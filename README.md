# Representation of Black Voters in the Electoral College
### Kayla Manning, Spring 2021

Does the Electoral College offer proportional representation for Black voters? This project contains the code and figures used to investigate that question.

## Background

Voting and representation rank as two of the most crucial elements of democracy, yet attempts to stifle Black voices and votes haunt the history of the United States. Voters determine leaders and leaders dictate policy, so silencing voters has severe consequences for representation. Although the days of outright voter suppression through mechanisms such as the Grandfather Clause and literacy tests have passed, Donald Trump’s popular vote loss and Electoral College victory in 2016 illustrated that some voters still carry more power than others. The distribution of voters across states determines whose votes carry the most electoral weight, and concentrations of various demographic groups vary across states. Given the nation’s history of voter suppression and the heterogeneity of state-level populations, the Electoral College could very well perpetuate the underrepresentation of historically marginalized groups. This raises the question, does the Electoral College offer proportional representation for Black voters? This analysis finds that the Electoral College underrepresents Black voters on a nationwide scale. However, Black voters do not receive over or underrepresentation in the states that decide the election.

## Important directories and files

- [final_report.docx](final_report.docx): This word document has the written report and the figures produced in the analysis file. If you only look at one file in this repository, this should be it.
- [analysis.Rmd](analysis.Rmd): This file contains the code used to produce the figures and the analyses included in the written work. If you wish to see the code and the output in a single, static document, you can clone this repository and knit this file to produce an HTML document.
- [data](data): This directory contains the data used in this analysis.
  + [ec_votes.csv](data/ec_votes.csv): This file, compiled with data from the Office of the Federal Register, contains the allocation of electoral votes in presidential elections from 1944-2020.
  + [state_elxn_returns](data/state_elxn_returns.csv): This file, downloaded from the MIT Election Data and Science Lab, contains the state-level presidential election returns in elections from 1976-2020. 
  + [ipums](data/ipums): This directory contains the data and scripts used to compile the Census data.
    - [ipums.R](data/ipums/ipums.R): This script reads in the original IPUMS data. The `.dat` and `.xml` files needed to run this script were too large for GitHub, so this script only exists to show my methods for cleaning and structuring the data into what I ultimately saved as [black_ipums.csv](data/black_ipums.csv). If you wish to run this script with the original files, email me at [kaylamanning@college.harvard.edu](kaylamanning@college.harvard.edu), and I can send the original files to you.
    - [black_ipums.csv](data/black_ipums.csv): This file contains the population data that I used for the analysis.
- [figures](figures): This directory contains saved images and HTML files of the tables and plots produced in [analysis.Rmd](analysis.Rmd) and included in [final_report.docx](final_report.docx).
