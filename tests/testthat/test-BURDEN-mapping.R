burden_raw <- function() {
  list(
    Raw_SITE = data.frame(
      protocol = "S",
      pi_number = c("I1", "I2", "I3", "I4"),
      site_status = "Active",
      stringsAsFactors = FALSE
    ),
    # I2 is repeated with the same count; I3 has no DQS row; I9 is not a study site.
    Raw_BURDEN = data.frame(
      edc_site_id = c("I1", "I2", "I2", "I4", "I9"),
      active_protocol_count = c(3, 7, 7, 0, 12),
      stringsAsFactors = FALSE
    )
  )
}

run_burden <- function(lRaw) {
  wf <- mapping_workflows("BURDEN")
  lData <- gsm.mapping::Ingest(lRaw, gsm.mapping::CombineSpecs(wf))
  workr::RunWorkflows(wf, lData)$Mapped_BURDEN
}

test_that("BURDEN has one row per study site with its DQS count (#182)", {
  lRaw <- burden_raw()
  res <- run_burden(lRaw)
  res <- res[order(res$invid), ]
  rownames(res) <- NULL

  # Double programming: base R lookup, not SQL/dplyr.
  burden <- unique(lRaw$Raw_BURDEN)
  expected <- data.frame(
    studyid = "S",
    invid = lRaw$Raw_SITE$pi_number,
    active_protocol_count = as.integer(
      burden$active_protocol_count[match(lRaw$Raw_SITE$pi_number, burden$edc_site_id)]
    ),
    stringsAsFactors = FALSE
  )

  expect_equal(as.data.frame(res), expected)
  expect_type(res$active_protocol_count, "integer")
})

test_that("sites without DQS coverage get NA, not 0 (#182)", {
  res <- run_burden(burden_raw())
  expect_true(is.na(res$active_protocol_count[res$invid == "I3"]))
  expect_equal(res$active_protocol_count[res$invid == "I4"], 0L)
  expect_false("I9" %in% res$invid)
})

test_that("conflicting DQS counts for one site error instead of inflating rows (#182)", {
  lRaw <- burden_raw()
  lRaw$Raw_BURDEN$active_protocol_count[3] <- 8
  expect_error(run_burden(lRaw))
})

test_that("selecting SITE does not pull in the BURDEN mapping (#182)", {
  expect_named(mapping_workflows("SITE"), "SITE")
})
