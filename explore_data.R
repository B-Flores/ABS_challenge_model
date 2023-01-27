source("import_clean.R")

df %>%
  filter(year(game_date) == 2022 & co_tot >= 250 & ge_perc >= 0.20) %>%
  mutate(full_name = factor(matchup_batter_full_name)) %>%
  group_by(full_name) %>%
  summarize(ge_perc = mean(ge_perc)) %>%
  mutate(Name = fct_reorder(full_name, ge_perc)) %>%
  ggplot(aes(x = Name, y = ge_perc, fill = Name)) +
    geom_col(show.legend = FALSE) +
    scale_y_continuous(labels = scales::percent_format()) +
    coord_flip() +
  ylab(label = "Good Eye %") +
  theme_minimal()


# Trying to visualize bad umps by the average ge_perc
# df %>% 
#   mutate(Umpire = factor(ump_name)) %>%
#   group_by(Umpire) %>%
#   summarize(be = mean(ge_perc)) %>%
#   mutate(Ump = fct_reorder(Umpire, be)) %>%
#   na.omit() %>%
#   ggplot(aes(x = Ump, y = be, fill = Ump)) +
#   geom_col(show.legend = FALSE) +
#   scale_y_continuous(labels = scales::percent_format()) +
#   coord_flip() +
#   ylab(label = "Bad Eye %") +
#   theme_minimal()


