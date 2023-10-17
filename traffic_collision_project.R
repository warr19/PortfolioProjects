
# Load the dataset
library(readr)

library(dplyr)

pd_collisions_datasd <- read_csv("pd_collisions_datasd.csv")
View(pd_collisions_datasd)

# Combine street number, direction of street, name of street columns, and add San Diego, CA.

pd_collisions_datasd$Full_Address <- paste(
  ifelse(pd_collisions_datasd$address_no_primary != 0, pd_collisions_datasd$address_no_primary, ""),
  ifelse(!is.na(pd_collisions_datasd$address_pd_primary), pd_collisions_datasd$address_pd_primary, ""),
  pd_collisions_datasd$address_road_primary,
  "San Diego, CA"
)

# Take away any blank spaces form columns starting with blank spaces in Full_Address column
pd_collisions_datasd$Full_Address <- gsub("^\\s+", "", pd_collisions_datasd$Full_Address)


# Group by full adress column and sum injured and killed columns then list in descending order

result <- pd_collisions_datasd %>%
  group_by(Full_Address) %>%
  summarize(Total_Injured = sum(injured), Total_Killed = sum(killed)) %>%
  arrange(desc(Total_Killed)) 


# Only List adresses where more than 0 people were killed

filtered_data <- result %>%
  filter(Total_Killed > 0)

# Take out all consecutive spaces
filtered_data$Full_Address <- gsub("\\s+", " ", filtered_data$Full_Address)

# geocode latitude and longitude columns

install.packages("ggmap")
install.packages("tidyr")

library(ggmap)
library(tidyr)

api_key <- "YOUR_API_KEY_HERE"

filtered_data <- filtered_data %>%
  mutate(geo_info = filtered_data(Full_Address, key = api_key)) %>%
  separate(geo_info, into = c("lat", "long"), sep = ",")

  # Plot on a google map

install.packages("leaflet")
library(leaflet)



color_palette <- colorRampPalette(c("blue", "red"))

# Create a color scale based on the range of total deaths
color_scale <- colorNumeric(palette = color_palette(100), domain = filtered_data$Total_Deaths)

# Create a leaflet map centered on San Diego
map <- leaflet(data = filtered_data) %>%
  addTiles() %>%
  setView(lng = -117.1611, lat = 32.7157, zoom = 12)

# Add circle markers with colors based on the number of total deaths
map <- map %>%
  addCircleMarkers(
    lat = ~Latitude,
    lng = ~Longitude,
    radius = ~Total_Deaths * 2,  # Adjust the marker size based on the Total_Deaths column
    color = ~color_scale(Total_Deaths),
    fillOpacity = 0.7
  )

# Display the map
map


