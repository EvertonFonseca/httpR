FROM r-base:4.0.3

WORKDIR /usr/src/app

# Bundle app source
COPY . .

RUN apt-get update
RUN yes | apt-get install build-essential software-properties-common libgdal-dev libgeos-dev libudunits2-dev libproj-dev libssl-dev libcurl4-openssl-dev libxml2-dev gnupg
RUN Rscript install_packages.R

CMD [ "Rscript", "/usr/src/app/servidor.R" ]
CMD ["sleep", "infinity"]

EXPOSE 1504