library(yaml)
library(jsonlite)








unzipFiles<- function(){
  
  config <- yaml.load_file("resources/config.yml")
  zipFile = config$data$zipFile
  
  
  
  unzip(zipFile,exdir = "input")
  unlink(zipFile)

}


