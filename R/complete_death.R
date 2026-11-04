#' combines study completion data, overall response data, and death data to output a dataframe containing pd date and death status.
#'
#' @param dfDeath `data.frame` death data frame with mapped names
#' @param dfStudyCompletion `data.frame` study completion data frame with mapped names
#' @param dfOverallResponse `data.frame` overall response data frame with mapped names
#' @param dfRandomization `data.frame` randomization data frame with mapped names
#' @param chrDeathDateCol `character` name of column in `dfDeath` that contains
#'   the death date. Default: `"death_dt"`.
#' @param chrStudyDiscontinuationReasonCol `character` name of column in `dfStudyCompletion` that contains
#'   the reason for study completion. Default: `"compreas"`.
#' @param chrDeathResponse `character` value of `compreas` in `dfStudyCompletion` that indicates death. Default is "Death"
#' @param chrResponseCol `character` name of column in `dfOverallResponse` that contains
#'   the overall response. Default: `"ovrlresp"`.
#' @param chrPDResponse `character` value of `ovrlresp` in `dfOverallResponse` that indicates PD. Default is "PD"
#' @param chrResponseDateCol `character` name of column in `dfOverallResponse` that contains
#'   the overall response date. Default: `"rs_dt"`.
#' @param chrRandomizationDateCol `character` name of column in `dfRandomization` that contains the randomization date.
#'   Default: `"rgmn_dt"`.
#'
#' @return a `data.frame` combining death status and first PD status
#' @export
#'
#' @examples
#' \dontrun{
#' lSource <- list(
#'   Source_OverallResponse = gsm.endpoints::lSource_ep$Raw_OverallResponse, ## Overall response
#'   Source_Death = gsm.endpoints::lSource_ep$Raw_Death, ## Death date
#'   Source_STUDCOMP = gsm.endpoints::lSource_ep$Raw_STUDCOMP
#' )
#'
#' lMapping <- workr::MakeWorkflowList(
#'   strPath = "workflow/1_mappings",
#'   strNames = c("Death", "OverallResponse", "STUDCOMP"),
#'   strPackage = "gsm.mapping"
#' )
#'
#' combined_spec <- gsm.mapping::CombineSpecs(lMapping)
#'
#' lRaw <- gsm.mapping::Ingest(lSourceData = lSource, lSpec = combined_spec)
#'
#' complete_death(
#'   dfDeath = lRaw$Raw_Death,
#'   dfStudyCompletion = lRaw$Raw_STUDCOMP,
#'   dfOverallResponse = lRaw$Raw_OverallResponse
#' )
#' }
#'
complete_death <- function(
  dfDeath,
  dfStudyCompletion,
  dfOverallResponse,
  dfRandomization,
  chrDeathDateCol = "death_dt",
  chrStudyDiscontinuationReasonCol = "compreas",
  chrDeathResponse = "Death",
  chrResponseCol = "ovrlresp",
  chrPDResponse = "PD",
  chrResponseDateCol = "rs_dt",
  chrRandomizationDateCol = "rgmn_dt"
) {
  death <- dfStudyCompletion %>%
    filter(
      .data[[chrStudyDiscontinuationReasonCol]] == chrDeathResponse
    ) %>%
    full_join(dfDeath) %>%
    left_join(dfRandomization, by = c("studyid", "subjid")) %>%
    mutate(
      death_dt = .data[[chrDeathDateCol]],
      death_dy = as.numeric(
        .data[[chrDeathDateCol]] - .data[[chrRandomizationDateCol]]
      ),
      death = TRUE
    )

  pd <- dfOverallResponse %>%
    filter(
      .data[[chrResponseCol]] == chrPDResponse,
      !is.na(.data[[chrResponseDateCol]])
    ) %>%
    group_by(.data$subjid) %>%
    slice(which.min(.data[[chrResponseDateCol]])) %>%
    ungroup() %>%
    mutate(
      pd_date = .data[[chrResponseDateCol]]
    )

  select_cols <- c(
    "studyid",
    "subjid",
    "death_dt",
    "death_dy",
    "death",
    "deathcls",
    "pd_date"
  )

  output <- death %>%
    full_join(
      pd,
      c("studyid", "subjid")
    ) %>%
    select(
      all_of(
        select_cols
      )
    )

  # Warn if death date is missing for any patients marked as deceased.
  missing_death_dates <- output %>%
    filter(
      .data$death,
      is.na(.data$death_dt)
    ) %>%
    pull(.data$subjid)

  if (length(missing_death_dates) > 1) {
    cli::cli_alert_warning(
      glue::glue(
        "Death date missing for patients: {
           stringr::str_wrap(stringr::str_flatten(missing_death_dates, collapse = ', '), 48)
        }\nLast known date will be used as a substitute."
      )
    )
  }

  return(output)
}
