if (!requireNamespace('pacman', quietly = TRUE)){
  install_ackages('pacman')
}
pacman::p_load(tidyverse, lubridate, janitor, 
               keyring, DBI, odbc, baseballr)

con <- dbConnect(odbc::odbc(), .connection_string = "Driver={MySQL ODBC 8.0 Unicode Driver};", 
                 Server = "localhost", Database = "mlb", UID = "root", PWD = key_get("DB_PWD"), 
                 Port = 3306)


###############################################################################################
############################### Import and Clean Function #####################################
###############################################################################################

import_clean <- function(mysql = con){
  
  df_raw <- tbl(src = mysql, "pbp") %>%
    select(game_pk, game_date, pitch_number,at_bat_index, about_half_inning,
           about_inning,matchup_batter_full_name,matchup_batter_id, details_code, 
           count_balls_start, count_strikes_start, count_outs_start, 
           pitch_data_coordinates_p_x, 
           pitch_data_coordinates_p_z, 
           pitch_data_strike_zone_top,
           pitch_data_strike_zone_bottom,
           matchup_bat_side_code, matchup_pitch_hand_code, result_event,
           result_description) %>%
    collect()
  
  # Calculates outcome variable -- Good Eye %
  df <- df_raw %>%
    mutate(abs_call = case_when(pitch_data_coordinates_p_x - 0.95 > 0 |
                                  -0.95 - pitch_data_coordinates_p_x > 0 |
                                  pitch_data_coordinates_p_z - pitch_data_strike_zone_top > 0 |
                                  pitch_data_strike_zone_bottom - pitch_data_coordinates_p_z > 0 ~ "ball",
                                TRUE ~ "strike")) %>%
    mutate(chall_opp = case_when((count_strikes_start == 2 & details_code == 'C')  |
                                   (count_balls_start == 3 & details_code == 'C') ~ 1,
                                 TRUE~0)) %>%
    mutate(good_eye = case_when((abs_call == "ball" & chall_opp == 1) ~ 1,
                                TRUE~0)) 
  
  ge_co_tots <- df %>%
    group_by(matchup_batter_id) %>%
    summarize(co_tot = sum(chall_opp),
              ge_tot = sum(good_eye)) 
  
  df <- df %>%
    left_join(ge_co_tots, by = "matchup_batter_id")
  
  good_eye_perc <- ge_co_tots %>%
    mutate(ge_perc = ge_tot/co_tot) %>%
    select(matchup_batter_id, ge_perc)
  
  
  df <- df %>%
    left_join(good_eye_perc, by = "matchup_batter_id")
  
  
  day_night <- 
    tbl(src = mysql, "game_packs") %>%
    select(game_pk, day_night) %>%
    distinct() %>%
    collect()
  
  dn2 <- day_night %>%
    group_by(game_pk) %>%
    summarise(count = n()) %>%
    filter(count > 1) %>%
    select(game_pk) %>%
    as_vector()
  
  dn3 <- day_night %>%
    filter(game_pk %in% dn2) 
  
  dn_final <- day_night %>%
    anti_join(dn3, by = "game_pk")
  
  umps <- 
    tbl(src = mysql, "umpire") %>%
    filter(position == "HP") %>%
    mutate(ump_name = name) %>%
    select(game_pk, ump_name) %>%
    distinct() %>%
    collect()
  
  u2 <- umps %>%
    group_by(game_pk) %>%
    summarise(count = n()) %>%
    filter(count > 1) %>%
    select(game_pk) %>%
    as_vector()
  
  u3 <- umps %>%
    filter(game_pk %in% u2)
  
  umps_final <- umps %>%
    anti_join(u3, by = "game_pk")
  
  
  final_df <- df %>%
    inner_join(dn_final, by = "game_pk") %>%
    inner_join(umps_final, by = "game_pk") 
  
  return(final_df)
} 

df %>%
  mutate(leadoff = case_when()) %>%
  mutate(man_on_first = case_when(),
         man_on_second = case_when(), 
         man_on_third = case_when())

start <- Sys.time()
df <- import_clean()
end <- Sys.time()
duration <- end - start
duration

dbDisconnect(con)
























###############################################################################################
##############################      Helper Functions      #####################################
###############################################################################################
class_of <- function(df0, year = 2022){
  # Players active in 2022  
  df0 %>%
    filter(year(game_date) == year) %>%
    select(matchup_batter_id) %>%
    distinct() %>%
    as_vector() -> df0
  return(df0)
}


# brewersID <- mlb_teams(season = 2023 ) %>%
#   filter(team_full_name == "Milwaukee Brewers") %>%
#   select(team_id)
# 
# brewCrew2023 <- mlb_rosters(team_id = brewersID, roster_type = "fullRoster")
# 
# batters <- brewCrew2023 %>%
#   filter(position_type != "Pitcher") %>%
#   select(person_full_name, person_id)


