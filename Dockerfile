FROM r-base:4.1.2

RUN mkdir -p /app/services && \
  mkdir /input && \
  apt-get update && apt-get install -y unzip pandoc libssl-dev curl libcurl4-openssl-dev libxml2-dev

ADD src/services/install-packages.R /app/services/install-packages.R 

WORKDIR /app

RUN ["Rscript", "services/install-packages.R"]

ADD src /app

CMD R -e 'rmarkdown::render("SlackReports.Rmd", "html_document")'