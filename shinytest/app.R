library(shiny)
library(ggplot2)
library(tidyr)

# Define UI
ui <- fluidPage(
  
  # Application title
  titlePanel("Quality Control app"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  sidebarLayout(
    
    # Sidebar with a slider input
    sidebarPanel(
      fileInput(inputId = "data_file", 
                label = "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      selectInput(inputId = "data_columns",
                  label = "Select columns for analysis",
                  choices = "Please Upload a file first",
                  multiple = TRUE
                  ),
      tags$hr(),
      uiOutput("finalresult")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      fluidRow(
        column(8,
               
               div(class = "plotresult", tags$label("Boxplot"),plotOutput("boxplot"))
        ),
        column(4,
               div(class = "tableresult", tags$label("Summary Table"), tableOutput("summary"))
               
        )
      ),
      fluidRow(
        column(8,
          div(class = "ftest", tags$label("F Statistic"), verbatimTextOutput("FTest"))
               ),
        column(4,
          div(class = "ftestresult", tags$label("Quality Control for F-Statistic"), uiOutput("FTestString"))
               )
        
      ),
      fluidRow(
        column(8,
               NULL
               ),
        column(4,
          div(class = "meanresult", tags$label("Quality Control for Mean"), uiOutput("MeanTest"))
               )
      )
    )
  )
)

# Server logic
server <- function(input, output, session) {
  
  input_data <- reactive({
    validate(need(length(input$data_file$datapath) == 1, "Please upload a file"))
    df <- read.csv(input$data_file$datapath,
             header = TRUE)
    validate(need(length(names(df) > 1), "The data set needs to contain at least two columns"))
    updateSelectInput(session, "data_columns", choices = names(df), selected = names(df)[c(1,2)])
    df
  })
  
  data_filtered_long <- reactive({
    df <- input_data()
    validate(need(length(input$data_columns) > 1, "Please select at least two columns from the data"))
    
    df <- df[, input$data_columns]
    
    tidyr::gather(df, samples, measurement, factor_key=TRUE)
  })
  output$boxplot <- renderPlot({
    
    ggplot(data_filtered_long()) +
      geom_boxplot(aes(y = measurement, fill = samples))
  })
  
  output$summary <- renderTable({
    dplyr::summarize(dplyr::group_by(data_filtered_long(), samples),
                     Mean=mean(measurement),
                     SD=sd(measurement),
                     Median = median(measurement),
                     Q25 = quantile(measurement, probs = 0.25),
                     Q75 = quantile(measurement, probs = 0.75)
                     )
    
  }, escape=FALSE)
  
  f_statistics <- reactive({
    validate(need(length(input$data_columns) > 1, "Please select at least two columns from the data"))
    lapply(2:length(input$data_columns), function(x){
      append(
        var.test(
          x = data_filtered_long()[which(data_filtered_long()$samples == input$data_columns[1]), "measurement"],
          y = data_filtered_long()[which(data_filtered_long()$samples == input$data_columns[x]), "measurement"],
          alternative = "two.sided"),
        list(
          x = input$data_columns[1],
          y = input$data_columns[x]
        )
      )
      
    })
    })
  
  mean_test <- reactive({
    validate(need(length(input$data_columns) > 1, "Please select at least two columns from the data"))
    lapply(2:length(input$data_columns), function(x){
      append(
        list(mean_compare = mean(data_filtered_long()[which(data_filtered_long()$samples == input$data_columns[x]), "measurement"], na.rm = T) <
               1.2 * mean(data_filtered_long()[which(data_filtered_long()$samples == input$data_columns[1]), "measurement"], na.rm = T) &&
               mean(data_filtered_long()[which(data_filtered_long()$samples == input$data_columns[x]), "measurement"], na.rm = T) >
               0.8 * mean(data_filtered_long()[which(data_filtered_long()$samples == input$data_columns[1]), "measurement"], na.rm = T)
        ),
        list(
          x = input$data_columns[1],
          y = input$data_columns[x]
        )
      )
    })
  })
  
  output$FTest <- renderText({
    
    paste(unlist(lapply(f_statistics(), function(x){
      paste("X, Y = ", x$x,",", x$y, "\n", "F = ", unname(x$statistic), ", p value = ", unname(x$p.value))
    })), collapse = "\n")
    
    
  })
  
  output$FTestString <- renderUI({
    lapply(f_statistics(), function(x){
      p(paste("X, Y = ", x$x,",", x$y, "\n", ifelse(unname(x$statistic) > 3 || unname(x$statistic) < 1/3, "F-Test failed", "F-Test ok")))
    })
  })
  
  output$MeanTest <- renderUI({
    
    lapply(mean_test(), function(x){
      p(paste("X, Y = ", x$x,",", x$y, "\n", ifelse(unname(x$mean_compare), "Mean Test ok", "Mean Test failed")))
    })
  })
  
  output$finalresult <- renderUI({
    do.call("div",
            lapply( seq_along(mean_test()), function(x){
              p(
                if(
                  mean_test()[[x]]$mean_compare &&
                  f_statistics()[[x]]$statistic < 3 &&
                  f_statistics()[[x]]$statistic > 1/3) {
                  
                  tags$img(src = "check.png", width = 20)
                }else{
                  tags$img(src = "cross.png", width = 20)
                },
                tags$label(paste(f_statistics()[[x]]$x,",", f_statistics()[[x]]$y))
              )
            }
            )
            
    )
  })
  
}

# Complete app with UI and server components
shinyApp(ui, server)