# iecat_concat in Mapped_EXCLUSION (gsm.mapping#188). Runs the SOURCE IE and
# EXCLUSION workflows through the load_all system.file shim.

run_exclusion_mapping <- function() {
  wf <- workr::MakeWorkflowList(
    strNames = c("IE", "EXCLUSION"),
    strPath = file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings"
    ),
    strPackage = NULL,
    bExact = TRUE
  )
  lData <- list(
    # S1's codes arrive unsorted, so only an ordered aggregate pairs them.
    Raw_IE = data.frame(
      studyid = "ST",
      subjid = c("S1", "S1", "S2"),
      tiver = "1",
      ietest = c("Inclusion 1", "Exclusion 2", "Inclusion 1"),
      ietestcd = c("INCL1", "EXCL2", "INCL1"),
      ieorres = c("No", "Yes", "Yes"),
      iecat = NA_character_,
      stringsAsFactors = FALSE
    ),
    Mapped_ENROLL = data.frame(
      studyid = "ST",
      subjectid = c("S1", "S2"),
      subjid = c("S1", "S2"),
      invid = "I1",
      enrollyn = "Y",
      country = "US",
      stringsAsFactors = FALSE
    ),
    Mapped_PD = data.frame(
      studyid = character(),
      subjid = character(),
      dvterm = character(),
      dvdecod = character(),
      deemedimportant = character(),
      dvdtm = as.POSIXct(character()),
      stringsAsFactors = FALSE
    )
  )
  workr::RunWorkflows(wf, lData)$Mapped_EXCLUSION
}

test_that("Mapped_EXCLUSION carries iecat_concat aligned with ietestcd_concat (#188)", {
  mapped <- run_exclusion_mapping()
  s1 <- mapped[mapped$subjid == "S1", ]
  s2 <- mapped[mapped$subjid == "S2", ]

  expect_equal(s1$ietestcd_concat, "EXCL2,INCL1")
  expect_equal(s1$iecat_concat, "EX,IN")
  expect_true(is.na(s2$iecat_concat))
  expect_true(is.na(s2$ietestcd_concat))
})
