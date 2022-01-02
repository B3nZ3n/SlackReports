# Slack report

## Pre-requisites

* Slack's export must be located in `data/export.zip`
* Environment variables required to deploy:
  * `ZQSD_REPORT_AWS_BUCKET_NAME`
  * `ZQSD_REPORT_AWS_BUCKET_REGION`
  * `ZQSD_REPORT_AWS_CLIENT_ID`
  * `ZQSD_REPORT_AWS_SECRET_KEY`


## Build Docker image

This must be executed every time an R library is added to the project.

```
$ docker build -t zqsd/report .
```

## Run bash in development

From the project folder:

```
$ docker run --rm -ti --name zqsd-report \
  -e ZQSD_REPORT_MUST_UNZIP=true \
  -v `pwd`/data/export.zip:/data/export.zip:ro \
  -v `pwd`/src:/app \
  zqsd/report bash
```

## Build report 

From the project folder:

```
$ docker run --rm --name zqsd-report \
  -e ZQSD_REPORT_MUST_UNZIP=true \
  -v `pwd`/data/export.zip:/data/export.zip:ro \
  -v `pwd`/src:/app \
  zqsd/report
```

## Build and deploy

```
$ docker run --rm --name zqsd-report \
  -e ZQSD_REPORT_MUST_UNZIP=true \
  -e ZQSD_REPORT_MUST_DEPLOY=true \
  -e ZQSD_REPORT_AWS_BUCKET_NAME=$ZQSD_REPORT_AWS_BUCKET_NAME \
  -e AWS_DEFAULT_REGION=$ZQSD_REPORT_AWS_BUCKET_REGION \
  -e AWS_ACCESS_KEY_ID=$ZQSD_REPORT_AWS_CLIENT_ID \
  -e AWS_SECRET_ACCESS_KEY=$ZQSD_REPORT_AWS_SECRET_KEY \
  -v `pwd`/data/export.zip:/data/export.zip:ro \
  -v `pwd`/src:/app \
  zqsd/report
```