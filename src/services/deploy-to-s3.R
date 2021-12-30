library("aws.s3")

uploadHtmlFile<- function(){
  put_object(file = "SlackReports.html", object = "index.html", Sys.getenv("ZQSD_REPORT_AWS_BUCKET_NAME"))
}
