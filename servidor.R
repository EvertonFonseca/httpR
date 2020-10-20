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

#var global
interruptor <- NULL
syscronize  <- NULL

#Create function output
printf <- function(...){ print(paste0(...))}

# Create function service
openService <- function(callback){
  
  if(!is.null(interruptor)) return(invisible(NULL))
  
  interruptor <<- ipc::AsyncInterruptor$new()
  syscronize  <<- ipc::queue()
  syscronize$consumer$start(100)
  
  #neutro function
  futuroFunction <- function(x){callback(x)}
  
  config  <- fromJSON('config.json')
  
  printf("Http url: ",config$url)
  
  #make new future
  future({
    message   <- ''
    running   <- TRUE
    
    repeat({
      
      if(!running)
          break
      
       tryCatch({
       
        request <- httr::GET(str_trim(config$url),accept('text/plain'))
        wkb     <- content(request, "text")
        
        #send request to callback
        syscronize$producer$fireCall(name = 'futuroFunction',list(url = config$url,wkb = wkb,time = Sys.time()))
        
        #check if service was stoped
        interruptor$execInterrupts()
        
      },error = function(e){
        running <<- FALSE
        message <<- e
      })
      
    })
    #print message
    message })%...>%(function(x) printf(x))
  
  return(invisible(NULL))
}

# Create function stop service
stopService <- function(){
  
  if(is.null(interruptor)) return(invisible(NULL))
  
  #stop
  interruptor$interrupt('Service was stopped with success!')
  syscronize$consumer$stop()
  syscronize$destroy()
  
  interruptor <<- NULL
  syscronize  <<- NULL
  
  return(invisible(NULL))
}

# Run service
openService(function(obj){ # callback request
  
  #make new future
  future({
    
    geometry.union <- st_union(st_cast(st_as_sf(readWKT(wkb_wkt(obj$wkb))),to = 'POLYGON'))
    new.wkb        <- toupper(paste0(st_as_binary(geometry.union),collapse = ''))
    #Send new object WKB UNION
    httr::POST(obj$url,accept('text/plain'),body = new.wkb)
    
  })
  
})

