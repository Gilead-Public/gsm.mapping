# Routed through Ingest(): RunWorkflows() alone passes columns whatever the spec says.
run_subj <- function(raw) {
  wf <- workr::MakeWorkflowList(
    strNames = "SUBJ",
    strPath = file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings"
    )
  )
  lRaw <- gsm.mapping::Ingest(
    list(Raw_SUBJ = raw),
    gsm.mapping::CombineSpecs(wf)
  )
  workr::RunWorkflows(wf, lRaw)$Mapped_SUBJ
}

ptd_raw <- function() {
  data.frame(
    studyid = "S",
    invid = "I1",
    country = "US",
    subjid = c("S1", "S2", "S3"),
    enrollyn = "Y",
    drv_treatment_discontinuation_dt = c("2025-02-01", "2025-03-01", NA),
    drv_premature_discontinuation_reason = c(
      NA,
      "Adverse Event, Physician Decision",
      NA
    ),
    drv_days_lapsed_enrl_discontinuation = c(32L, 60L, NA),
    stringsAsFactors = FALSE
  )
}

test_that("SUBJ passes the three PTD fields to Mapped_SUBJ with their spec types (#160)", {
  res <- run_subj(ptd_raw())

  expect_s3_class(res$drv_treatment_discontinuation_dt, "Date")
  expect_equal(
    res$drv_treatment_discontinuation_dt,
    as.Date(c("2025-02-01", "2025-03-01", NA))
  )
  expect_type(res$drv_days_lapsed_enrl_discontinuation, "integer")
  expect_equal(res$drv_days_lapsed_enrl_discontinuation, c(32L, 60L, NA))
})

test_that("a null reason stays null and a comma-joined reason is not split (#160)", {
  res <- run_subj(ptd_raw())

  expect_equal(nrow(res), 3)
  expect_equal(
    res$drv_premature_discontinuation_reason,
    c(NA, "Adverse Event, Physician Decision", NA)
  )
})

test_that("a study delivering none of the PTD fields still maps SUBJ (#160)", {
  res <- run_subj(ptd_raw()[c(
    "studyid",
    "invid",
    "country",
    "subjid",
    "enrollyn"
  )])

  expect_equal(nrow(res), 3)
  expect_false(any(grepl("discontinu", names(res))))
})
