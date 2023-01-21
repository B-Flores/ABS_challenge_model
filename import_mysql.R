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

TYPES2 <- list(game_pk = "Int(10)", 
               game_date = "Date",
               index = "Int(10)", 
               is_pitch = "Boolean", 
               type = "varchar(100)", 
               pitch_number = "Int(10)", 
               details_description = "varchar(100)", 
               details_event = "varchar(100)",
               details_away_score = "Int(10)", 
               details_home_score = "Int(10)",
               details_is_scoring_play = "Boolean", 
               details_has_review = "Boolean",
               details_code = "varchar(4)", 
               details_ball_color = "varchar(100)",
               details_is_in_play = "Boolean", 
               details_is_strike = "Boolean",
               details_is_ball = "Boolean",
               details_call_description = "varchar(100)", 
               count_balls_start = "Int(10)",
               count_strikes_start = "Int(10)", 
               count_outs_start = "Int(10)",
               player_id = "Int(10)", 
               player_link = "varchar(100)", 
               pitch_data_strike_zone_top = "double(6,4)", 
               pitch_data_strike_zone_bottom = "double(6,4)",
               pitch_data_coordinates_x = "double(10,4)",
               pitch_data_coordinates_y = "double(10,4)",
               hit_data_trajectory = "varchar(100)", 
               hit_data_hardness = "varchar(100)",
               hit_data_location = "Int(10)", 
               hit_data_coordinates_coord_x = "double(10,4)",
               hit_data_coordinates_coord_y = "double(10,4)",
               details_event_type = "varchar(100)",
               details_runner_going = "boolean",
               position_code = "Int(10)", 
               position_name = "varchar(100)",
               position_type = "varchar(100)", 
               position_abbreviation = "varchar(100)", 
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
               batted_ball_result = "varchar(100)", 
               home_team = "varchar(100)", 
               home_level_id = "Int(10)",
               home_level_name = "varchar(100)", 
               home_parent_org_id = "Int(10)",
               home_parent_org_name = "varchar(100)", 
               home_league_id = "Int(10)",
               home_league_name = "varchar(100)", 
               away_team = "varchar(100)",
               away_level_id = "Int(10)", 
               away_level_name = "varchar(100)",
               away_parent_org_id = "Int(10)", 
               away_parent_org_name = "varchar(100)",
               away_league_id = "Int(10)", 
               away_league_name = "varchar(100)",
               batting_team = "varchar(100)", 
               fielding_team = "varchar(100)", 
               pfx_id = "varchar(100)",
               details_trail_color = "varchar(100)", 
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
               hit_data_launch_speed = "double(10,4)",
               hit_data_launch_angle = "double(10,4)",
               hit_data_total_distance = "double(10,4)",
               injury_type = "varchar(100)",
               umpire_id = "varchar(100)",
               umpire_link = "varchar(100)",
               details_is_out = "boolean",
               is_base_running_play = "boolean",
               is_substitution = "boolean",
               result_is_out = "boolean",
               about_is_top_inning = "boolean",
               matchup_post_on_first_id = "Int(10)",
               matchup_post_on_first_full_name = "varchar(100)",
               matchup_post_on_first_link = "varchar(100)",
               matchup_post_on_second_id = "Int(10)",
               matchup_post_on_second_full_name = "varchar(100)",
               matchup_post_on_second_link = "varchar(100)",
               matchup_post_on_third_id = "Int(10)",
               matchup_post_on_third_full_name = "varchar(100)",
               matchup_post_on_third_link = "varchar(100)")


###########################################################################################
#################       Import Play By Play Data With mlb_pbp()      ######################
###########################################################################################
not_included <- c("start_time", "end_time", "play_id", "details_call_code", "details_from_catcher", 
                  "action_play_id", "batting_order", "result_description", "about_end_time",
                  "about_start_time", "replaced_player_id", "replaced_player_link",
                  "last_pitch_of_ab")

game_packs <- tbl(src = con, "game_packs") %>%
  select(game_pk) %>%
  collect()
game_packs <- as_vector(game_packs)

pbp_init <- as_tibble(mlb_pbp(game_pk = game_packs[1])) %>%
  clean_names() %>%
  filter(type == "pitch") %>%
  select(-all_of(not_included)) 
  
pbp_init$at_bat_index <- as.numeric(pbp_init$at_bat_index)
pbp_init$pitch_number <- as.numeric(pbp_init$pitch_number)

pbp_init <- pbp_init %>%
  arrange(at_bat_index, pitch_number)

dbWriteTable(con, name = "pbp", value = pbp_init,
             field.types = TYPES2, row.names = FALSE, overwrite = TRUE)


write_pbp <- function(){

}




  
  








