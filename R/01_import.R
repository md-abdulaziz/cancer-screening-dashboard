library(tidyverse)
library(sotkanet)

ids <- c(3620, 3621, 6103)

raw <- GetDataSotkanet(indicators = ids, years = 2010:2024,
                       genders = "total", region.category = "KUNTA")

write_csv(raw, "data/raw/screening_raw.csv")
glimpse(raw)