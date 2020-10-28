# install.packages('RPostgres')
# install.packages('future')
# install.packages('promises')
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
# install.packages('DBI')

#load librarys
library(RPostgres)
library(future)
library(promises)
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
library(DBI)


#load file of config
source('config.R')

selectGeometrys <- function(flag){
  
   dataset <- NULL
   
   tryCatch({
      
     #open connection with postgres
     con <-  dbConnect(
       RPostgres::Postgres(),
       dbname   =  db.name,
       host     =  db.host,
       port     =  db.port,
       user     =  db.user,
       password =  db.password)
     
     status <- dbIsValid(con)
     print(paste0('Connection is open ',status ))
     
     #connection is off
     if(!status){
       return(NULL)
     }
     
     sql     <- paste0("select * from sgpa_map.fnc_get_pipeline_agrupar_geom('",flag,"');")
     print(paste0('Run query: ',sql))
     
     dataset <- dbGetQuery(con,sql)
     
     DBI::dbDisconnect(con)

   })
   
   return(dataset)
}

updateGeomtrys <- function(dataset){

  cl <- makeCluster(cores)
  registerDoParallel(cl)
  
  # Defining packages and variables for cluster
  clusterEvalQ(cl, {
    
    library(RPostgres)
    library(parallel)
    library(doParallel)
    library(DBI)
    #load file of config
    source('config.R')
    
    #open connection with postgres
    conn <-  dbConnect(
      RPostgres::Postgres(),
      dbname   =  db.name,
      host     =  db.host,
      port     =  db.port,
      user     =  db.user,
      password =  db.password)
    
  })
  
  foreach(
    i = 1:nrow(dataset),
    .combine  = 'c',
    .inorder  = F,
    .packages = c("sf", "rgeos","wellknown","RPostgres")) %dopar%{
      
      cd_id        <- dataset$cd_id[i]
      polygon      <- dataset$array_geoms[i]
      
      if(!is.null(polygon))
      {
        DBI::dbExecute(conn,paste0("call sgpa_map.prc_mapa_agrupado_nivel_set_geom(",cd_id,",'",polygon,"');"))
      }
      NULL
      
    }# end foreach
  
  #Closing connection in all clusters
  clusterEvalQ(cl, {
    dbDisconnect(conn)
  })
  
  # Stopping cluster
  stopCluster(cl)
  stopImplicitCluster()
  
  return(invisible(NULL))
}

processGeomtryUnion <- function(dataset){
  
  if(nrow(dataset) == 0) return(dataset)
  
  cl <- makeCluster(cores)

  registerDoParallel(cl)
  
  dataset$array_geoms <- foreach(
     i = 1:nrow(dataset),
    .combine  = 'c',
    .inorder  = F,
    .packages = c("sf", "rgeos","wellknown")) %dopar%{
    
    geometry     <- dataset$array_geoms[i]
    
    if(!is.na(geometry)){
      
      geometryUnion  <- st_union(st_cast(st_as_sf(readWKT(wkb_wkt(geometry))),to = 'POLYGON'))
      toupper(paste0(st_as_binary(geometryUnion)[[1]],collapse = ''))
      
    }else{ NULL }

  }# end foreach
  
  # Stopping cluster
  stopCluster(cl)
  stopImplicitCluster()

  return(dataset)
}

#Run Main
repeat({
  
  time.begin <- Sys.time()
  index      <- 1
  
  while(index <= length(flags)){
    
    flag <- flags[index]
  
    print('Loading geometrys ...')
    dataset <- selectGeometrys(flag)
    
    if(!is.null(dataset))
    {
      begin.time <-  Sys.time()
      
      print(paste0('Process start geomtry at ',begin.time))
      
      #process geomtry
      dataset <- processGeomtryUnion(dataset)
      
      end.time <- Sys.time()
      
      print(paste0('Process end geomtry at ',end.time))
      print(paste0('Elapsed time: ',(end.time - begin.time),' secunds'))
      
      if(nrow(dataset) == 0)
      {
        print('No records found!')
      }
      else
      { 
        updateGeomtrys(dataset)
        rm(dataset)  #clear all the matrix
        index <- index + 1
      }
      else{
        
        index <- index - 1
        index <- ifelse(index < 1,1,index)
        
      }

    }
    
    gc(verbose = FALSE)
  
  }# end while
  
  print(paste0('Elapsed time total: ',(Sys.time() - time.begin),' secunds'))
  print(paste0('Service is sleeping ... by ',(db.timeout / 1000)))
  #sleep by time
  Sys.sleep(db.timeout / 1000)

})
