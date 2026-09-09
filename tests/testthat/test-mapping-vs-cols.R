# Site/country exposure and deterministic ordering for VS (gsm.mapping#164).
# Routed through the real Ingest -> VS mapping pipeline rather than hand-built
# frames, so the Raw_VS spec and the ordering step are checked together.
# Reads the SOURCE workflow YAMLs via the load_all system.file shim.

test_that("Mapped_VS exposes invid and country and is deterministically ordered (#164)", {
  wf_dir <- file.path(
    system.file(package = "gsm.mapping"),
    "workflow",
    "1_mappings"
  )
  wf <- workr::MakeWorkflowList(strNames = "VS", strPath = wf_dir)

  # Deliberately shuffled, with a same-date pair (Visit 1 / Visit 3) that only
  # the visit tie-breaker can order.
  lSourceData <- list(
    Raw_VS = data.frame(
      studyid = "S",
      invid = c("I2", "I1", "I1", "I1"),
      country = c("CAN", "US", "US", "US"),
      subjid = c("S2", "S1", "S1", "S1"),
      foldername = c("Visit 1", "Visit 2", "Visit 3", "Visit 1"),
      vs_dt = as.Date(c("2020-01-01", "2020-02-01", "2020-01-01", "2020-01-01")),
      vsperf_std = "Y",
      weight = 70,
      height = 170,
      bmi = 24.2,
      sysbp = c(110, 120, 130, 140),
      diabp = 80,
      pulse = 72,
      temp = 37,
      resp = 16,
      bsa = 1.8,
      stringsAsFactors = FALSE
    )
  )

  raw <- gsm.mapping::Ingest(lSourceData, gsm.mapping::CombineSpecs(wf))
  mapped <- workr::RunWorkflows(wf, raw)$Mapped_VS

  expect_true(all(
    c("studyid", "invid", "country", "subjid", "visit", "vs_dt") %in%
      names(mapped)
  ))
  expect_type(mapped$invid, "character")
  expect_type(mapped$country, "character")

  # Additive only: the vitals columns still arrive, and no rows are dropped.
  expect_true(all(
    c("weight", "height", "bmi", "sysbp", "diabp", "pulse", "temp", "resp", "bsa") %in%
      names(mapped)
  ))
  expect_equal(nrow(mapped), 4L)

  # vs_dt must stay a Date through the query, or downstream date arithmetic breaks.
  expect_s3_class(mapped$vs_dt, "Date")

  # subjid, then date, then visit for the same-date tie.
  expect_equal(mapped$subjid, c("S1", "S1", "S1", "S2"))
  expect_equal(mapped$visit, c("Visit 1", "Visit 3", "Visit 2", "Visit 1"))
  expect_equal(mapped$sysbp, c(140, 130, 120, 110))

  # Ordering must not depend on the order the raw rows happened to arrive in.
  shuffled <- lSourceData
  shuffled$Raw_VS <- shuffled$Raw_VS[c(3, 1, 4, 2), ]
  reshuffled <- workr::RunWorkflows(
    wf,
    gsm.mapping::Ingest(shuffled, gsm.mapping::CombineSpecs(wf))
  )$Mapped_VS
  expect_equal(reshuffled$sysbp, mapped$sysbp)
})
