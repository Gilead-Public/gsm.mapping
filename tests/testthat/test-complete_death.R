# Data Setup ===================================================================
test <- mapped_data$Mapped_Death

# Testing ======================================================================
test_that("Death workflow uses explicit death and progression responses (#170)", {
  workflows <- workr::MakeWorkflowList(
    strNames = "Death",
    strPath = file.path(system.file(package = "gsm.mapping"), "workflow", "1_mappings")
  )
  params <- workflows[[1]]$steps[[2]]$params
  expect_identical(params$chrDeathResponse, "DEATH")
  expect_identical(params$chrPDResponse, "Progressive Disease")

  source_data <- list(
    Raw_Death = data.frame(
      studyid = character(),
      subjid = character(),
      death_dt = as.Date(character()),
      deathcls = character()
    ),
    Mapped_STUDCOMP = data.frame(
      studyid = "STUDY001",
      subjid = c("DEATH_MATCH", "DEATH_DEFAULT"),
      compreas = c("DEATH", "Death")
    ),
    Mapped_OverallResponse = data.frame(
      studyid = "STUDY001",
      subjid = c("PD_MATCH", "PD_MATCH", "PD_DEFAULT"),
      ovrlresp = c("Progressive Disease", "Progressive Disease", "PD"),
      rs_dt = as.Date(c("2023-06-15", "2023-05-10", "2023-04-01"))
    ),
    Mapped_Randomization = data.frame(
      studyid = "STUDY001",
      subjid = c("DEATH_MATCH", "DEATH_DEFAULT", "PD_MATCH", "PD_DEFAULT"),
      rgmn_dt = as.Date("2023-01-01")
    )
  )

  result <- workr::RunWorkflows(workflows, source_data)$Mapped_Death

  expect_identical(sort(result$subjid), c("DEATH_MATCH", "PD_MATCH"))
  expect_true(result$death[result$subjid == "DEATH_MATCH"])
  expect_equal(
    result$pd_date[result$subjid == "PD_MATCH"],
    as.Date("2023-05-10")
  )
})

testthat::test_that("verify complete_death() internal study_comp filter is working properly (#47)", {
  original_code <- mapped_data$Mapped_STUDCOMP %>%
    filter(.data$compreas == "Death") %>%
    full_join(lSource$Raw_Death, by = "subjid") %>%
    mutate("death" = TRUE)

  double_code <- c(
    mapped_data$Mapped_STUDCOMP %>%
      filter(compreas == "Death") %>%
      pull(subjid),
    lSource$Raw_Death$subjid
  ) %>% unique()

  expect_identical(sort(original_code$subjid), sort(double_code))
})

testthat::test_that("verify complete_death() internal response filter is working properly", {
  original_code <- mapped_data$Mapped_OverallResponse %>%
    filter(
      .data$ovrlresp == "PD",
      !is.na(.data$rs_dt)
    ) %>%
    group_by(.data$subjid) %>%
    slice(which.min(.data$rs_dt)) %>%
    rename("pd_date" = "rs_dt") %>%
    ungroup() %>%
    arrange(subjid)

  double_code <- mapped_data$Mapped_OverallResponse %>%
    filter(ovrlresp == "PD") %>%
    group_by(subjid) %>%
    reframe(first_pd = min(rs_dt)) %>%
    arrange(subjid)

  expect_identical(original_code$subjid, double_code$subjid)
  expect_identical(original_code$pd_date, double_code$first_pd)
})

testthat::test_that("verify complete_death() output is valid for data.frame input (#47, #134)", {
  expect_snapshot(test)
  pd <- mapped_data$Mapped_OverallResponse %>%
    filter(ovrlresp == "PD") %>%
    group_by(subjid) %>%
    reframe(first_pd = min(rs_dt))

  study_comp_death <- mapped_data$Mapped_STUDCOMP %>%
    filter(compreas == "Death") %>%
    select(subjid, compreas)

  total <- lSource$Raw_Death %>%
    filter(!is.na(death_dt)) %>%
    full_join(pd, by = "subjid") %>%
    full_join(study_comp_death, by = "subjid")

  expect_identical(sort(test$subjid), sort(total$subjid))
  expect_true(
    all(
      c("subjid", "pd_date", "death_dt", "death", "deathcls") %in% names(test)
    )
  )
})


test_that("complete_death calculates death_dy correctly", {
  # Create test data with known dates for verification
  dfDeath <- data.frame(
    studyid = c("STUDY001", "STUDY001"),
    subjid = c("SUBJ001", "SUBJ002"),
    death_dt = as.Date(c("2023-06-15", "2023-07-20")),
    deathcls = c("Adverse Event", "Disease Progression")
  )

  dfStudyCompletion <- data.frame(
    studyid = c("STUDY001", "STUDY001"),
    subjid = c("SUBJ001", "SUBJ002"),
    compreas = c("Death", "Death")
  )

  dfOverallResponse <- data.frame(
    studyid = c("STUDY001"),
    subjid = c("SUBJ003"),
    ovrlresp = c("PD"),
    rs_dt = as.Date("2023-05-10")
  )

  dfRandomization <- data.frame(
    studyid = c("STUDY001", "STUDY001", "STUDY001"),
    subjid = c("SUBJ001", "SUBJ002", "SUBJ003"),
    rgmn_dt = as.Date(c("2023-01-01", "2023-02-15", "2023-01-15"))
  )

  # Run the function
  result <- complete_death(
    dfDeath = dfDeath,
    dfStudyCompletion = dfStudyCompletion,
    dfOverallResponse = dfOverallResponse,
    dfRandomization = dfRandomization
  )

  # Expected death_dy calculations:
  # SUBJ001: 2023-06-15 - 2023-01-01 = 165 days
  # SUBJ002: 2023-07-20 - 2023-02-15 = 155 days

  # Test that death_dy is calculated correctly
  subj001_result <- result[result$subjid == "SUBJ001", ]
  subj002_result <- result[result$subjid == "SUBJ002", ]

  expect_equal(subj001_result$death_dy, 165)
  expect_equal(subj002_result$death_dy, 155)

  # Test that death status is set correctly
  expect_true(subj001_result$death)
  expect_true(subj002_result$death)

  # Test that death_dt is preserved
  expect_equal(subj001_result$death_dt, as.Date("2023-06-15"))
  expect_equal(subj002_result$death_dt, as.Date("2023-07-20"))
})

test_that("complete_death handles missing randomization dates gracefully (#134)", {
  # Test data with missing randomization date
  dfDeath <- data.frame(
    studyid = "STUDY001",
    subjid = "SUBJ001",
    death_dt = as.Date("2023-06-15"),
    deathcls = "Adverse Event"
  )

  dfStudyCompletion <- data.frame(
    studyid = "STUDY001",
    subjid = "SUBJ001",
    compreas = "Death"
  )

  dfOverallResponse <- data.frame(
    studyid = character(0),
    subjid = character(0),
    ovrlresp = character(0),
    rs_dt = as.Date(character(0))
  )

  dfRandomization <- data.frame(
    studyid = "STUDY001",
    subjid = "SUBJ002", # Different subject - no match
    rgmn_dt = as.Date("2023-01-01")
  )

  # Run the function
  result <- complete_death(
    dfDeath = dfDeath,
    dfStudyCompletion = dfStudyCompletion,
    dfOverallResponse = dfOverallResponse,
    dfRandomization = dfRandomization
  )

  # Test that death_dy is NA when randomization date is missing
  expect_true(is.na(result$death_dy))

  # Test that other fields are still populated correctly
  expect_true(result$death)
  expect_equal(result$death_dt, as.Date("2023-06-15"))
})
