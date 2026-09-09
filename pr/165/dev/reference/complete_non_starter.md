# Classify IP non-starter status per enrolled subject

Joins the mapped subject, study-drug-completion and study-completion
frames to classify each enrolled subject's IP non-starter status.
`Mapped_SUBJ` is already filtered to `enrollyn == 'Y'`, so every row is
an enrolled subject.

## Usage

``` r
complete_non_starter(
  dfSubjects,
  dfStudyDrugCompletion,
  dfStudyCompletion,
  nWindowDays = 30,
  chrNeverDosedReason = "Subject Never Dosed with Study Drug"
)
```

## Arguments

- dfSubjects:

  `Mapped_SUBJ`:
  `studyid, subjid, invid, country, firstdosedate, timeonstudy`.

- dfStudyDrugCompletion:

  `Mapped_SDRGCOMP`: `studyid, subjid, sdrgreas`.

- dfStudyCompletion:

  `Mapped_STUDCOMP`: `studyid, subjid, compreas`.

- nWindowDays:

  `integer` window in days separating the two potential statuses;
  default `30`.

- chrNeverDosedReason:

  `character` coded `sdrgreas` value marking a confirmed non-starter,
  matched ignoring case; default
  `"Subject Never Dosed with Study Drug"`.

## Value

a `data.frame` with one row per enrolled subject and columns
`studyid, subjid, invid, country, dosed, nonstarter_status, confirmed_nonstarter`.

## Details

A subject is a **confirmed** non-starter when they are enrolled, not
dosed (`firstdosedate` is `NA` or blank) and have either a non-blank
study-completion reason (`compreas`) or the coded study-drug-completion
reason (`sdrgreas` matching `chrNeverDosedReason`, compared
case-insensitively).

`nonstarter_status` is assigned by explicit predicate: `"Started"` when
dosed, `"Confirmed"` when a confirmed non-starter, `"Potential-within"`
/ `"Potential-outside"` for the remaining subjects whose `timeonstudy`
falls at or below vs. above `nWindowDays`, and `NA` when none apply
(e.g. `timeonstudy` is missing so the window cannot be evaluated).

## Examples

``` r
if (FALSE) { # \dontrun{
lMapping <- workr::MakeWorkflowList(
  strPath = "workflow/1_mappings",
  strNames = c("SUBJ", "SDRGCOMP", "STUDCOMP"),
  strPackage = "gsm.mapping"
)
lRaw <- gsm.mapping::Ingest(lSource, gsm.mapping::CombineSpecs(lMapping))
mapped <- workr::RunWorkflows(lMapping, lRaw)
complete_non_starter(
  dfSubjects = mapped$Mapped_SUBJ,
  dfStudyDrugCompletion = mapped$Mapped_SDRGCOMP,
  dfStudyCompletion = mapped$Mapped_STUDCOMP
)
} # }
```
