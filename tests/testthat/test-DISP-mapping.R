test_that("DISP preserves upstream fields and includes unenrolled participants (#169)", {
  raw <- data.frame(
    studyid = "S",
    invid = c("I1", "I1", "I2"),
    country = c("US", "US", "CA"),
    subjid = c("S1", "S2", "S3"),
    enrollyn = c("Y", "N", "N"),
    drv_study_disposition = c(
      "upstream-status-1",
      "upstream-status-2",
      "unrecognized-upstream-status"
    ),
    drv_last_contact_dt = as.Date(c("2025-01-10", "2025-02-10", NA)),
    drv_withdrawn_dt = as.Date(c(NA, "2025-02-01", NA)),
    drv_death_dt = as.Date(c(NA, NA, "2025-03-01")),
    drv_ae_death_dt = as.Date(c(NA, NA, "2025-03-01")),
    rbqm_flags = c("flag-1", NA, "flag-3"),
    stringsAsFactors = FALSE
  )
  workflows <- mapping_workflows(c("SUBJ", "DISP"))
  raw_data <- gsm.mapping::Ingest(
    list(Raw_SUBJ = raw),
    gsm.mapping::CombineSpecs(workflows)
  )
  result <- workr::RunWorkflows(workflows, raw_data)
  mapped <- result$Mapped_DISP[match(raw$subjid, result$Mapped_DISP$subjid), ]

  expect_equal(nrow(mapped), nrow(raw))
  expect_equal(mapped$subjid, raw$subjid)
  expect_equal(mapped$enrollyn, raw$enrollyn)
  expect_equal(mapped$drv_study_disposition, raw$drv_study_disposition)
  expect_s3_class(mapped$drv_last_contact_dt, "Date")
  expect_equal(mapped$drv_last_contact_dt, raw$drv_last_contact_dt)
  expect_equal(mapped$drv_withdrawn_dt, raw$drv_withdrawn_dt)
  expect_equal(mapped$drv_death_dt, raw$drv_death_dt)
  expect_equal(mapped$drv_ae_death_dt, raw$drv_ae_death_dt)
  expect_equal(mapped$rbqm_flags, raw$rbqm_flags)
  expect_false(any(startsWith(names(mapped), "disp_")))

  # SUBJ continues to apply its existing enrolled-subject filter.
  expect_equal(result$Mapped_SUBJ$subjid, "S1")
  expect_equal(
    result$Mapped_SUBJ$drv_study_disposition,
    raw$drv_study_disposition[1]
  )
  expect_equal(
    result$Mapped_SUBJ$drv_last_contact_dt,
    raw$drv_last_contact_dt[1]
  )
  expect_equal(
    result$Mapped_SUBJ$drv_withdrawn_dt,
    raw$drv_withdrawn_dt[1]
  )
  expect_equal(result$Mapped_SUBJ$drv_death_dt, raw$drv_death_dt[1])
  expect_equal(result$Mapped_SUBJ$drv_ae_death_dt, raw$drv_ae_death_dt[1])
  expect_equal(result$Mapped_SUBJ$rbqm_flags, raw$rbqm_flags[1])
})
