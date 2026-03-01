# RedSea-DataLens 🌊
**Interactive Ecological Predictive Dashboard for Red Sea Aquatic Food Systems**

## Overview
This R Shiny application models the 10-year sustainability of the Red Sea ecosystem. Users can simulate climate change and fishery management scenarios to visualize impacts on fish biomass.

## Key Features
- **Predictive Modeling:** Calculates biomass recovery based on SST and fishing effort.
- **Live Geospatial Mapping:** Uses Leaflet for real-time risk visualization.
- **Data Harmonization:** Merges species occurrence (OBIS) and climate data (NOAA).

## How to Run
Ensure you have R and RStudio installed. You will also need the following packages:

```install.packages(c("shiny", "leaflet", "dplyr", "ggplot2", "bslib", "robis", "rerddap"))```
