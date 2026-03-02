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

# ==========================================
# 2. PREDICTIVE MODEL FUNCTION
# ==========================================
# A simplified ecological model projecting biomass 10 years out.
calculate_projection <- function(base_biomass, sst_change, effort_change, coral_health) {
  # Increase in temp reduces biomass; decrease in effort increases biomass
  temp_impact <- 1 - (sst_change * 0.05) 
  effort_impact <- 1 + (abs(effort_change) * 0.005) # Assuming slider is negative %
  
  # Coral health acts as a resilience multiplier
  resilience <- (coral_health / 50) 
  
  projected <- base_biomass * temp_impact * effort_impact * resilience
  return(max(0, projected)) # Biomass can't drop below 0
}

# ==========================================
# 3. SHINY USER INTERFACE (UI)
# ==========================================
ui <- page_sidebar(
  title = "Red Sea Reef Health & Fishery Dashboard",
  theme = bs_theme(bootswatch = "cerulean"),
  
  sidebar = sidebar(
    h4("Scenario Modeling (10-Year)"),
    p("Adjust the environmental and economic variables to see the projected impact on fish biomass."),
    
    sliderInput("sst_slider", 
                "Projected SST Change (°C):", 
                min = 0, max = 4, value = 0, step = 0.5),
    
    sliderInput("effort_slider", 
                "Fishing Effort Reduction (%):", 
                min = -50, max = 0, value = 0, step = 5),
    
    hr(),
    h5("How it works"),
    p("Click on a specific zone marker on the map to view local metrics and the 10-year biomass projection based on your slider inputs.")
  ),
  
  card(
    full_screen = TRUE,
    leafletOutput("reef_map", height = "500px")
  ),
  
  uiOutput("dynamic_plot_card")
)

# ==========================================
# 4. SERVER LOGIC (To Commit)
# ==========================================

# Run the application 
shinyApp(ui = ui, server = server)
