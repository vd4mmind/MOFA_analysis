# runs all Rmd files containing the analysis of the CLL data

rmarkdown::render("data_overview.Rmd")
rmarkdown::render("import_models.Rmd")
rmarkdown::render("MOFAfactors_overview.Rmd")
rmarkdown::render("Analysis_Factor1.Rmd")
rmarkdown::render("IGHVstatus.Rmd")
rmarkdown::render("survival.Rmd")
