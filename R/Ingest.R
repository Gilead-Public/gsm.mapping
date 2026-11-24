#' Ingests data from a source based on a given specification.
#'
#' This function ingests data from a source based on a given specification. It iterates over each
#' domain in the specification and checks if the columns exist in the source data. It then
#' constructs a query to select the columns from the source and calls the `RunQuery` function to
#' retrieve the data. The resulting data frames are stored in a list, where each data frame
#' corresponds to a domain in the specification.
#'
#' @param lSourceData `list` A named list of source data frames.
#' @param lSpec `list` A named list of column specifications.
#' @param strDomain `character` Domain name to add to the data frames after ingestions. Default: "Raw"
#'
#' @return `list` A named list of data frames, where each data frame corresponds to a domain in the
#' specification.
#'
#' @examples
#' core_mappings <- c(
#'   "AE", "COUNTRY", "DATACHG", "DATAENT", "ENROLL", "LB",
#'   "PD", "QUERY", "STUDY", "STUDCOMP", "SDRGCOMP", "SITE", "SUBJ"
#' )
#'
#' lSourceData <- gsm.core::lSource
#'
#' lIngestWorkflow <- workr::MakeWorkflowList(
#'   strNames = core_mappings,
#'   strPath = "workflow/1_mappings", strPackage = "gsm.mapping"
#' )[[1]]
#' lRawData <- Ingest(lSourceData, lIngestWorkflow$spec)
#'
#' @export

Ingest <- function(lSourceData, lSpec, strDomain = "Raw") {
  gsm.core::stop_if(!is.list(lSourceData), "[ lSourceData ] must be a list.")
  gsm.core::stop_if(!is.list(lSpec), "[ lSpec ] must be a list.")

  # If there is a domain (specificed with and underscore) in lSourceData/lSpec names, remove it
  names(lSourceData) <- sub(".*_", "", names(lSourceData))
  names(lSpec) <- sub(".*_", "", names(lSpec))

  lMappedData <- lSpec %>%
    imap(
      function(columnSpecs, domain) {
        gsm.core::LogMessage(
          level = "info",
          message = "Ingesting data for {domain}.",
          cli_detail = "alert_info"
        )

        # check that the domain exists in the source data
        dfSource <- lSourceData[[domain]]

        gsm.core::stop_if(
          cnd = is.null(dfSource),
          message = glue("Domain '*_{domain}' not found in source data.")
        )

        dfMapped <- ApplySpec(
          dfSource,
          columnSpecs,
          domain
        )

        return(dfMapped)
      }
    )

  names(lMappedData) <- paste(strDomain, names(lMappedData), sep = "_")

  return(lMappedData)
}
