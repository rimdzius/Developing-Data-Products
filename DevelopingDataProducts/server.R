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

shinyServer(function(input, output) {
    
    ## These are the numeric inputs in which the user can enter values for the
    ## prediction. THey are created with a renderUI, so that the default value
    ## can be set as the median of the selected input value from the graph.
    output$xselection <- renderUI({
        numericInput(inputId = "xpred", label = paste0("Enter a value for ",input$x,":"),
                    value = median(data[,input$x], na.rm = TRUE),
                    min = min(data[,input$x,], na.rm = TRUE),
                    max = max(data[,input$x], na.rm = TRUE))
    })
    output$colorselection <- renderUI({
        numericInput(inputId = "colorpred", label = paste0("Enter a value for ",input$color,":"),
                     value = median(data[,input$color], na.rm = TRUE),
                     min = min(data[,input$color,], na.rm = TRUE),
                     max = max(data[,input$color], na.rm = TRUE))
    })
    output$sizeselection <- renderUI({
        numericInput(inputId = "sizepred", label = paste0("Enter a value for ",input$size,":"),
                     value = median(data[,input$size], na.rm = TRUE),
                     min = min(data[,input$size,], na.rm = TRUE),
                     max = max(data[,input$size], na.rm = TRUE))
    })
    
    ## The plot is created with ggplot2.
    output$plot <- renderPlot({
        ## The input values are saved as variables for simoplicity.
        xi <- input$x
        yi <- input$y
        colori <- input$color
        sizei <- input$size

        ## Since I am using variables, instead of the actual column names, I have
        ## to use eval(as.name()) to extract the column name to use with ggplot.
        ggplot(data, aes(x = eval(as.name(xi)),
                         y = eval(as.name(yi)),
                         color = eval(as.name(colori)),
                         size = eval(as.name(sizei)))) +
            geom_point() +
            ## Since I used eval(as.name()) above, I need to rename axes and
            ## legends with the proper names.
            labs(x = as.name(xi),
                 y = as.name(yi),
                 color = as.name(colori),
                 size = as.name(sizei),
                 title = paste0("Airquality data: ",yi, " vs. ", xi, ", ", colori, ", and ", sizei))

    })
    
    ## The title for the prediction input section is given with the correct
    ## input variable.
    output$title <- renderText({
        paste0("Predicting a value for \"",input$y,"\" (Y-axis).")
    })
    
    ## The randomforest prediction only begins running once the Action button
    ## is pressed.
    output$results <- renderText({
        
        ## If the button hasn't been pressed at all, inform the user how to get a prediction.
        if (input$button == 0)
            return("Enter desired values above, and press \"Predict.\"")
        
        ## Wait for the button to be pressed before running the model.
        input$button
        isolate({   
            ## Get all of the inputs.
            y <- input$y
            x1 <- input$x
            x2 <- input$color
            x3 <- input$size
            pred1 <- input$xpred
            pred2 <- input$colorpred
            pred3 <- input$sizepred
            x <- c(x1, x2, x3)
            pred <- data.frame(pred1, pred2, pred3)
            colnames(pred) <- x
        
            ## Train a randomforest model based on the complete cases of the data.
            model <- train(x=data[complete.cases(data),x], y=data[complete.cases(data),y], method="rf")
            ## Get the predicted value based on the inputed predictors.
            prediction <- predict(model, pred)
            ## Get the results to the user.
            ## I wish this were a slightly larger dataset to do validation, and
            ## return some proper accuracy and confidence intervals.
            paste0("Predicted value of ",y,": ",round(prediction,2),
                   "\nPredictors: ",x1,", ",x2,", ",x3,
                   "\nUsing randomforest method inside caret package's train() function.",
                   "\n(Only complete cases used for modeling.)",
                   "\nTo make another prediction, enter new values and select Predict, or select new variables in the graph.")
        })
    })
    

})
