library(shiny)
library(leaflet)

# Choices for drop-downs
vars <- c(
  "Is SuperZIP?" = "superzip",
  "Centile score" = "centile",
  "College education" = "college",
  "Median income" = "income",
  "Population" = "adultpop"
)


shinyUI(navbarPage(" ", id="nav",
                   
                   tabPanel(
                     "Interactive map",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css"),
                                  includeScript("gomap.js")
                                ),
                                
                                leafletOutput("map", width="100%", height="100%"),
                                
                                # Shiny versions prior to 0.11 should use class="modal" instead.
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 330, height = 300,
                                              
                                              h2("Taking Root"),
                                              img(src="tr_logo.jpg"),
                                              #selectInput("color", "Color", vars),
                                              #selectInput("size", "Size", vars, selected = "adultpop"),
                                              #conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
                                              #                 # Only prompt for threshold when coloring or sizing by superzip
                                              #                 numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
                                              #),
                                              h4("Zoom and click on the coloured areas to meet the farmers on the Interactive Map."),
                                             # h4(paste("Total area currently in projects net of drop outs (in hectares equivalent):",
                                             #           length(allzips)))
                                              h4("Use the -Data Explorer- to see the data listings.")
                                              #plotOutput("histCentile", height = 200),
                                              #plotOutput("scatterCollegeIncome", height = 250)
                                ),
                                
                                tags$div(id="cite",
                                         'Data compiled for ', tags$em('Taking Root'), ' (2016).'
                                )
                            )
                   ),
                   
                   tabPanel("Data explorer",
                             #fluidRow(
                             #  column(3,
                              #       selectInput("adultpop", "System", c("All systems"="",structure(c(3,4,6)))), multiple=TRUE)
                               #,
                               #column(3,
                              #        conditionalPanel("input.states",
                              #                         selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
                              #        )
                              # ),
                             #  column(3,
                            #          conditionalPanel("input.states",
                            #                           selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
                            #          )
                            #   )
                            # ),
                            fluidRow(
                              column(3,
                                     numericInput("minScore", "Min Area", min=0, max=300, value=0)
                              ),
                              column(3,
                                     numericInput("maxScore", "Max Area", min=0, max=300, value=100)
                              )
                            ),
                            hr(),
                            DT::dataTableOutput("ziptable")
                   ),
                   
                   conditionalPanel("false", icon("crosshair"))
))