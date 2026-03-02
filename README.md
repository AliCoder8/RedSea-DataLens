## RedSea-DataLens
This repository contains a spatial decision support tool designed to visualize and project the ecological health of the Red Sea. By harmonizing disparate datasets, the application allows users to simulate how environmental shifts and management decisions impact fish biomass over a 10-year horizon.
## 📌 Project Overview
The Red Sea is a unique marine ecosystem characterized by high endemism and varying levels of thermal resilience. This dashboard provides an interactive interface to explore five key zones: the Gulf of Aqaba, Northern Red Sea, Central Red Sea, Southern Red Sea, and the Farasan Islands.
The core of this project is a predictive ecological model that evaluates the interplay between rising ocean temperatures and local fishing pressure, weighted by the inherent resilience of existing coral health.

## Key Features
- **Data Harmonization:** Merges simulated Sea Surface Temperature (SST), fishing effort, and coral cover, into a unified master data.
- **Predictive Modeling:** Calculates biomass recovery based on SST and fishing effort.
- **Live Geospatial Mapping:** Uses Leaflet for real-time risk visualization.

## How to Run
Ensure you have R and RStudio installed. You will also need the following packages:

```install.packages(c("shiny", "leaflet", "dplyr", "ggplot2", "bslib", "robis", "rerddap"))```

## Result

By using this tool, stakeholders can visualize a "Resilience Gradient." For example, zones with high initial coral cover (70%) demonstrate greater capacity to buffer against temperature increases compared to the zones, where lower coral cover significantly amplifies the impact of environmental stress.

<img width="939" height="600" alt="red_sea_1" src="https://github.com/user-attachments/assets/80d5c4cf-e519-4d5c-9cb1-a5af08d0ff37" />

<img width="939" height="600" alt="red_sea_2" src="https://github.com/user-attachments/assets/000cf234-62c9-4223-b537-cc3650fb1fdd" />
