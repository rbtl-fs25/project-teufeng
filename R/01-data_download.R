library(tidyverse)
library(googlesheets4)

#download google sheet
responses <- read_sheet("https://docs.google.com/spreadsheets/d/1bk-Md8azi3InXizjREE6KnyCvO_tuHsU6gGm66BCJHg/edit?usp=sharing")

# save raw data as CSV
write_csv(responses, "data/raw/battery_recycling_incentive_survey.csv")
