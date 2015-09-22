
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Sheffield NBN data"),

  tabsetPanel(
    tabPanel("Plot",
             fluidRow(column(width = 2,
                             h2("rnbn"),
                             p("This visualisation is created using information collected from the NBN Gateway"),
                             a('https://data.nbn.org.uk/', href = 'https://data.nbn.org.uk/'),
                             br(),
                             br(),
                             p("Data was collected using the R package 'rnbn'. This package can be easily installed from the R console like this:"),
                             code('install.packages("rnbn")'),
                             br(),
                             br(),
                             p('Find all the code used to build this shiny site here:'),
                             a('https://github.com/AugustT', href = 'https://github.com/AugustT')),
                      column(width = 10,
                             htmlOutput("view"))
                      )),
    tabPanel("Table", DT::dataTableOutput("table")),
    tabPanel("Change Indicies",
             fluidRow(column(width = 4,
                             offset = 4,
                             sliderInput("range", "X-axis Range",
                                         min = 1, max = 234, value = c(1,234),
                                         ticks = FALSE, dragRange = TRUE,
                                         step = 1)
                             )
             ),
             fluidRow(column(width = 12,
                             htmlOutput("tel_out"))
                      )
             )
                      ,
    tabPanel("Export .rdata file", downloadButton("downloadData",
                                                  "Download .rdata")) 
  )
))
