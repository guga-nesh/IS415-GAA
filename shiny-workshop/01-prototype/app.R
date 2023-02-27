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

pacman::p_load(shiny, sf, tidyverse, tmap)

sgpools <- read_csv("data/aspatial/SGPools_svy21.csv")

sgpools_sf <- st_as_sf(sgpools,
                       coords = c("XCOORD",
                                  "YCOORD"),
                       crs = 3414)

ui <- fluidPage( # controls layout and appearance of app
  titlePanel("Static Proportional Symbol Map"), # to put multiple items we use ","
  sidebarLayout( # shiny comes with different layouts - in our case we're using sidebarLayout()
    sidebarPanel(),
    mainPanel(
      plotOutput("mapPlot") # there are many types of output - we are using one of the static plot ones
    )
  )
)

server <- function(input, output) { # contains instructions needed to build app
  output$mapPlot <- renderPlot({ # this $mapPlot must be the same as the name you initialised earlier - tells Shiny where to put the plot
    tm_shape(sgpools_sf) + 
      tm_bubbles(col = "OUTLET TYPE",
                 size = "Gp1Gp2 Winnings",
                 border.col = "black",
                 border.lwd = 0.5)
  }) 
}
shinyApp(ui=ui, server=server) # created the Shiny app object