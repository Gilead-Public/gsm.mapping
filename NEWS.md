# gsm.mapping (development version)

* Added the `IPNS` mapping, recoding `drv_ip_nonstarter_status` to an ordinal `ipns_status_ord` (0-3, `NA` for unrecognised statuses) (#162).

# gsm.mapping v1.1.6

This patch release removes the log4r package dependency, because the log4r package was archived on CRAN (#143, #113).

# gsm.mapping 1.1.5

This release migrates query execution and workflow discovery to the new `workr` package and includes mapping and documentation improvements.

**Changes:**
- Migrated `RunQuery()` and `MakeWorkflowList()` calls from `gsm.core` to the new `workr` package across `ApplySpec()`, the R functions, and all mapping workflow specs.
- Fixed `ApplySpec()` to quote SQL column identifiers, so source/target columns with special characters or reserved words map correctly.
- Added the `deathcls` field to the Death mapping (`Death.yaml`).
- Converted the Example Mapping Workflow article from `.R` to `.Rmd` for a richer, rendered walkthrough on the package site.

# gsm.mapping 1.1.4

This patch release updates the GitHub action workflows to align with the new federated action framework in `gsm.utils`


# gsm.mapping 1.1.3

This minor update includes new/updated domain mapping specs, improved mapping documentation, and expanded qualification/unit testing and CI workflows.

**Changes:**
- Added `complete_death()` to `gsm.mapping` and updated the Death workflow spec to use it (including calculating `death_dy` with `Randomization` data).
- Refreshed mapping-spec vignette to auto-discover YAML domains and render a richer, filterable mapping table.
- Added qualification/unit tests (including snapshots) and modernized GitHub Actions workflows (qcthat + new pkgdown workflow), alongside version bump/remotes update.

# gsm.mapping 1.1.2

This patch release adds `db_lock_dt` to spec of `STUDY.yaml` and makes wording/phrasing changes for `EXCLUSION.yaml`.

# gsm.mapping 1.1.1

This patch release adds new contributor guidelines and standardized issue templates. 

# gsm.mapping 1.1.0

## Notable Changes:

**New Mapping Workflows:**
A new workflow for inclusion/exclusion data has been added, denoted as 'IE'. PR [#69](https://github.com/Gilead-BioStats/gsm.mapping/pull/69)

**Other Updates:**
We have made small modifications to most mappings to include `studyid` and harmonize across other `gsm` ecosystem packages like `gsm.datasim`. PR [#73](https://github.com/Gilead-BioStats/gsm.mapping/pull/73)

# gsm.mapping 1.0.2

This patch release updates the description file to incorporate min version for `{gsm.core}`.

# gsm.mapping 1.0.1 

This patch release adds a new mapping yaml for PK Compliance data and updates the mappings for `gsm.endpoints` 

# gsm.mapping 1.0.0

We are excited to announce the first major release of the `gsm.mapping` package, which contains essential mapping-specific functions and workflows for the GSM (Good Statistical Modeling) pipeline. This release introduces significant improvements, new features, and bug fixes, all aimed at improving the ease of use and functionality for users working with data mapping in the GSM pipeline.

## Notable Changes:
**Namespaces in Function Calls:**
We have standardized the function calls in workflows by adding namespaces to enhance modularity and avoid potential conflicts. This change helps improve readability and maintainability.
PR [#32](https://github.com/Gilead-BioStats/gsm.mapping/pulls/32) 

**New Mapping Workflows:**
A set of new workflows for handling gsm.endpoints and PK mapping have been added, streamlining the process of managing and utilizing endpoints within the pipeline.
PR [#31](https://github.com/Gilead-BioStats/gsm.mapping/pulls/31) 

**Replacing `clindata` with `gsm.datasim`:**
Replaced `clindata` with `gsm.datasim`, improving the data simulation workflow.
PR [#41](https://github.com/Gilead-BioStats/gsm.mapping/pulls/41) 

**`gsm.core` Update:**
The package has been updated to use gsm.core instead of the previously used gsm, ensuring compatibility with the new modular approach to the gsm pipeline.
PR [#46](https://github.com/Gilead-BioStats/gsm.mapping/pulls/46)

**Vignette Updates:**
Several improvements were made to the documentation and vignettes, providing users with clearer and more informative examples for using the mapping workflows, as well as .
PR [#44](https://github.com/Gilead-BioStats/gsm.mapping/pulls/44)

## Other Updates:
- Minor bug fixes and performance enhancements across various modules of the package.
- Improved error handling and logging for better debugging and workflow tracking.

For detailed information on the changes, please refer to the individual pull requests linked above.
 

# gsm.mapping 0.0.2

This initial release migrates the mapping-specific functions, workflows and documentation from `{gsm}` to `{gsm.mapping}`.
