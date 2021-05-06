# Representation of Black Voters in the Electoral College
### Kayla Manning, Spring 2021

Does the Electoral College offer proportional representation for Black voters? This project contains the code and figures used to investigate that question.

## Background

Voting and representation rank as two of the most crucial elements of democracy, yet attempts to stifle Black voices and votes haunt the history of the United States. Voters determine leaders and leaders dictate policy, so silencing voters has severe consequences for representation. Although the days of outright voter suppression through mechanisms such as the Grandfather Clause and literacy tests have passed, Donald Trump’s popular vote loss and Electoral College victory in 2016 illustrated that some voters still carry more power than others. The distribution of voters across states determines whose votes carry the most electoral weight, and concentrations of various demographic groups vary across states. Given the nation’s history of voter suppression and the heterogeneity of state-level populations, the Electoral College could very well perpetuate the underrepresentation of historically marginalized groups. 

## Important directories and files

- [analysis.Rmd](analysis.Rmd): This file contains the code used to produce the figures and the analyses included in the written work. Knitting this document will produce `analysis.html`.
- [analysis.html](analysis.html): This file contains the code from `analysis.Rmd` and displays the output.
- [data](data): This directory contains the data used in this analysis.
  + [ec_votes.csv](data/ec_votes.csv): This file, compiled with data from the Office of the Federal Register, contains the allocation of electoral votes in presidential elections from 1944-2020.
  + [state_elxn_returns](data/state_elxn_returns.csv): This file, downloaded from the MIT Election Data and Science Lab, contains the state-level presidential election returns in elections from 1976-2020. 
  + [ipums](data/ipums): This directory contains the data and scripts used to compile the Census data.
    - [ipums.R](data/ipums/ipums.R): reads in the data with a script. The `.dat` and `.xml` files needed to run this script were too large for GitHub, so this script only exists to show my methods for cleaning and structuring the data. I saved separate `.csv` files with the data needed to run the code in this analysis.
    - [saved_data](data/ipums/saved_data): This directory contains `.csv` files of the Census data I needed for this analysis.
    - [vap2004.xls](data/ipums/vap2004.xls): This file contains data on the voting-age population in the United States in 2004. The units of measurement in the ACS data for this year did not seem accurate relative to the surrounding years, so I downloaded this file so that I could compare the data and get the same units of measurement across election years. 
