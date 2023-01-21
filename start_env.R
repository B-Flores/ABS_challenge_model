if (!requireNamespace('pacman', quietly = TRUE)){
  install_ackages('pacman')
}
pacman::p_load(tidyverse, lubridate, janitor, 
               keyring, DBI, odbc, baseballr)



