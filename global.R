# 1 - Librerias --------------------

paquetes <- list(
  "Shiny Core" = list("shiny", "shinydashboard"),
  "Shiny Extras" = list("shinyjs", "shinyWidgets", "shinydashboardPlus"),
  "Tidyverse" = list("tidyverse", "lubridate", "jsonlite", "httr"),
  "Encrypt" = list("digest", "sodium"),
  "Generales" = list("xts")
)
lapply(as.list(c(paquetes, recursive = T, use.names = F)), 
       function(x) {
         if (x %in% rownames(installed.packages()) == FALSE) {
           install.packages(x, verbose = F)
         }
         library(x, character.only = T, verbose = F)
       })
rm(list = c("paquetes"))

# 2 - Modules --------------------

invisible(lapply(list.files(path = "modules", full.names = T), source))