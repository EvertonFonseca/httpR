#load all packages
library(httr)
library(future)
library(promises)
library(jsonlite)
library(ipc)
library(stringr)
library(sf)
library(snowfall)
library(raster)
library(geosphere)
library(rgeos)

#R working with multithreads
plan(multisession)

#Create function output
printf <- function(...){ print(paste0(...))}

server <- function(){
  
  config  <- fromJSON('config.json')
  
  while(TRUE){
    
    printf("Listening...")
    
    con    <- socketConnection(host=config$host, port = config$port, blocking=TRUE,server=TRUE, open="r+")
    bytes  <- readLines(con,1)
    
    while(length(bytes) != 0)
    { 
      #make new future
      future({
        
        geometry.union <- st_union(st_cast(st_as_sf(readWKT(wkb_wkt(bytes))),to = 'POLYGON'))
        new.wkb        <- toupper(paste0(st_as_binary(geometry.union),collapse = ''))
        #Send new object WKB UNION
        writeLines(new.wkb,con)
        
      })
      
      bytes <- readLines(con,n = 1)
    }
    close(con)
  }
}

server()
