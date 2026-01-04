library(terra)
library(tidyverse)

NC_list = list.files(pattern = "\\.nc$")

times = map(.x = NC_list,
            .f = function(x){
              time = time(sds(x))
              time_1 = time[[1]]
              print(time_1)
              
              time_all_identical = map_lgl(.x = time,
                                           .f = function(x, y){
                                             identical(x, y)
                                           },
                                           y = time_1)
              if(!all(time_all_identical)){
                cli::cli_text("{x} does not have identical time values for all raster layers")
                next
              }
              cli::cli_text("{x} is good!")
              return(unique(time_1))
            }) %>%
  unlist() %>%
  as.Date()

Dates_Required = seq.Date(from = "2013-01-01", to = "2025-12-31")
Dates_Needed = Dates_Required[!Dates_Required %in% times]
Months_Needed = as.character(Dates_Needed) %>%
  str_remove("\\-[0-9]{2}$") %>%
  unique()

writeLines(Months_Needed, "Months_Needed.txt")
