# Priority 1 mappings
# These upstream columns may be absent from older source snapshots.
disp_source_fields <- c(
  "drv_study_disposition",
  "drv_last_contact_dt",
  "drv_withdrawn_dt",
  "drv_death_dt",
  "drv_ae_death_dt",
  "rbqm_flags"
)

test_that("Qual: mappings now done by individual domain, test that inputs and outputs of priority 1 mappings are completed as expected (#97, #114, #128, #129, #169)", {
  priority1 <- c(
    "AE.yaml",
    "ENROLL.yaml",
    "LB.yaml",
    "PD.yaml",
    "SDRGCOMP.yaml",
    "STUDCOMP.yaml",
    "SUBJ.yaml",
    "OverallResponse.yaml",
    "Randomization.yaml"
  )

  mapped_p1_yaml <- map(
    priority1,
    ~ read_yaml(
      file.path(
        system.file(package = "gsm.mapping"),
        "workflow",
        "1_mappings",
        .x
      )
    )
  )

  # Required raw data is in data source
  iwalk(mapped_p1_yaml, ~ expect_true(all(names(.x$spec) %in% names(lData))))

  # Output from yaml is in the mapped data object
  iwalk(
    mapped_p1_yaml,
    ~ expect_true(flatten(.x$steps)$output %in% names(mapped_data))
  )

  # Needed columns of raw data are actually in raw data and retained in final data
  iwalk(
    mapped_p1_yaml,
    ~ {
      spec_cols <- names(flatten(.x$spec))
      source_cols <- names(lData[names(.x$spec)][[1]])
      mapped_cols <- names(mapped_data[[flatten(.x$steps)$output]])
      expected_cols <- union(
        setdiff(spec_cols, disp_source_fields),
        intersect(spec_cols, source_cols)
      )

      expect_true(all(expected_cols %in% source_cols))
      expect_true(all(expected_cols %in% mapped_cols))
    }
  )
})


# Priority 2 Mappings

test_that("Qual: mappings now done by individual domain, test that inputs and outputs of priority 2 mappings are completed as expected (#97, #114, #166, #169)", {
  priority2 <- c(
    "DATACHG.yaml",
    "DATAENT.yaml",
    "QUERY.yaml",
    "Death.yaml",
    "VS.yaml",
    "IPNS.yaml",
    "DISP.yaml"
  )

  mapped_p2_yaml <- map(
    priority2,
    ~ read_yaml(
      file.path(
        system.file(package = "gsm.mapping"),
        "workflow",
        "1_mappings",
        .x
      )
    )
  )

  iwalk(
    mapped_p2_yaml,
    ~ expect_true(all(
      names(.x$spec) %in%
        c(
          names(lData),
          "Mapped_SUBJ",
          "Mapped_Randomization",
          "Mapped_OverallResponse",
          "Mapped_STUDCOMP"
        )
    ))
  )

  iwalk(
    mapped_p2_yaml,
    ~ expect_true(flatten(.x$steps)$output %in% c(
      names(mapped_data),
      "Temp_SubjectLookup",
      "Temp_Death",
      "Temp_VS",
      "Mapped_DISP"
    ))
  )

  iwalk(
    mapped_p2_yaml,
    ~ expect_true(all(
      setdiff(names(flatten(.x$spec)), disp_source_fields) %in%
        c(
          names(lData[names(.x$spec)][[1]]),
          names(lData["Raw_SUBJ"][[1]]),
          names(lData["Raw_Randomization"][[1]]),
          names(lData["Raw_OverallResponse"][[1]]),
          names(lData["Raw_STUDCOMP"][[1]])
        )
    ))
  )
})

# Priority 3 Mappings

test_that("Qual: mappings now done by individual domain, test that inputs and outputs of priority 3 mappings are completed as expected (#97)", {
  priority3 <- c("COUNTRY.yaml", "SITE.yaml", "STUDY.yaml")

  mapped_p3_yaml <- map(
    priority3,
    ~ read_yaml(
      file.path(
        system.file(package = "gsm.mapping"),
        "workflow",
        "1_mappings",
        .x
      )
    )
  )

  iwalk(
    mapped_p3_yaml,
    ~ expect_true(all(names(.x$spec) %in% c(names(lData), "Mapped_SUBJ")))
  )

  temp_objs <- c(
    "Temp_CountryCountsWide",
    "Temp_CTMSSiteWide",
    "Temp_CTMSSite",
    "Temp_SiteCountsWide",
    "Temp_SiteCounts",
    "Temp_CTMSStudyWide",
    "Temp_CTMSStudy",
    "Temp_StudyCountsWide",
    "Temp_StudyCounts"
  )

  iwalk(
    mapped_p3_yaml,
    ~ expect_true(
      flatten(.x$steps)$output %in% c(names(mapped_data), temp_objs)
    )
  )

  iwalk(
    mapped_p3_yaml,
    ~ expect_true(all(
      names(flatten(.x$spec)) %in%
        c(names(lData[names(.x$spec)][[1]]), names(lData["Raw_SUBJ"][[1]]))
    ))
  )
})
