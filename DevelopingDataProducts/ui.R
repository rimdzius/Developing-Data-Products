#'
#' This application uses the base-R "airquality" dataset.
#' 
#' The data is displayed on a graph, and the user is able to select the
#' X- and Y-axis variables, as well as the color and size variables.
#' 
#' They can then enter values from the X-axis, color and size variables,
#' and get a prediction from a randomforest model for the y-axis variable.
#'

library(shiny)
library(ggplot2)
library(caret)
library(randomForest)
data <- airquality

shinyUI(fluidPage(

    ## Title and description of the app.
    fluidRow(
        column(12,
               h1("Air Quality Dataset"),
               p("This dataset includes daily air quality measurements in New York, 
                 May to September 1973. Investigate the data in the graph,
                 and enter any values below it in which you want to make a 
                 prediction. The selections for the graph are the outcome and
                 predictors in the model below!")
        )
    ),
    
    hr(),
    
    ## The exploratory plot interface. Four selections for the graph on the left
    ## and the actual plot on the right.
    fluidRow(
        column(3,
               br(),
               selectInput(inputId = "y", label = "Y-axis", choices = names(data), selected = "Ozone"),
               hr(),
               selectInput(inputId = "x", label = "X-axis", choices = names(data), selected = "Solar.R"),
               selectInput(inputId = "color", label = "Color", choices = names(data), selected = "Temp"),
               selectInput(inputId = "size", label = "Size", choices = names(data), selected = "Wind")
        ),
        column(9,
               plotOutput("plot")
        )
    ),
    
    hr(),
    
    ## These are the input values for the model. The actual selectinputs are on the
    ## server.ui, as the default variable is set as the median value of the associated
    ## input.
    fluidRow(
        column(12,
               h1(textOutput("title")),
               uiOutput("xselection"),
               uiOutput("colorselection"),
               uiOutput("sizeselection"),
               actionButton(inputId = "button", label = "Predict")
        )
    ),
    
    hr(),
    
    ## The results are displayed at the bottom.
    fluidRow(
        column(12,
               verbatimTextOutput("results")
        )
    )
    
))
