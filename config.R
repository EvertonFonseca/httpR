
#Essas configurações pertece ao arquivo database.R
#Database connection postgres

# PG_DATABASE -> 'Nome do banco de dados'
# PG_HOST     -> 'host'
# PG_PORT     -> 'porta'
# PG_USER     -> 'usuario'
# PG_PASSWORD -> 'senha'
# PG_JOBS     -> 'quantas thread o serviço vai usar pra acelerar os calculos, nunca utilizar as threads mais do que o host possui'
# PG_SLEEP    -> 'quanto tempo o serviço vai entrar no modo sleep depois que processos as flags D, S, M, T'

db.name     = Sys.getenv(x = 'PG_DATABASE', unset = "", names = NA)
db.host     = Sys.getenv(x = 'PG_HOST', unset = "", names = NA)  
db.port     = as.integer(Sys.getenv(x = 'PG_PORT', unset = "", names = NA))  
db.user     = Sys.getenv(x = 'PG_USER', unset = "", names = NA)  
db.password = Sys.getenv(x = 'PG_PASSWORD', unset = "", names = NA)  
cores       = as.integer(Sys.getenv(x = 'PG_JOBS', unset = "", names = NA))
flags       = c('D','S','M','T')
#Timeout para cada tempo de operação deve ser executado
db.timeout  = as.integer(Sys.getenv(x = 'PG_SLEEP', unset = "", names = NA))

############################################################

#Essas configurações pertece ao arquivo servidor.R
#configurações para servidor
http.host   = 'localhost'
http.port   =  1504