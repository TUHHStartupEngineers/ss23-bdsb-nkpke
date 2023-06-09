# Challenge 2.1 ----

# 1.0 LIBRARIES ----

library(tidyverse) # Main Package - Loads dplyr, purrr, etc.
library(rvest)     # HTML Hacking & Web Scraping
library(xopen)     # Quickly opening URLs
library(jsonlite)  # converts JSON files to R objects
library(glue)      # concatenate strings
library(stringi)   # character string/text processing
library(RSQLite)
library(httr)

# Get api key from renviron file 
apikey <- Sys.getenv('key')

# store openweathermap city id for hamburg to variable
city_id <- 2911298

# Call to openweathermao api 
weather <- GET(glue("http://api.openweathermap.org/data/2.5/forecast?id={city_id}&APPID={apikey}"))

# convert API response body
weather_extracted <- rawToChar(weather$content)  %>% fromJSON()

# extract wind speed data from response
windspeed <- weather_extracted$list$wind$speed

# extract city name from response
city_name <- weather_extracted$city$name

# hour list
hours_tbl <- seq(0,120-1,3) %>% as_tibble() %>% rename("hours" = value)

# combine hour list and windspeed data
windspeed_tbl <- windspeed %>% as_tibble() %>% rename("windspeed" = value)

# combine hours and windspeed data 
forecast_tbl <- bind_cols(hours_tbl, windspeed_tbl)

# preview first 10 rows
forecast_tbl %>% head(10)

# plot results
forecast_tbl %>%
  
  # Set up x, y, fill
  ggplot(aes(x = hours, y = windspeed)) +
  
  # Geometries
  geom_col() + # Run up to here to get a stacked bar plot
  
  # Formatting
  scale_y_continuous(labels = scales::dollar_format(big.mark = ".", 
                                                    decimal.mark = ",", 
                                                    prefix = "", 
                                                    suffix = "m/s")) +
  labs(
    title = glue("Wind speed in {city_name}"),
    subtitle = "Forecast for the next 5 days in 3 hour intervals",
    x = "Nr. of hours into the future", 
    y = "Wind speed in m/s")
