# NOTE: To load data, you must download both the extract's data and the DDI
# and also set the working directory to the folder with these files (or change the path below).

if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. It can be installed using the following command: install.packages('ipumsr')")

ddi <- read_ipums_ddi("data/ipums/usa_00008.xml")
data <- read_ipums_micro(ddi)

# getting ready to clean the data

{
  library(maps)
  library(tidyverse)
  library(janitor)
  library(sjlabelled)
  library(readxl)
  library(zoo)
  map <- purrr::map
}

# getting everything grouped by state

race_counts <- data %>% 
  clean_names() %>%
  select(-c(age)) %>% 
  group_by(year, statefip, race) %>% 
  count() %>% 
  mutate(statefip = as_label(statefip),
         race = as_label(race)) %>% 
  rename(state = statefip) %>% 
  ungroup()

# dropping NA state values (which is just DC) & creating my black proportion
# columns for the main analysis

black_ipums_1 <- race_counts %>% 
  mutate(race = ifelse(str_detect(race, "Black"), "black", "nonblack")) %>% 
  group_by(year, state, race) %>% 
  summarise(n = sum(n)) %>% 
  pivot_wider(names_from = race, values_from = n) %>% 
  mutate(total_vap = black + nonblack,
         black_prop_vap = black / (black + nonblack),
         state = state.abb[match(state, state.name)]) %>% 
  select(year, state, black_prop_vap, black, total_vap) %>% 
  drop_na(state) %>% 
  ungroup()
  
# getting 2004 data since the ACS numbers seem very wrong... realized data is in
# thousands from the Census website (it's likely that's how it is with the ipums
# data too, but I will stick with the census data since I know that for a fact)

dat2004 <- read_excel("data/ipums/vap2004.xls", skip = 4) %>% 
  clean_names() %>% 
  select(state_sex_race_and_hispanic_origin,
         population_18_and_over) %>% 
  drop_na(state_sex_race_and_hispanic_origin) %>% 
  mutate(state = ifelse(!str_detect(state_sex_race_and_hispanic_origin, "[a-z]"),
                        state_sex_race_and_hispanic_origin,
                        NA),
         state = na.locf(state)) %>% 
  rename(cat = state_sex_race_and_hispanic_origin,
         vap = population_18_and_over) %>% 
  mutate(cat = str_remove_all(cat, fixed(".")),
         year = 2004) %>% 
  filter(cat != state,
         !cat %in% c("Male", "Female")) %>% 
  mutate(state = state.abb[match(str_to_title(state), state.name)],
         vap = as.numeric(vap) * 10) %>% 
  drop_na(state) %>% 
  ungroup()

# formatting 2004 data to match the black_ipums table

black_2004 <- dat2004 %>% 
  mutate(cat = case_when(str_detect(cat, "Black") ~ "black", 
                         cat == "Total" ~ "total_vap",
                         TRUE ~ "other")) %>% 
  filter(cat != "other") %>% 
  group_by(cat, state, year) %>% 
  summarise(vap = sum(vap),
            .groups = "drop") %>% 
  pivot_wider(names_from = cat, values_from = vap) %>% 
  mutate(black_prop_vap = black / total_vap) %>% 
  ungroup()

# replacing ipums 2004 data with this.... also I realized that 1980, 1990, 2000
# numbers do not make sense (it appears that they're a factor of 10 greater than
# they should be), so I am getting them all to the same baseline & then
# rescaling to the actual population count

black_ipums <- black_ipums_1 %>% 
  filter(year != 2004) %>% 
  bind_rows(black_2004) %>% 
  mutate(black = case_when(year %in% c(1980, 1990, 2000) ~ black / 10 * 100,
                           TRUE ~ black * 100),
         total_vap = case_when(year %in% c(1980, 1990, 2000) ~ total_vap / 10 * 100,
                           TRUE ~ total_vap * 100)) %>% 
  ungroup()

# saving the data I use as CSV files so that I don't have to rerun this script
# (it takes a long time)

write_csv(black_ipums, "data/ipums/saved_data/black_ipums.csv")
write_csv(race_counts, "data/ipums/saved_data/race_counts.csv")

