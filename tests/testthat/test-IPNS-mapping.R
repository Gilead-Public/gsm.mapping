# Reads the SOURCE workflow YAML: under load_all, system.file() resolves to the
# source root, so the directory is passed explicitly rather than by strPackage.
ipns_workflow <- function() {
  workr::MakeWorkflowList(
    strNames = "IPNS",
    strPath = file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings"
    )
  )
}

test_that("IPNS recodes each status to its ordinal and report label (#162, #166)", {
  mapped <- list(
    Mapped_SUBJ = data.frame(
      studyid = "S",
      subjid = c("S1", "S2", "S3", "S4"),
      invid = "I1",
      country = "US",
      drv_enrollment_dt = as.Date("2025-01-01"),
      drv_ip_dosed = c("Y", "N", "N", "N"),
      drv_ip_first_dose_dt = as.Date(c("2025-01-05", NA, NA, NA)),
      drv_enrl_first_dose_days = c(5L, NA, NA, NA),
      drv_days_lapsed_since_enrl = c(NA, 10L, 60L, 60L),
      drv_ip_nonstarter_status = c(
        "Dosed",
        "Potential Non-Starter within window",
        "Potential Non-Starter outside window",
        "Confirmed Non-Starter"
      ),
      drv_kit_assigned = c("Y", "N", "Y", NA),
      stringsAsFactors = FALSE
    )
  )

  res <- workr::RunWorkflows(ipns_workflow(), mapped)$Mapped_IPNS

  expect_equal(nrow(res), 4)
  expect_equal(res$ipns_status_ord, c(0, 1, 2, 3))
  expect_equal(
    res$ipns_status,
    c(
      "Dosed",
      "Potential IP non-starter - within window",
      "Potential IP non-starter - outside window",
      "Confirmed IP non-starter"
    )
  )
  expect_equal(res$drv_kit_assigned, c("Y", "N", "Y", NA))
})

test_that("an unrecognised status yields NA, keeping the subject in the denominator (#162, #166)", {
  mapped <- list(
    Mapped_SUBJ = data.frame(
      studyid = "S",
      subjid = "S9",
      invid = "I1",
      country = "US",
      drv_enrollment_dt = as.Date("2025-01-01"),
      drv_ip_dosed = "N",
      drv_ip_first_dose_dt = as.Date(NA),
      drv_enrl_first_dose_days = NA_integer_,
      drv_days_lapsed_since_enrl = 60L,
      drv_ip_nonstarter_status = "Something Else",
      drv_kit_assigned = "N",
      stringsAsFactors = FALSE
    )
  )

  res <- workr::RunWorkflows(ipns_workflow(), mapped)$Mapped_IPNS

  expect_equal(nrow(res), 1)
  expect_true(is.na(res$ipns_status_ord))
  expect_true(is.na(res$ipns_status))
})

subj_ipns_workflows <- function() {
  workr::MakeWorkflowList(
    strNames = c("SUBJ", "IPNS"),
    strPath = file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings"
    )
  )
}

# Routed through Ingest(): RunWorkflows() alone passes columns whatever the spec says.
test_that("drv_kit_assigned reaches Mapped_SUBJ and Mapped_IPNS unchanged (#166)", {
  raw <- data.frame(
    studyid = "S",
    invid = "I1",
    country = "US",
    subjid = c("S1", "S2", "S3", "S4"),
    enrollyn = c("Y", "Y", "Y", "N"),
    drv_enrollment_dt = as.Date(c(
      "2025-01-01",
      "2025-01-01",
      "2025-01-01",
      NA
    )),
    drv_ip_dosed = c("Y", "N", "N", NA),
    drv_ip_first_dose_dt = as.Date(c("2025-01-05", NA, NA, NA)),
    drv_enrl_first_dose_days = c(5L, NA, NA, NA),
    drv_days_lapsed_since_enrl = c(NA, 60L, 60L, NA),
    drv_ip_nonstarter_status = c(
      "Dosed",
      "Confirmed Non-Starter",
      "Potential Non-Starter outside window",
      NA
    ),
    drv_kit_assigned = c("Y", "N", NA, NA),
    stringsAsFactors = FALSE
  )
  wf <- subj_ipns_workflows()
  lRaw <- gsm.mapping::Ingest(
    list(Raw_SUBJ = raw),
    gsm.mapping::CombineSpecs(wf["SUBJ"])
  )
  mapped <- workr::RunWorkflows(wf, lRaw)

  expect_equal(mapped$Mapped_SUBJ$drv_kit_assigned, c("Y", "N", NA))
  expect_equal(mapped$Mapped_IPNS$drv_kit_assigned, c("Y", "N", NA))
})
