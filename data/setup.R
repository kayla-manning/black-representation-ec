

# Scraping Electoral College edge data from FiveThirtyEight:
# https://fivethirtyeight.com/features/even-though-biden-won-republicans-enjoyed-the-largest-electoral-college-edge-in-70-years-will-that-last/

{
  library(tidyverse)
  library(rvest)
  library(janitor)
}

# getting and organizing the data from 538

{
  content <- read_html("https://fivethirtyeight.com/features/even-though-biden-won-republicans-enjoyed-the-largest-electoral-college-edge-in-70-years-will-that-last/")
  ec_edge <- html_table(content)
  ec_edge <- ec_edge[[1]] 
  
  ec_edge <- ec_edge %>% 
    clean_names() %>% 
    rename(nat_pv = national_popular_vote,
           tipping_state = tipping_point_state_s,
           tipping_margin = tipping_point_margin,
           ec_edge = electoral_college_edge)
  
  write_csv(ec_edge, "data/ec_edge.csv")
}

# getting NOMINATE data all organized

{
  nom <- read_csv("data/HSall_members.csv") %>% 
    select(congress, chamber, party_code, nominate_dim1, bioname) %>% 
    filter(congress >= 81)
  
  prez_parties <- nom %>% 
    filter(chamber == "President") %>% 
    mutate(prez_party = party_code) %>% 
    select(congress, prez_party, bioname, nominate_dim1)
  
  nom <- nom %>% 
    inner_join(prez_parties, by = "congress", suffix = c("_all", "_prez")) %>% 
    mutate(branch = ifelse(chamber == "President", "exec", "leg")) %>% 
    group_by(congress, branch) %>% 
    mutate(party_avg = mean(nominate_dim1_all, na.rm = TRUE)) %>% 
    rename(party = prez_party) %>% 
    mutate(party = case_when(party == 100 ~ "D",
                             party == 200 ~ "R",
                             TRUE ~ "other"),
           further = case_when(party == "D" ~ ifelse(nominate_dim1_prez < party_avg, TRUE, FALSE),
                               party == "R" ~ ifelse(nominate_dim1_prez > party_avg, TRUE, FALSE),
                               TRUE ~ NA)) %>% 
    filter(branch != "exec") %>% 
    select(-c(branch, bioname_all, nominate_dim1_all, chamber)) %>% 
    mutate(gap = abs(nominate_dim1_prez - party_avg)) %>% 
    distinct() %>% 
    mutate(year = congress + 1867 + (congress - 81))
  
  all_dat <- inner_join(ec_edge, nom, by = "year") %>% 
    select(year, nat_pv, ec_edge, bioname_prez, further, gap, party) %>% 
    rename(prez_party = party) %>% 
    separate(ec_edge, c("edge_party", "edge"), sep = "\\+") %>% 
    mutate(prez_edge = (prez_party == edge_party),
           edge = as.numeric(edge))
}




