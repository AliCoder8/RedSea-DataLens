library(shiny)
library(leaflet)
library(dplyr)
library(sf)
library(ggplot2)
library(bslib)

# ==========================================
# 1. DATA HARMONIZATION SCRIPT (Simulated)
# ==========================================
generate_red_sea_data <- function() {
  # Simulated Coordinates for Red Sea Zones (North to South)
  zones <- data.frame(
    Zone = c("Gulf of Aqaba", "Northern Red Sea", "Central Red Sea", "Southern Red Sea", "Farasan Islands"),
    Lat = c(28.5, 26.0, 21.5, 16.5, 16.7),
    Lng = c(34.8, 35.5, 38.0, 40.5, 41.8)
  )
  
  # Dataset 1: Historical Sea Surface Temp (SST in Celsius)
  sst_data <- data.frame(
    Zone = zones$Zone,
    Baseline_SST = c(24.5, 26.0, 28.5, 30.2, 31.0)
  )
  
  # Dataset 2: Simulated Catch Data / Fishing Effort (Scale 1-100)
  catch_data <- data.frame(
    Zone = zones$Zone,
    Fishing_Effort = c(45, 60, 85, 90, 50),
    Base_Fish_Biomass = c(800, 650, 400, 350, 750) # metric tons per km2
  )
  
  # Dataset 3: Coral Reef Health Index (Percentage of Live Coral Cover)
  coral_data <- data.frame(
    Zone = zones$Zone,
    Coral_Cover_Pct = c(65, 55, 35, 30, 70)
  )
  
  # HARMONIZATION: Merge the proxies into a single master dataset
  master_data <- zones %>%
    left_join(sst_data, by = "Zone") %>%
    left_join(catch_data, by = "Zone") %>%
    left_join(coral_data, by = "Zone")
  
  return(master_data)
}

reef_data <- generate_red_sea_data()
