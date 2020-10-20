# ServiceGeometry
Esse serviço é resonsavel por executar servidor http, assim obtem o object WKB para unir a geometria dos multi polignos e retorno essa nova geometria da união para host

# Install R
https://www.r-project.org/

# Pacotes
install.packages('httr')
install.packages('future')
install.packages('promises')
install.packages('jsonlite')
install.packages('ipc')
install.packages('stringr')
install.packages('sf')
install.packages('snowfall')
install.packages('raster')
install.packages('geosphere')
install.packages('rgeos')

# Run Service
Rscript servidor.R
