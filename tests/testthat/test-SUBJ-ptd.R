test_that("SUBJ passes the three PTD fields to Mapped_SUBJ with their spec types (#160)", {
  res <- run_from_raw_subj(ptd_raw())$Mapped_SUBJ

  expect_s3_class(res$drv_treatment_discontinuation_dt, "Date")
  expect_equal(
    res$drv_treatment_discontinuation_dt,
    as.Date(c("2025-02-01", "2025-03-01", NA))
  )
  expect_type(res$drv_days_lapsed_enrl_discontinuation, "integer")
  expect_equal(res$drv_days_lapsed_enrl_discontinuation, c(32L, 60L, NA))
})

test_that("a null reason stays null and a comma-joined reason is not split (#160)", {
  res <- run_from_raw_subj(ptd_raw())$Mapped_SUBJ

  expect_equal(nrow(res), 3)
  expect_equal(
    res$drv_premature_discontinuation_reason,
    c(NA, "Adverse Event, Physician Decision", NA)
  )
})

test_that("a study delivering none of the PTD fields still maps SUBJ (#160)", {
  res <- run_from_raw_subj(ptd_raw()[c(
    "studyid",
    "invid",
    "country",
    "subjid",
    "enrollyn"
  )])$Mapped_SUBJ

  expect_equal(nrow(res), 3)
  expect_false(any(grepl("discontinu", names(res))))
})
