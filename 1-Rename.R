library(tidyverse)
library(terra)
library(ncdf4)

NC_list = list.files(".", pattern = "\\.nc$")
for(NC in NC_list){
  data = sds(NC)
  names = names(data)
  longnames = longnames(data)
  
  data_changed = map(.x = names,
                     .f = function(n, data){
                       data_temp = data[[n]]
                       if(units(data_temp)[[1]] == "degC"){
                         units(data_temp) = "K"
                       }
                       data_temp
                     },
                     data = data) %>%
    `names<-`(names)
  data_changed = sds(data_changed$temp, 
                     data_changed$climate_p10, 
                     data_changed$climate_p50, 
                     data_changed$climate_p90, 
                     data_changed$climate_mean, 
                     data_changed$climate_sd, 
                     data_changed$diff, 
                     data_changed$cat)
  longnames(data_changed) = longnames
  writeCDF(x = data_changed,
           compression = 8,
           missval = -9999,
           filename = paste0("new_", NC),
           overwrite = TRUE)
}


old_NC_list = list.files(pattern = "^THW.*\\.nc$")
new_NC_list = list.files(pattern = "^new_THW.*\\.nc$")

OldInNew = paste0("new_", old_NC_list) %in% new_NC_list
file.remove(old_NC_list[OldInNew])
file.rename(from = new_NC_list,
            to = new_NC_list %>% str_remove("^new_"))
