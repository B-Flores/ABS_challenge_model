source("start_env.R")

###############################################################
mlb_games <- as_tibble(mlb_schedule(season = 2022)) %>%
  filter(series_description == "Regular Season") 

field_types <- list(colnames(mlb_games)) %>%
  list_tea
list

RMySQL::dbWriteTable(con, name = "mlb", value = mlb_games, 
             row.names = FALSE,
             types = 
             overwrite = TRUE)
  


# importData <- function(season , team){
#   
#   game_packs <- as_vector(mlb_schedule(season = season,
#                                        level_ids = "1") %>%
#                             filter(teams_home_team_name == team) %>%
#                             filter(date < "2022-09-29") %>%
#                             select(game_pk))
#   
#   # Upon comparing data from each ballpark, we should not include:
#   #   base, replacedPlayer.id, replacedPlayer.link
#   # also cleans column names using janitor package (turns "." into "_") 
#   
#   pbp <- map_df(game_packs, mlb_pbp) %>%
#     select(-base, -replacedPlayer.id, -replacedPlayer.link) %>%
#     clean_names()
#   
#   return(pbp)
#   
# }
# 
# import_and_store <- function(year, home_team){
#   temp <- as_tibble(importData(season = year, team = home_team))
#   
#   dbWriteTable(con, name = "data", value = temp, 
#                row.names = FALSE,
#                append = TRUE)
# }