# combines study completion data, overall response data, and death data to output a dataframe containing pd date and death status.

combines study completion data, overall response data, and death data to
output a dataframe containing pd date and death status.

## Usage

``` r
complete_death(
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
)
```

## Arguments

- dfDeath:

  `data.frame` death data frame with mapped names

- dfStudyCompletion:

  `data.frame` study completion data frame with mapped names

- dfOverallResponse:

  `data.frame` overall response data frame with mapped names

- dfRandomization:

  `data.frame` randomization data frame with mapped names

- chrDeathDateCol:

  `character` name of column in `dfDeath` that contains the death date.
  Default: `"death_dt"`.

- chrStudyDiscontinuationReasonCol:

  `character` name of column in `dfStudyCompletion` that contains the
  reason for study completion. Default: `"compreas"`.

- chrDeathResponse:

  `character` value of `compreas` in `dfStudyCompletion` that indicates
  death. Default is "Death"

- chrResponseCol:

  `character` name of column in `dfOverallResponse` that contains the
  overall response. Default: `"ovrlresp"`.

- chrPDResponse:

  `character` value of `ovrlresp` in `dfOverallResponse` that indicates
  PD. Default is "PD"

- chrResponseDateCol:

  `character` name of column in `dfOverallResponse` that contains the
  overall response date. Default: `"rs_dt"`.

- chrRandomizationDateCol:

  `character` name of column in `dfRandomization` that contains the
  randomization date. Default: `"rgmn_dt"`.

## Value

a `data.frame` combining death status and first PD status

## Examples

``` r
if (FALSE) { # \dontrun{
lSource <- list(
  Source_OverallResponse = gsm.endpoints::lSource_ep$Raw_OverallResponse, ## Overall response
  Source_Death = gsm.endpoints::lSource_ep$Raw_Death, ## Death date
  Source_STUDCOMP = gsm.endpoints::lSource_ep$Raw_STUDCOMP
)

lMapping <- workr::MakeWorkflowList(
  strPath = "workflow/1_mappings",
  strNames = c("Death", "OverallResponse", "STUDCOMP"),
  strPackage = "gsm.mapping"
)

combined_spec <- gsm.mapping::CombineSpecs(lMapping)

lRaw <- gsm.mapping::Ingest(lSourceData = lSource, lSpec = combined_spec)

complete_death(
  dfDeath = lRaw$Raw_Death,
  dfStudyCompletion = lRaw$Raw_STUDCOMP,
  dfOverallResponse = lRaw$Raw_OverallResponse
)
} # }
```
