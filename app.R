library(shiny)
library(leaflet)
library(dplyr)
library(sf)
library(ggplot2)
library(bslib)

# ==========================================
# 1. DATA HARMONIZATION SCRIPT (Simulated)
# ==========================================
# In reality, you would read from CSV/GeoJSON files. Here, we simulate 
# data for 5 distinct zones in the Red Sea.
