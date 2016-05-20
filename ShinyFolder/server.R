library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
set.seed(100)
zipdata <- allzips[,]
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
zipdata <- zipdata[order(zipdata$centile),]

shinyServer(function(input, output, session) {
  
  ## Interactive Map ###########################################
  
  # Create the map  see : http://leaflet-extras.github.io/leaflet-providers/preview/index.html
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = 'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
        options = tileOptions(maxNativeZoom=17, maxZoom=19)
      ) %>%
      setView(lng = -86.23, lat = 13.5, zoom = 11)%>%
      addProviderTiles("Stamen.TonerLabels")%>%
      addProviderTiles("Stamen.TonerLines", options = providerTileOptions(opacity = 0.95)
      )
  })
  
  # A reactive expression that returns the set of zips that are
  # in bounds right now
  zipsInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(zipdata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(zipdata,
           latitude >= latRng[1] & latitude <= latRng[2] &
             longitude >= lngRng[1] & longitude <= lngRng[2])
  })
  
  # Precalculate the breaks we'll need for the two histograms
  centileBreaks <- hist(plot = FALSE, allzips$centile, breaks = 20)$breaks
  
  output$histCentile <- renderPlot({
    # If no zipcodes are in view, don't plot
    if (nrow(zipsInBounds()) == 0)
      return(NULL)
    
#   hist(zipsInBounds()$centile,
#         breaks = centileBreaks,
#         main = "Number of Trees ",
#         xlab = "Percentile",
#         xlim = range(allzips$centile),
#         col = '#00DD00',
#         border = 'white')
    
    
    
  })
  
  output$scatterCollegeIncome <- renderPlot({
    # If no zipcodes are in view, don't plot
    if (nrow(zipsInBounds()) == 0)
      return(NULL)
    
    #print(xyplot(income ~ college, data = zipsInBounds(), xlim = range(allzips$college), ylim = range(allzips$income)))
  })
  
  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  observe({
    #colorBy <- input$color
    #sizeBy <- input$size
    
    #if (colorBy == "superzip") {
      # Color and palette are treated specially in the "superzip" case, because
      # the values are categorical instead of continuous.
    #  colorData <- ifelse(zipdata$centile >= (100 - input$threshold), "yes", "no")
    #  pal <- colorFactor("Spectral", colorData)
    #} else {
    #  colorData <- zipdata[[colorBy]]
    #  pal <- colorBin("Spectral", colorData, 7, pretty = FALSE)
    #}
    
    #if (sizeBy == "superzip") {
    #  # Radius is treated specially in the "superzip" case.
    #  radius <- ifelse(zipdata$centile >= (100 - input$threshold), 5123, 3000)
    #} else {
    #  radius <- zipdata[[sizeBy]] / max(zipdata[[sizeBy]]) * 5123
    #}
  # adding polygons:  
    for(ii in 1:length(allcoords)){
    #for(ii in 1){
     mypts<-data.frame(allcoords[[ii]])
     #colnames(mypts)<-c("lon","lat","planvivo", "planvivo_plot","zipcode")
     mydat1<-cbind(as.numeric((mypts[,c("lon")])))
     mydat2<-cbind(as.numeric((mypts[,c("lat")])))
     mydat<-cbind(mydat1,mydat2)
     zipcode<-unique(as.vector(mypts[,"zipcode"]))
     leafletProxy("map", data=mypts)%>%
      addPolygons(data=mydat, stroke = TRUE, smoothFactor = 0.5 , color="red",
        fillColor="orange", layerId =zipcode)
    # addCircles(~lon, ~lat, radius=100, 
     #           stroke=FALSE, fillOpacity=0.55, fillColor="red",layerId =~zipcode)
    #%>%
      #addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
      #          layerId="colorLegend")
    
    }
    
    #observe({
    #  event <- input$map_shape_click
    #  if (is.null(event))
    #    return()
    #  print(event)      
    #})
    
    
    leafletProxy("map", data = zipdata) %>%
      #clearShapes() %>%
     addCircles(~longitude, ~latitude, radius=40, layerId=~zipcode,
               stroke=FALSE, fillOpacity=0.55, fillColor="red") 
    #%>%
    # addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
    #            layerId="colorLegend")
  
    
    })
  
  # Show a popup at the given location
  showZipcodePopup <- function(zipcode, lat, lng) {
    selectedZip <- allzips[allzips$zipcode == zipcode,]
    content <- as.character(tagList(
      #tags$h4("Last Name:", as.character(selectedZip$state.x)),
      tags$strong(HTML(sprintf("%s, %s ",  selectedZip$state.x,  selectedZip$city.x)                       )), tags$br(),
      sprintf("ID: %s",  as.character(selectedZip$county)),tags$br(),
      sprintf("PID: %s",  as.character(selectedZip$city.y)),tags$br(),
      #sprintf("Number of Trees: %s",selectedZip$centile), tags$br(),
      #sprintf("Percent of adults with BA: %s%%", as.integer(selectedZip$college)), tags$br(),
      sprintf("System: %s", selectedZip$adultpop),tags$br(),
      sprintf("Area: %s", paste(round(selectedZip$centile,2),"m2")),tags$br(),
      #tags$img(src="http://192.241.213.120/picture/productor/import/Foto_JM.jpg", width = 300)
      tags$img(src=paste(selectedZip$households), width = 100)
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
  }
 
  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      showZipcodePopup(event$id, event$lat, event$lng)
    })
  })
  
  
  ## Data Explorer ###########################################
  
  observe({
    cities <- if (is.null(input$states)) character(0) else {
      filter(cleantable, LastName %in% input$states) %>%
        `$`('FirstName') %>%
        unique() %>%
        sort()
    }
    stillSelected <- isolate(input$cities[input$cities %in% cities])
    updateSelectInput(session, "cities", choices = cities,
                      selected = stillSelected)
  })
  
#  observe({
#    zipcodes <- if (is.null(input$states)) character(0) else {
#      cleantable %>%
#        filter(LastName %in% input$states,
#               is.null(input$cities) | FirstName %in% input$cities) %>%
#        `$`('Zipcode') %>%
#        unique() %>%
#        sort()
#    }
#    stillSelected <- isolate(input$zipcodes[input$zipcodes %in% zipcodes])
#    updateSelectInput(session, "zipcodes", choices = zipcodes,
#                      selected = stillSelected)
#  })
  
  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map <- leafletProxy("map")
      map %>% clearPopups()
      dist <- 0.5
      zip <- input$goto$zip
      lat <- input$goto$lat
      lng <- input$goto$lng
      showZipcodePopup(zip, lat, lng)
      map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
    })
  })
  
  output$ziptable <- DT::renderDataTable({
    df <- cleantable %>%
      filter(
        Area >= input$minScore,
        Area <= input$maxScore
       # is.null(input$adultpop) | System %in% input$adultpop
       # is.null(input$cities) | input$cities %in% input$cities,
      #  is.null(input$zipcodes) | input$zipcodes %in% input$zipcodes
      ) %>%
      mutate(Action = paste('<a class="go-map" href="" data-lat="', Lat, '" data-long="', Long,  '"><i class="fa fa-crosshairs"></i></a>', sep=""))
    action <- DT::dataTableAjax(session, df)
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })

  
  
  
})