library(tidyverse)
d <- read_csv("data/processed/clean_data.csv")

# Trend over time (unweighted mean across municipalities)
trend <- d %>% group_by(screening, year) %>%
  summarise(mean_rate = mean(rate), median_rate = median(rate),
            sd = sd(rate), n_regions = n(), .groups = "drop")
print(trend, n = 50)

# Regional ranking, latest year per screening
latest <- d %>% group_by(screening) %>%
  filter(year == max(year)) %>%
  mutate(rank = min_rank(desc(rate))) %>% ungroup()
latest %>% arrange(screening, rank) %>% print(n = 15)

# Simple model: did participation change across the period?
m <- lm(rate ~ year + screening, data = d)
print(summary(m))

ggsave("figures/trend.png",
       ggplot(trend, aes(year, mean_rate, colour = screening)) +
         geom_line() + geom_point() + theme_minimal() +
         labs(x = "Year", y = "Participation (% of invited)",
              title = "Screening participation over time, Finnish municipalities"),
       width = 8, height = 5)