# #
# # This is a Shiny web application. You can run the application by clicking
# # the 'Run App' button above.
# #
# # Find out more about building applications with Shiny here:
# #
# #    http://shiny.rstudio.com/
# #
# 
# library(shiny)
# 
# # Define UI for application that draws a histogram
# ui <- fluidPage(
# 
#     # Application title
#     titlePanel("Old Faithful Geyser Data"),
# 
#     # Sidebar with a slider input for number of bins 
#     sidebarLayout(
#         sidebarPanel(
#             sliderInput("bins",
#                         "Number of bins:",
#                         min = 1,
#                         max = 50,
#                         value = 30)
#         ),
# 
#         # Show a plot of the generated distribution
#         mainPanel(
#            plotOutput("distPlot")
#         )
#     )
# )
# 
# # Define server logic required to draw a histogram
# server <- function(input, output) {
# 
#     output$distPlot <- renderPlot({
#         # generate bins based on input$bins from ui.R
#         x    <- faithful[, 2]
#         bins <- seq(min(x), max(x), length.out = input$bins + 1)
# 
#         # draw the histogram with the specified number of bins
#         hist(x, breaks = bins, col = 'darkgray', border = 'white',
#              xlab = 'Waiting time to next eruption (in mins)',
#              main = 'Histogram of waiting times')
#     })
# }
# 
# # Run the application 
# shinyApp(ui = ui, server = server)

# ---------------WORKSHOP CONTENT-------------------

# 3 basic components:
  # ui <- fluidPage()
  # server <- function(input, output){}
  # shinyApp(ui = ui, server = server) - basically you need your ui and your server to run a Shiny App

pacman::p_load(shiny, DT, sf, tidyverse, tmap)

sgpools <- read_csv("data/aspatial/SGPools_svy21.csv")

sgpools_sf <- st_as_sf(sgpools,
                       coords = c("XCOORD",
                                  "YCOORD"),
                       crs = 3414)

ui <- fluidPage( # controls layout and appearance of app - fluidPage() allows webapp to be responsive
  titlePanel("Reactive Proportional Symbol Map"), # Shiny's main selling point is its Reactiveness - using user inputs to make changes to output
  sidebarLayout( # shiny comes with different layouts - in our case we're using sidebarLayout()
    sidebarPanel( # we need to use input interfaces - e.g., actionButton(), actionLink(), etc. -> most of them have an id so when storyboarding assign an id for your components so easier for us
      selectInput(inputId = "type",
                  label = "Branch or Outlet",
                  choices = c("branch" = "Branch",
                              "outlet" = "Outlet"),
                  selected = "Branch",
                  multiple = TRUE),
      sliderInput(inputId = "winning",
                  label = "Number of wins",
                  min = 5,
                  max = 82,
                  value = 20),
      checkboxInput(inputId = "showData",
                    label = "Show data table",
                    value = TRUE)
    ),
    mainPanel(
      tmapOutput("mapPlot"), # there are many types of output - we are using one of the interactive ones (using tmap)
      DT::dataTableOutput(outputId = "aTable") # use DT to show interactive table (not the Shiny dataTableOutput but the DT one)
    )
  )
)

server <- function(input, output) { # contains instructions needed to build app
  dataset <- reactive({
    sgpools_sf %>%
      filter(`OUTLET TYPE` %in% input$type) %>% # see how we use the same id mentioned earlier
      filter(`Gp1Gp2 Winnings` >= input$winning)
  })
  output$mapPlot <- renderTmap({ # this $mapPlot must be the same as the name you initialised earlier - tells Shiny where to put the plot
    tm_shape(shp = dataset(),
             bbox = st_bbox(sgpools_sf)) + # st_bbox() return bounding of a sf or sf set (bounding box = covered area)
      tm_bubbles(col = "OUTLET TYPE",
                 size = "Gp1Gp2 Winnings",
                 border.col = "black",
                 border.lwd = 0.5) +
      tm_view(set.zoom.limits = c(11, 16))
  })
  output$aTable <- DT::renderDataTable({
    if(input$showData) {
      DT::datatable(data = dataset() %>%
                      select(1:4), # you cannot get rid of the geometry column
                    options = list(pageLength = 10),
                    rownames = FALSE)
    }
  })
}
shinyApp(ui=ui, server=server) # created the Shiny app object