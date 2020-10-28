# ServiceGeometry
Esse serviço é resonsavel por executar servidor http, assim obtem o object WKB para unir a geometria dos multi polignos e retorno essa nova geometria da união para host

# Install R
https://www.r-project.org/

# Pacotes
install.packages('RPostgres')
install.packages('future')
install.packages('promises')
install.packages('stringr')
install.packages('sf')
install.packages('snowfall')
install.packages('wellknown')
install.packages('foreach')
install.packages('parallel')
install.packages('doParallel')
install.packages('raster')
install.packages('geosphere')
install.packages('rgeos')
install.packages('DBI')

# Run Service
Rscript database.R
