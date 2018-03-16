# runs all Rmd files containing the analysis of the CLL data

rmarkdown::render("data_overview.Rmd")
rmarkdown::render("import_models.Rmd")
rmarkdown::render("MOFAfactors_overview.Rmd")
rmarkdown::render("Factor1.Rmd")
rmarkdown::render("IGHVstatus.Rmd")
rmarkdown::render("Factor3.Rmd")
rmarkdown::render("Factor4.Rmd")
rmarkdown::render("Factor8.Rmd")
rmarkdown::render("survival.Rmd")
