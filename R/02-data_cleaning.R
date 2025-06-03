library(tidyverse)
library(googlesheets4)
library(lubridate)

#read data from csv
responses <- read_csv("data/raw/battery_recycling_incentive_survey.csv") 

#data tidying ------------------------------------------

# #delete/remove a column
# responses <- responses |> 
#   select(-Timestamp)  

#make an id col
tidydata <- responses |> 
  mutate(id = seq(1:n()),
         .before = `Timestamp`) 

#rename test
tidydata <- tidydata |> 
  rename("age" = `What is your age?`)

#all other renames
tidydata <- tidydata |> 
  rename("gender" = `What is your gender`, 
         "education_level" = `What your highest completed level of your education?`,
         "environmental_responsibility" = `How important is environmental responsibility to you`,
         "returns_count" = `How many times have you returned portable batteries in the last 6 months?`,
         "disposal_location" = `Where do you mostly dispose of used batteries?`,
         "disposal_distance" = `How far do you have to walk to return batteries in meters?`,
         "injury_estimate" = `Risk to Human Life and Injury`,
         "infrastructure_damage_estimate" = `Major Property and Infrastructure Damage`,
         "pollution_estimate" = `Environmental Pollution`,
         "fin_losses_estimate" = `Severe Financial Losses`,
         "material_losses_estimate" = `Loss of raw material`)

#rename some more       
tidydata <- tidydata |> 
  rename("deposit_incentive_rating" = `Introducing a deposit of CHF 0.50 per battery.`,
         "distance_incentive_rating" = `Halving the distance to your next collection point.`,
         "education_incentive_rating" = `Education campaigns about the consequences of improper disposal.`,
         "removable_incentive_rating" = `Batteries can be removed from all devices without tools.`,
         "battery_fires_knowledge" = `Did you know that improper battery recycling causes increasingly more fires in waste facilities each year?`,
         "has_read_fire_text" = `Have you read the text in the description?`,
         "second_education_rating_after_reading" = `Rate the likelihood of an Education campaign with this information increasing your motivation to recycle.`) 

#education level tidy       
tidydata <- tidydata |> 
  mutate(education_level = str_remove(education_level, "Level")) |> 
  mutate(education_level = as.numeric(education_level))

#date, time, weekday conversion to seperate cols
tidydata <- tidydata |> 
  mutate(date = as_date(Timestamp)) |> 
  mutate(time = format(Timestamp, "%H:%M:%S")) |> 
  mutate(weekday = wday(Timestamp, label = TRUE, abb = FALSE)) |> 
  relocate(weekday) |> 
  relocate(time) |> 
  relocate(date) |> 
  select(!Timestamp) # remove old timestamp variable

#save wide version
tidydata_wide <- tidydata 

#pivot measure ratings
tidydata <- tidydata |> 
  pivot_longer(cols = deposit_incentive_rating:removable_incentive_rating, names_to = "measure_type", values_to = "measure_rating")

#relocate new cols
tidydata <- tidydata |> 
  relocate(measure_type, .after = material_losses_estimate) |> 
  relocate(measure_rating, .after = measure_type)

#pivot importance estimates
tidydata <- tidydata |> 
  pivot_longer(cols = injury_estimate:material_losses_estimate, names_to = "importance_estimate_type", values_to = "importance_estimate_rating")

#save files in processed folder
write_csv(tidydata, "data/processed/battery_recycling_incentive_survey_processed_responses_long.csv")
write_rds(tidydata, "data/processed/battery_recycling_incentive_survey_processed_responses_long.rds")
write_csv(tidydata_wide, "data/processed/battery_recycling_incentive_survey_processed_responses_wide.csv")
write_rds(tidydata_wide, "data/processed/battery_recycling_incentive_survey_processed_responses_wide.rds")
           