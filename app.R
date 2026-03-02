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
# 4. SHINY SERVER LOGIC
# ==========================================
server <- function(input, output, session) {
  
  # Reactive data: Update projections dynamically as sliders move
  dynamic_data <- reactive({
    data <- reef_data %>%
      mutate(
        Projected_Biomass = mapply(calculate_projection, 
                                   Base_Fish_Biomass, 
                                   input$sst_slider, 
                                   input$effort_slider, 
                                   Coral_Cover_Pct)
      )
    return(data)
  })
  
  # Render the base Leaflet Map
  output$reef_map <- renderLeaflet({
    leaflet(reef_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 38.0, lat = 21.5, zoom = 5) # Centered on Red Sea
  })
  
  observe({
    data <- dynamic_data()
    
    # Create a color palette based on Coral Cover for the markers
    pal <- colorNumeric(palette = "RdYlGn", domain = c(0, 100))
    
    leafletProxy("reef_map", data = data) %>%
      clearMarkers() %>%
      addCircleMarkers(
        ~Lng, ~Lat,
        layerId = ~Zone, # Used to capture clicks
        radius = ~Coral_Cover_Pct / 4,
        color = ~pal(Coral_Cover_Pct),
        stroke = FALSE, fillOpacity = 0.8,
        label = ~paste(Zone, "| Coral Cover:", Coral_Cover_Pct, "%"),
        popup = ~paste("<b>", Zone, "</b><br>",
                       "Base Biomass:", Base_Fish_Biomass, "MT/km2<br>",
                       "Projected Biomass:", round(Projected_Biomass, 0), "MT/km2")
      ) %>%
      addLegend("bottomright", pal = pal, values = c(0, 100),
                title = "Coral Cover (%)", opacity = 1, layerId = "legend")
  })
  
  # React to Map Clicks to render a specific zone's comparison plot
  output$dynamic_plot_card <- renderUI({
    req(input$reef_map_marker_click)
    
    card(
      card_header(paste("Biomass Projection for:", input$reef_map_marker_click$id)),
      plotOutput("biomass_plot", height = "300px")
    )
  })
  
  output$biomass_plot <- renderPlot({
    req(input$reef_map_marker_click)
    selected_zone <- input$reef_map_marker_click$id
    
    zone_data <- dynamic_data() %>% filter(Zone == selected_zone)
    
    # Prepare data for ggplot
    plot_data <- data.frame(
      Timeframe = factor(c("Current (Base)", "10-Year Projection"), levels = c("Current (Base)", "10-Year Projection")),
      Biomass = c(zone_data$Base_Fish_Biomass, zone_data$Projected_Biomass)
    )
    
    ggplot(plot_data, aes(x = Timeframe, y = Biomass, fill = Timeframe)) +
      geom_bar(stat = "identity", width = 0.5) +
      scale_fill_manual(values = c("#3498db", "#2ecc71")) +
      theme_minimal() +
      labs(y = expression("Fish Biomass (MT/" ~ km^2 ~ ")"), x = "") +
      theme(legend.position = "none", text = element_text(size = 14)) +
      geom_text(aes(label = round(Biomass, 0)), vjust = -0.5, size = 5)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
