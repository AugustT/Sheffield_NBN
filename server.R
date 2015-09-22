
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(googleVis)
library(shiny)
library(DT)
library(sparta)

load('data/dataMotion.rdata')
load('data/tel_out.rdata')

shinyServer(function(input, output) {

  output$view <- renderGvis({

    gvisMotionChart(data = shef_sum_sub,
                    timevar = 'Year',
                    idvar = 'Species',
                    xvar = 'Locations',
                    yvar = 'Proportion_100m',
                    colorvar = 'Surveys',
                    sizevar = 'Records',
                    options = list(height = 500,
                                   width = 800))
  })
  
  output$table <-  DT::renderDataTable(
    shef_sum_sub,
    filter = 'top',
    options = list()
  )
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste('data-', Sys.Date(), '.rdata', sep='')
    },
    content = function(con) {
      file.copy(from = 'data/shef_data.rdata',
                to = con)
    }
  )
  
  
  output$tel_out <- renderGvis({
    
    gvisColumnChart(data = tel_out[input$range[1]:input$range[2],], xvar = "taxa", yvar = "Telfer_1_2",
                    options = list(hAxis = "{title:'Species'}",
                                   vAxis = "{title:'Change Index'}",
                                   legend = "{position: 'none'}",
                                   height = 500))
    
  })
  
  

})
