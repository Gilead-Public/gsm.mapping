# Fatal-AE fields on the AE mapping (gsm.mapping#135). The premature-death
# report (gsm.kri#304) needs AE outcome (aeout), derived relatedness (aereldrv)
# and serious-death flag (aesdth) to identify fatal AEs without relying only on
# the grade-5 proxy. Routed through the real Ingest -> AE mapping pipeline.

make_ae_source <- function(include_fatal_cols = TRUE) {
  ae <- data.frame(
    studyid = "S",
    subjid = c("S1", "S1", "S2"),
    aeser = c("Y", "N", "Y"),
    aest_dt = as.Date(c("2020-01-01", "2020-02-01", "2020-03-01")),
    aeen_dt = as.Date(c("2020-01-03", "2020-02-02", "2020-03-02")),
    mdrpt_nsv = c("Cardiac arrest", "Headache", "Sepsis"),
    mdrsoc_nsv = c("Cardiac disorders", "Nervous system disorders", "Infections"),
    aetoxgr = c(5L, 1L, 4L),
    aeongo = "N",
    aerel = c("RELATED", "NOT RELATED", NA),
    stringsAsFactors = FALSE
  )
  if (include_fatal_cols) {
    ae$aeout <- c("Fatal", "Recovered/Resolved", "Fatal")
    ae$aereldrv <- c("Yes", "No", NA)
    ae$aesdth <- c("Yes", "No", "Yes")
  }
  list(Raw_AE = ae)
}

run_ae_mapping <- function(lSourceData) {
  wf <- workr::MakeWorkflowList(
    strNames = "AE",
    strPath = file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings"
    ),
    bExact = TRUE
  )
  raw <- gsm.mapping::Ingest(lSourceData, gsm.mapping::CombineSpecs(wf))
  workr::RunWorkflows(wf, raw)$Mapped_AE
}

test_that("AE spec declares aeout, aereldrv and aesdth as character (#135)", {
  wf <- workr::MakeWorkflowList(
    strNames = "AE",
    strPath = file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings"
    ),
    bExact = TRUE
  )
  spec <- gsm.mapping::CombineSpecs(wf)$Raw_AE

  for (col in c("aeout", "aereldrv", "aesdth")) {
    expect_true(col %in% names(spec), info = col)
    expect_equal(spec[[col]]$type, "character", info = col)
  }
})

test_that("Mapped_AE passes aeout, aereldrv and aesdth through unchanged (#135)", {
  mapped <- run_ae_mapping(make_ae_source())

  expect_true(all(c("aeout", "aereldrv", "aesdth") %in% names(mapped)))
  expect_equal(nrow(mapped), 3L)
  expect_type(mapped$aeout, "character")
  expect_type(mapped$aereldrv, "character")
  expect_type(mapped$aesdth, "character")
  expect_equal(mapped$aeout, c("Fatal", "Recovered/Resolved", "Fatal"))
  # Missing relatedness stays missing; downstream renders it as Unknown.
  expect_equal(mapped$aereldrv, c("Yes", "No", NA))
  expect_equal(mapped$aesdth, c("Yes", "No", "Yes"))
})

test_that("AE mapping still runs on legacy extracts without the fatal-AE fields (#135)", {
  expect_no_error(
    mapped <- suppressWarnings(run_ae_mapping(make_ae_source(include_fatal_cols = FALSE)))
  )
  expect_equal(nrow(mapped), 3L)
  expect_true(all(c("subjid", "aetoxgr", "aerel", "mdrpt_nsv") %in% names(mapped)))
})
