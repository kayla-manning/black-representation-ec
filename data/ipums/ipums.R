# NOTE: To load data, you must download both the extract's data and the DDI
# and also set the working directory to the folder with these files (or change the path below).

# if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. It can be installed using the following command: install.packages('ipumsr')")
# 
# ddi <- read_ipums_ddi("data/ipums/usa_00008.xml")
# data <- read_ipums_micro(ddi)

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

# getting everything grouped by state... also I realized that 1980, 1990, 2000
# numbers do not make sense (it appears that they're a factor of 10 greater than
# they should be), so I am getting them all to the same baseline & then
# rescaling to the actual population count

old_race_counts <- data %>% 
  clean_names() %>%
  select(-c(age)) %>% 
  group_by(year, statefip, race) %>% 
  count() %>% 
  mutate(statefip = as_label(statefip),
         race = as_label(race)) %>% 
  rename(state = statefip) %>% 
  ungroup() %>% 
  mutate(n = case_when(year %in% c(1980, 1990, 2000) ~ n / 10 * 100,
                       TRUE ~ n * 100))

{
  # inferring data points for years not in the IPUMS data... race coding is
  # different starting at the turn of the century, so I have to store vectors for
  # each of these
  
  races <- unique(race_counts$race[race_counts$year == 1970])
  missing_years <- c(1971:1979, 1981:1989, 1991:1999)
  
  # creating table with extra years... 2004 numbers look very wrong when
  # compared to other years, so I am testing out what happens if I remove them
  # do linear interpolation on those too
  
  extra_race_counts <- tibble(year = rep(missing_years, each = length(state.name) * length(races)),
                              state = rep(state.name, each = 7, times = length(missing_years)),
                              race = rep(races, times = length(state.name) * length(missing_years)),
                              n = NA) %>% 
    bind_rows(old_race_counts) %>% 
    mutate(n = ifelse(year == 2004, NA, n))
  
  # using linear interpolation to approximate the counts for each race within each state/year
  
  race_counts <- extra_race_counts %>% 
    arrange(state, race, year) %>% 
    mutate(n = na.approx(n))
}

# dropping NA state values (which is just DC) & creating my black proportion
# columns for the main analysis

black_ipums <- race_counts %>% 
  filter(!str_detect(race, "major races")) %>% 
  mutate(race = ifelse(str_detect(race, "Black"), "black", "nonblack")) %>% 
  group_by(year, state, race) %>% 
  summarise(n = sum(n),
            .groups = "drop") %>% 
  pivot_wider(names_from = race, values_from = n) %>% 
  mutate(total_vap = black + nonblack,
         black_prop_vap = black / (black + nonblack),
         state = state.abb[match(state, state.name)]) %>% 
  select(year, state, black_prop_vap, black, total_vap) %>% 
  drop_na(state) %>% 
  ungroup()

# replacing the total VAP numbers for 2000 with what I read in from the pdf


{
  # 2000 data is wrong for Georgia, so I am not sure that i can trust it for other
  # states. because of that, I am reading the numbers in from this PDF
  
  dat <- tabulizer::extract_tables("https://www.eac.gov/sites/default/files/eac_assets/1/6/2000%20Voter%20Registration%20and%20Turnout%20by%20State.pdf",
                                   area = list(c(233.820958, 7.900537, 768.296910, 597.055877),
                                               c(22.147313, 7.900537, 369.644880, 582.944372 )))
  vap2000 <- do.call(rbind, dat) %>% 
    as_tibble() %>% 
    select(V1, V2) %>% 
    mutate(V2 = as.numeric(str_remove_all(V2, ",")),
           V1 = state.abb[match(V1, state.name)]) %>% 
    rename(state = V1, total_vap = V2) %>% 
    drop_na(state)
}

# using this data for 1980-2014

dat <- googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1or-N33CpOZYQ1UfZo0h8yGPSyz0Db-xjmZOXg3VJi-Q/edit#gid=1670431880") %>% 
  clean_names()

# unlisting the columns that I need & putting them in a tibble

vaps <- tibble(year = unlist(dat$x1),
       state = unlist(dat$state),
       total_vap = unlist(dat$x11)) %>% 
  mutate(year = as.numeric(year),
         total_vap = as.numeric(total_vap),
         state = state.abb[match(state, state.name)]) %>% 
  drop_na()

black_ipums <- black_ipums %>% 
  filter(year %in% seq(1976, 2016, by = 4))

# replacing all vap data from 1980 to 2014 with this data

for (i in 1:nrow(black_ipums)) {
  
  state <- black_ipums[i,]$state
  year <- black_ipums[i,]$year
  
  # replacing total_vap and updating black vap accordingly (proportion still
  # appears to be correct)
  
  if (year %in% 1980:2014) {
    black_ipums[i,]$total_vap <- vaps$total_vap[vaps$state == state & vaps$year == year]
    black_ipums[i,]$black <- black_ipums[i,]$black_prop_vap * black_ipums[i,]$total_vap
  }
}

# saving the data I use as CSV files so that I don't have to rerun this script
# (it takes a long time)

write_csv(black_ipums, "data/ipums/saved_data/black_ipums.csv")

