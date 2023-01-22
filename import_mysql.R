source("start_env.R")

con <- dbConnect(odbc::odbc(), 
                 .connection_string = "Driver={MySQL ODBC 8.0 Unicode Driver};",
                 Server = "localhost", Database = "mlb",
                 UID = "root", PWD = key_get("DB_PWD"),
                 Port = 3306)

dbDisconnect(con)

###########################################################################################
###############     Import Game Packs Data With mlb_schedule()    #########################
###########################################################################################

# Initialize data table in mySQL with 2022 gamepacks
gamepks_init <- as_tibble(mlb_schedule(season = 2022)) %>%
  filter(series_description == "Regular Season") %>%
  select(game_pk, date, season, day_night, teams_away_team_id,
         teams_away_team_name, teams_home_team_id,
         teams_home_team_name, venue_id, venue_name)

TYPES = list(game_pk = "Int(10)",
             date = "date",
             season = "Int(4)",
             day_night = "varchar(5)",
             teams_away_team_id = "Int(5)",
             teams_away_team_name = "varchar(25)",
             teams_home_team_id = "Int(5)",
             teams_home_team_name = "varchar(25)",
             venue_id = "Int(5)",
             venue_name = "varchar(25)")

dbWriteTable(con, name = "game_packs", value = gamepks_init,
             field.types = TYPES, row.names = FALSE)

# Function to be iterated over each year of data
write_game_pks <- function(connect, year){
  gamepks <- as_tibble(mlb_schedule(season = year)) %>%
    filter(series_description == "Regular Season") %>%
    select(game_pk,date, season, day_night, teams_away_team_id,
           teams_away_team_name, teams_home_team_id,
           teams_home_team_name, venue_id, venue_name)
  
  dbWriteTable(conn = connect, name = "game_packs",
               value = gamepks, row.names = FALSE,
               append = TRUE)
}

years <- c(2013:2021)

for(y in years){
  write_game_pks(connect = con, year = y)
}

###########################################################################################
# field.types argument for mlb_pbp data
# inclusion of some columns varies from year to year
# these included fields should be in every year

TYPES2 <- list(game_pk = "Int(10)", 
               game_date = "Date",
               index = "Int(10)", 
               is_pitch = "Boolean", 
               type = "varchar(100)", 
               pitch_number = "Int(10)", 
               details_description = "varchar(100)",
               details_is_scoring_play = "Boolean",
               details_code = "varchar(4)",
               details_is_in_play = "Boolean", 
               details_is_strike = "Boolean",
               details_is_ball = "Boolean",
               details_call_description = "varchar(100)", 
               count_balls_start = "Int(10)",
               count_strikes_start = "Int(10)", 
               count_outs_start = "Int(10)", 
               pitch_data_strike_zone_top = "double(6,4)", 
               pitch_data_strike_zone_bottom = "double(6,4)",
               pitch_data_coordinates_x = "double(10,4)",
               pitch_data_coordinates_y = "double(10,4)",
               details_event_type = "varchar(100)",
               details_runner_going = "boolean", 
               at_bat_index = "Int(10)",
               result_type = "varchar(100)", 
               result_event = "varchar(100)",
               result_event_type = "varchar(100)",
               result_rbi = "Int(10)", 
               result_away_score = "Int(10)",
               result_home_score = "Int(10)", 
               about_at_bat_index = "Int(10)",
               about_half_inning = "varchar(100)", 
               about_inning = "Int(10)",
               about_is_complete = "boolean", 
               about_is_scoring_play = "boolean",
               about_has_review = "boolean", 
               about_has_out = "boolean",
               about_captivating_index = "Int(10)",
               count_balls_end = "Int(10)", 
               count_strikes_end = "Int(10)",
               count_outs_end = "Int(10)", 
               matchup_batter_id = "Int(10)",
               matchup_batter_full_name = "varchar(100)",
               matchup_batter_link = "varchar(100)", 
               matchup_bat_side_code = "varchar(100)",
               matchup_bat_side_description = "varchar(100)",
               matchup_pitcher_id = "Int(10)", 
               matchup_pitcher_full_name = "varchar(100)",
               matchup_pitcher_link = "varchar(100)", 
               matchup_pitch_hand_code = "varchar(100)",
               matchup_pitch_hand_description = "varchar(100)", 
               matchup_splits_batter = "varchar(100)",
               matchup_splits_pitcher = "varchar(100)", 
               matchup_splits_men_on_base = "varchar(100)", 
               home_team = "varchar(100)", 
               away_team = "varchar(100)",
               batting_team = "varchar(100)", 
               fielding_team = "varchar(100)", 
               details_type_code = "varchar(100)",
               details_type_description = "varchar(100)", 
               pitch_data_start_speed = "double(10,4)",
               pitch_data_end_speed = "double(10,4)", 
               pitch_data_zone = "Int(10)",
               pitch_data_type_confidence = "double(10,4)", 
               pitch_data_plate_time = "double(10,4)",
               pitch_data_extension = "double(10,4)", 
               pitch_data_coordinates_a_y = "double(10,4)",
               pitch_data_coordinates_a_z = "double(10,4)",
               pitch_data_coordinates_pfx_x = "double(10,4)",
               pitch_data_coordinates_pfx_z = "double(10,4)",
               pitch_data_coordinates_p_x = "double(10,4)",
               pitch_data_coordinates_p_z = "double(10,4)",
               pitch_data_coordinates_v_x0 = "double(10,4)",
               pitch_data_coordinates_v_y0 = "double(10,4)",
               pitch_data_coordinates_v_z0 = "double(10,4)",
               pitch_data_coordinates_x0 = "double(10,4)",
               pitch_data_coordinates_y0 = "double(10,4)",
               pitch_data_coordinates_z0 = "double(10,4)",
               pitch_data_coordinates_a_x = "double(10,4)",
               pitch_data_breaks_break_angle = "double(10,4)",
               pitch_data_breaks_break_length = "double(10,4)",
               pitch_data_breaks_break_y = "Int(10)",
               pitch_data_breaks_spin_rate = "Int(10)",
               pitch_data_breaks_spin_direction = "Int(10)",
               umpire_id = "varchar(100)",
               umpire_link = "varchar(100)")

