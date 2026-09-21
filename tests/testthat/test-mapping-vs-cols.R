# Site/country exposure and deterministic ordering for VS (gsm.mapping#164).
# Routed through the real Ingest -> VS mapping pipeline rather than hand-built
# frames, so the Raw_VS spec, the Mapped_SUBJ join and the ordering step are
# checked together. Reads the SOURCE workflow YAMLs via the load_all
# system.file shim.
#
# invid and country come from Mapped_SUBJ, not from the VS extract: the real VS
# domain does carry its own invid, but Mapped_SUBJ is the designated source of
# truth for site and country assignment.

make_vs_source <- function() {
  list(
    Raw_SUBJ = data.frame(
      studyid = "S",
      invid = c("I1", "I2"),
      country = c("US", "CAN"),
      subjid = c("S1", "S2"),
      subject_nsv = c("S1", "S2"),
      enrollyn = c("Y", "Y"),
      timeonstudy = c(100L, 100L),
      firstdosedate = as.Date(c("2020-01-01", "2020-01-01")),
      mincreated_dts = as.POSIXct(rep("2020-01-01", 2)),
      stringsAsFactors = FALSE
    ),
    # Deliberately shuffled, with a same-date pair (Visit 1 / Visit 3) that only
    # the visit tie-breaker can order.
    # Column names here are the RAW source names (project, foldername,
    # bsaentry), so Ingest() exercises the spec's source_col remapping.
    Raw_VS = data.frame(
      project = "S",
      subjid = c("S2", "S1", "S1", "S1"),
      foldername = c("Visit 1", "Visit 2", "Visit 3", "Visit 1"),
      vs_dt = as.Date(c("2020-01-01", "2020-02-01", "2020-01-01", "2020-01-01")),
      vsperf_std = "Y",
      weight = 70,
      height = 170,
      sysbp = c(110, 120, 130, 140),
      diabp = 80,
      pulse = 72,
      temp = 37,
      resp = 16,
      bsaentry = 1.8,
      stringsAsFactors = FALSE
    )
  )
}

run_vs_mapping <- function(lSourceData) {
  wf <- workr::MakeWorkflowList(
    strNames = c("SUBJ", "VS"),
    strPath = file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings"
    )
  )
  raw <- gsm.mapping::Ingest(lSourceData, gsm.mapping::CombineSpecs(wf))
  workr::RunWorkflows(wf, raw)$Mapped_VS
}

test_that("Mapped_VS draws invid and country from Mapped_SUBJ (#164)", {
  mapped <- run_vs_mapping(make_vs_source())

  expect_true(all(
    c("studyid", "invid", "country", "subjid", "visit", "vs_dt") %in%
      names(mapped)
  ))
  expect_type(mapped$invid, "character")
  expect_type(mapped$country, "character")

  # The join must attach the subject's site/country, not invent rows.
  expect_equal(nrow(mapped), 4L)
  expect_equal(
    mapped$invid,
    c("I1", "I1", "I1", "I2")
  )
  expect_equal(
    mapped$country,
    c("US", "US", "US", "CAN")
  )

  # Additive only: the vitals columns still arrive, under their mapped names.
  expect_true(all(
    c("weight", "height", "sysbp", "diabp", "pulse", "temp", "resp", "bsa") %in%
      names(mapped)
  ))

  # vs_dt must stay a Date through the query, or downstream date arithmetic breaks.
  expect_s3_class(mapped$vs_dt, "Date")
})

test_that("Mapped_VS is deterministically ordered regardless of raw row order (#164)", {
  mapped <- run_vs_mapping(make_vs_source())

  # subjid, then date, then visit for the same-date tie.
  expect_equal(mapped$subjid, c("S1", "S1", "S1", "S2"))
  expect_equal(mapped$visit, c("Visit 1", "Visit 3", "Visit 2", "Visit 1"))
  expect_equal(mapped$sysbp, c(140, 130, 120, 110))

  shuffled <- make_vs_source()
  shuffled$Raw_VS <- shuffled$Raw_VS[c(3, 1, 4, 2), ]
  expect_equal(run_vs_mapping(shuffled)$sysbp, mapped$sysbp)
})

test_that("Mapped_VS keeps VS records for participants missing from Mapped_SUBJ (#164)", {
  # Mapped_SUBJ filters to enrollyn == 'Y', so an unenrolled participant with VS
  # records resolves to no site/country. A left join keeps the record with NA
  # rather than silently dropping it -- worth pinning, since an inner join here
  # would quietly change downstream denominators.
  lSourceData <- make_vs_source()
  lSourceData$Raw_SUBJ$enrollyn <- c("Y", "N")

  mapped <- run_vs_mapping(lSourceData)

  expect_equal(nrow(mapped), 4L)
  orphan <- mapped[mapped$subjid == "S2", ]
  expect_equal(nrow(orphan), 1L)
  expect_true(is.na(orphan$invid))
  expect_true(is.na(orphan$country))
})
