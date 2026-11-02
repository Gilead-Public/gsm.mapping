# Reads the SOURCE workflow YAML: under load_all, system.file() resolves to the
# source root, so the directory is passed explicitly rather than by strPackage.
mapping_workflows <- function(strNames) {
  workr::MakeWorkflowList(
    strNames = strNames,
    strPath = file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings"
    )
  )
}

# Routed through Ingest(): RunWorkflows() alone passes columns whatever the spec says.
run_from_raw_subj <- function(raw, strNames = "SUBJ") {
  wf <- mapping_workflows(strNames)
  lRaw <- gsm.mapping::Ingest(
    list(Raw_SUBJ = raw),
    gsm.mapping::CombineSpecs(wf["SUBJ"])
  )
  workr::RunWorkflows(wf, lRaw)
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