included_cols <- c("game_pk", "game_date","index", "is_pitch", "type", "pitch_number", 
                   "details_description","details_is_scoring_play","details_code",
                   "details_is_in_play", "details_is_strike","details_is_ball",
                   "details_call_description", "count_balls_start","count_strikes_start", 
                   "count_outs_start", "pitch_data_strike_zone_top", 
                   "pitch_data_strike_zone_bottom","pitch_data_coordinates_x",
                   "pitch_data_coordinates_y","details_event_type","details_runner_going", 
                   "at_bat_index","result_type", "result_event","result_event_type",
                   "result_rbi","result_away_score","result_home_score",
                   "about_at_bat_index","about_half_inning","about_inning",
                   "about_is_complete", "about_is_scoring_play","about_has_review", 
                   "about_has_out","about_captivating_index","count_balls_end", 
                   "count_strikes_end","count_outs_end", "matchup_batter_id",
                   "matchup_batter_full_name","matchup_batter_link", "matchup_bat_side_code",
                   "matchup_bat_side_description","matchup_pitcher_id",
                   "matchup_pitcher_full_name","matchup_pitcher_link", 
                   "matchup_pitch_hand_code","matchup_pitch_hand_description", 
                   "matchup_splits_batter","matchup_splits_pitcher",
                   "matchup_splits_men_on_base", "home_team", "away_team","batting_team", 
                   "fielding_team", "details_type_code","details_type_description", 
                   "pitch_data_start_speed","pitch_data_end_speed", "pitch_data_zone",
                   "pitch_data_type_confidence", "pitch_data_plate_time",
                   "pitch_data_extension", "pitch_data_coordinates_a_y",
                   "pitch_data_coordinates_a_z","pitch_data_coordinates_pfx_x",
                   "pitch_data_coordinates_pfx_z","pitch_data_coordinates_p_x",
                   "pitch_data_coordinates_p_z","pitch_data_coordinates_v_x0",
                   "pitch_data_coordinates_v_y0","pitch_data_coordinates_v_z0",
                   "pitch_data_coordinates_x0","pitch_data_coordinates_y0",
                   "pitch_data_coordinates_z0","pitch_data_coordinates_a_x",
                   "pitch_data_breaks_break_angle","pitch_data_breaks_break_length",
                   "pitch_data_breaks_break_y","pitch_data_breaks_spin_rate",
                   "pitch_data_breaks_spin_direction","umpire_id","umpire_link")

###########################################################################################
#################       Import Play By Play Data With mlb_pbp()      ######################
###########################################################################################

# Initialize table in mysql (only column names)

game_packs <- tbl(src = con, "game_packs") %>%
  select(game_pk) %>%
  collect() %>%
  as_vector()

pbp_init <- as_tibble(mlb_pbp(game_pk = game_packs[1])) %>%
  clean_names() %>%
  filter(type == "pitch") %>%
  select(included_cols) %>%
  filter(game_pk != game_packs[1])
  

dbWriteTable(con, name = "pbp", value = pbp_init,
             field.types = TYPES2, row.names = FALSE)


# Function to write pbp data into mysql by year
# Arguments: y = season, mysql = con (database connection),
# na = list of variable not include (i.e "not_included")

write_pbp <- function(y, mysql){
  
  gp <- tbl(src = mysql, "game_packs") %>%
    filter(season == y) %>%
    select(game_pk) %>%
    collect() %>%
    as_vector()
    
    for(g in gp){
      
      pbp <- as_tibble(mlb_pbp(game_pk = g)) %>%
        clean_names() %>%
        filter(type == "pitch") %>%
        select(-all_of(na))
      
      pbp$at_bat_index <- as.numeric(pbp$at_bat_index)
      pbp$pitch_number <- as.numeric(pbp$pitch_number)
      pbp <- pbp %>%
        arrange(at_bat_index, pitch_number)
    
      dbWriteTable(conn = mysql, name = "pbp",
                  value = pbp, row.names = FALSE,
                  append = TRUE)
    }
}

write_pbp(y = 2013, mysql = con, na = not_included)






############################ TEST #####################################

gp <- tbl(src = con, "game_packs") %>%
  filter(season == 2013) %>%
  select(game_pk) %>%
  collect() %>%
  as_vector()

for(g in gp){
  
  pbp <- as_tibble(mlb_pbp(game_pk = g)) %>%
    clean_names() %>%
    filter(type == "pitch") %>%
    select(included_cols)
 
  pbp$at_bat_index <- as.numeric(pbp$at_bat_index)
  pbp$pitch_number <- as.numeric(pbp$pitch_number)
  pbp <- pbp %>%
    arrange(at_bat_index, pitch_number)
  
  dbWriteTable(conn = con, name = "pbp",
               value = pbp, row.names = FALSE,
               append = TRUE)
}  

##########################################################################################

##########################################################################################
################## Import umpire data using load_umpire_ids() ############################
##########################################################################################

umps <- as_tibble(load_umpire_ids())

TYPES3 <- list(
  id = "Int(10)",
  position = "varchar(5)",
  name = "varchar(25)",
  game_pk = "Int(10)",
  game_date = "Date")

dbWriteTable(con, name = "umpire", value = umps,
             field.types = TYPES3, row.names = FALSE)





