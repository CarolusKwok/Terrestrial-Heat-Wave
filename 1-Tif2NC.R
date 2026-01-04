library(tidyverse)
library(terra)
library(ncdf4)

TIF_list = list.files(".", pattern = "tif$")
TIF = TIF_list[[1]]
for(TIF in TIF_list){
  data = rast(x = TIF)
  time = names(data) %>% str_extract(pattern = "[0-9]{8}") %>% unique
  
  data_temp = names(data) %>% .[str_detect(string = ., pattern = "temp")] %>% data[[.]]
  data_P010 = names(data) %>% .[str_detect(string = ., pattern = "P010")] %>% data[[.]]
  data_P050 = names(data) %>% .[str_detect(string = ., pattern = "P050")] %>% data[[.]]
  data_P090 = names(data) %>% .[str_detect(string = ., pattern = "P090")] %>% data[[.]]
  data_MEAN = names(data) %>% .[str_detect(string = ., pattern = "MEAN")] %>% data[[.]]
  data_SD = names(data) %>% .[str_detect(string = ., pattern = "SD")] %>% data[[.]]
  data_DIFF = names(data) %>% .[str_detect(string = ., pattern = "DIFF")] %>% data[[.]]
  data_CAT = names(data) %>% .[str_detect(string = ., pattern = "CAT")] %>% data[[.]]
  
  data_temp = data_temp/1000+250
  data_P010 = data_P010/1000+250
  data_P050 = data_P050/1000+250
  data_P090 = data_P090/1000+250
  data_MEAN = data_MEAN/1000+250
  data_SD   = data_SD/10000
  data_DIFF = data_DIFF/10000
  data_CAT  = data_CAT/1000-50
  
  if(length(time) == length(names(data_temp)) & 
     length(time) == length(names(data_P010)) &
     length(time) == length(names(data_P050)) &
     length(time) == length(names(data_P090)) &
     length(time) == length(names(data_MEAN)) &
     length(time) == length(names(data_SD)) &
     length(time) == length(names(data_DIFF)) &
     length(time) == length(names(data_CAT))){
    
    names(data_temp) = time
    names(data_P010) = time
    names(data_P050) = time
    names(data_P090) = time
    names(data_MEAN) = time
    names(data_SD)   = time
    names(data_DIFF) = time
    names(data_CAT)  = time
    
    time = as.Date(time, "%Y%m%d")
    
    time(data_temp) = time
    time(data_P010) = time
    time(data_P050) = time
    time(data_P090) = time
    time(data_MEAN) = time
    time(data_SD) = time
    time(data_DIFF) = time
    time(data_CAT) = time
  } else {
    next
  }
  
  data = sds(data_temp, data_P010, data_P050, data_P090, data_MEAN, data_SD, data_DIFF, data_CAT)
  
  units(data) = c("degC", "degC", "degC", "degC", "degC", "degC", "degC", "Unitless")
  names(data) = c("temp", "climate_p10", "climate_p50", "climate_p90",
                  "climate_mean", "climate_sd", "diff", "cat")
  longnames(data) = c("Daily 2m-Air Temperature",
                      "Climatic 30-year 10th Percentile of temp",
                      "Climatic 30-year 50th Percentile of temp",
                      "Climatic 30-year 90th Percentile of temp",
                      "Climatic 30-year Mean of temp",
                      "Climatic 30-year Standard Deviation of temp",
                      "Absolute Difference between temp and climate_p90",
                      "Marine Heatwave Category (Further Filtering Required)")
  
  writeCDF(x = data,
           compression = 8,
           missval = -9999,
           filename = paste0(stringr::str_remove(TIF, pattern = "\\.tif$"),
                             ".nc"),
           overwrite = TRUE)
}

TIF_list = list.files(".", pattern = "tif$") 
NC_list = list.files(".", pattern = "nc$")
TIF_list_inNC = str_remove(string = TIF_list, "\\.tif$") %in% str_remove(NC_list, "\\.nc$")
file.remove(TIF_list[TIF_list_inNC])


