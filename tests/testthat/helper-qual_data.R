library(yaml)

set.seed(123)

## Declare all the data
lSource <- gsm.core::lSource

# Step 0 - Data Ingestion - standardize tables/columns names
lData <- list(
  # Shimmed until gsm.core regenerates lSource with the upstream drv_ fields;
  # the Raw_LB entry below uses the same pattern for lbtstnam/rptresn.
  Raw_SUBJ = lSource$Raw_SUBJ %>%
    mutate(
      drv_enrollment_dt = .data$enrolldt,
      drv_ip_dosed = ifelse(is.na(.data$firstdosedate), "N", "Y"),
      drv_ip_first_dose_dt = .data$firstdosedate,
      drv_enrl_first_dose_days = as.integer(.data$firstdosedate - .data$enrolldt) + 1L,
      drv_days_lapsed_since_enrl = NA_integer_,
      drv_ip_nonstarter_status = ifelse(
        is.na(.data$firstdosedate),
        "Potential Non-Starter within window",
        "Dosed"
      )
    ),
  Raw_AE = lSource$Raw_AE,
  Raw_PD = lSource$Raw_PD %>%
    rename(subjid = subjectenrollmentnumber) %>%
    rename(dvdecod = crocategory) %>%
    rename(dvterm = description) %>%
    rename(dvdtm = deviationdate),
  Raw_LB = lSource$Raw_LB %>%
    mutate(
      lbtstnam = "ALT (SGPT)",
      rptresn = 25
    ),
  Raw_STUDCOMP = lSource$Raw_STUDCOMP,
  Raw_SDRGCOMP = lSource$Raw_SDRGCOMP %>%
    mutate(phase = as.character(phase)),
  Raw_DATACHG = lSource$Raw_DATACHG %>%
    rename(subject_nsv = subjectname),
  Raw_DATAENT = lSource$Raw_DATAENT %>%
    rename(subject_nsv = subjectname),
  Raw_QUERY = lSource$Raw_QUERY %>%
    rename(subject_nsv = subjectname),
  Raw_ENROLL = lSource$Raw_ENROLL,
  Raw_SITE = lSource$Raw_SITE %>%
    rename(studyid = protocol) %>%
    rename(invid = pi_number) %>%
    rename(InvestigatorFirstName = pi_first_name) %>%
    rename(InvestigatorLastName = pi_last_name) %>%
    rename(City = city) %>%
    rename(State = state) %>%
    rename(Country = country),
  Raw_STUDY = lSource$Raw_STUDY %>%
    rename(studyid = protocol_number),
  Raw_PK = lSource$Raw_PK %>%
    rename(visit = foldername),
  Raw_IE = lSource$Raw_IE,
  Raw_VISIT = lSource$Raw_VISIT %>%
    rename(visit = foldername),
  Raw_Death = lSource$Raw_Death %>%
    mutate(deathcls = NA_character_),
  Raw_OverallResponse = lSource$Raw_OverallResponse %>%
    rename(response_folder = foldername) %>%
    # gsm.core::lSource supplies rs_dt as a character string; coerce to Date to
    # match the mapping spec (rs_dt: type: Date) and the production Ingest() path.
    mutate(rs_dt = as.Date(rs_dt)),
  Raw_Randomization = lSource$Raw_Randomization,
  Raw_VS = data.frame(
    studyid = "STUDY01",
    subjid = "SUBJ01",
    visit = "Visit 1",
    vs_dt = as.Date("2024-01-01"),
    vsperf_std = "Y",
    weight = 70,
    height = 170,
    bmi = 24.2,
    sysbp = 120,
    diabp = 80,
    pulse = 72,
    temp = 37,
    resp = 16,
    bsa = 1.8
  )
)

## Data with missing values (15% NA's)

## specify domains
domains <- gsub("Raw_", "", names(lData))

## Get Mapped data
mappings_wf <- workr::MakeWorkflowList(
  strNames = domains,
  strPath = file.path(system.file(package = "gsm.mapping"), "workflow", "1_mappings")
)

gsm.core::SetLogLevel(level = "WARN")
mapped_data <- workr::RunWorkflows(mappings_wf, lData)
gsm.core::SetLogLevel(level = "DEBUG")

mapping_output <- map(mappings_wf, ~ .x$steps[[1]]$output) %>% unlist()
