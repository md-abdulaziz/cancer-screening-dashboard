library(tidyverse); library(janitor); library(DBI)

raw <- read_csv("data/raw/screening_raw.csv") %>% clean_names()

# Look at missing values BEFORE removing anything
raw %>% summarise(across(everything(), ~ mean(is.na(.)))) %>% glimpse()

clean <- raw %>%
  transmute(
    screening = case_when(
      indicator == 3620 ~ "Cervical (Pap)",
      indicator == 3621 ~ "Breast (mammography)",
      indicator == 6103 ~ "Colorectal"),
    year,
    region = region_title_fi,
    region_code,
    rate = primary_value,
    absolute_value
  ) %>%
  filter(!is.na(rate))

cat("Rows before:", nrow(raw), " after:", nrow(clean), "\n")

write_csv(clean, "data/processed/clean_data.csv")

con <- dbConnect(RSQLite::SQLite(), "data/processed/screening.sqlite")
dbWriteTable(con, "screening", clean, overwrite = TRUE)
dbDisconnect(con)