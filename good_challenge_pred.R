source("import_clean.R")
library(tidymodels)

df %>%
  filter(co_tot >= 500 & ge_perc >= 0.20) %>%
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
  
  
