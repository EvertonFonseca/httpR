#install packages
# install.packages('future')
# install.packages('promises')
# install.packages('jsonlite')
# install.packages('ipc')
# install.packages('stringr')
# install.packages('sf')
# install.packages('snowfall')
# install.packages('wellknown')
# install.packages('foreach')
# install.packages('parallel')
# install.packages('doParallel')
# install.packages('raster')
# install.packages('geosphere')
# install.packages('rgeos')
# install.packages('plumber')


#load all packages
library(future)
library(promises)
library(jsonlite)
library(ipc)
library(stringr)
library(sf)
library(snowfall)
library(wellknown)
library(foreach)
library(parallel)
library(doParallel)
library(raster)
library(geosphere)
library(rgeos)
library(plumber)


#load file of config
source('config.R')

http.host <- ifelse(http.host == 'localhost','127.0.0.1')

#R working with multithreads
plan(multisession)

#Funcion union all polygone
processGeomtryUnion <- function(polygone){
  
  #transforma as dimensoes
  polygones   <- lapply(seq_along(polygone$geometry), function(i) {
    
    cd_id           <- polygone$cd_id[i]
    geometry        <- polygone$geometry[i]
    geometry.union  <- st_union(st_cast(st_as_sf(readWKT(wkb_wkt(geometry))),to  = 'POLYGON'))
    new.wkb         <- toupper(paste0(st_as_binary(geometry.union)[[1]],collapse = ''))

    list(cd_id = cd_id,geometry = new.wkb)
  })
  polygones
}

#Run Application
pr() %>%
  pr_post("/v1/union",function(req, res) {
    
    if (is.null(req$body)) return("No input")
     
     # Make a new Future
     future({
       
       json           <- req$body
       polygones      <- jsonlite::fromJSON(json)
       polygonesUnion <- processGeomtryUnion(polygones)
        
       # Submit a new json object response
       jsonlite::toJSON(polygonesUnion,auto_unbox = TRUE)
     },seed = TRUE)
    
  }) %>%
  pr_run(host = http.host,port = http.port)
