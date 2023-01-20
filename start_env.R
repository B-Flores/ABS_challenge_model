if (!requireNamespace('pacman', quietly = TRUE)){
  install_ackages('pacman')
}
pacman::p_load(tidyverse, lubridate, janitor, 
               keyring, DBI, RMySQL, baseballr)

con <- dbConnect(RMySQL::MySQL(),
                 dbname = "mlb",
                 host = "localhost",
                 port = 3306,
                 user = "root",
                 password = key_get("DB_PWD"))