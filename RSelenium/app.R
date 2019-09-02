library(shiny)
library(tibble)
library(dplyr)
library(ggplot2)
library(ggmosaic)
library(gridExtra)

source("utils.R")

set.seed(1)

# Patient listing
pat_data <- list(
  SUBJID = 1:200,
  STUDYID = c(rep(1, 40), rep(2, 100), rep(3, 60)) %>% as.factor(),
  AGE = sample(20:88, 200, replace = T) %>% as.numeric(),
  SEX = c(sample(c("M", "F"), 180, replace = T), rep("U", 20)) %>% as.factor(),
  RACE = sample(c("ASIAN", "AMERICAN", "AFRO AMERICAN"), 200, replace = T) %>% as.factor(),
  VITAMIND = rexp(200, 1 / 100) %>% as.numeric(),
  COUNTRY = sample(c("CHINA", "US", "GER", "FRA"), 200, replace = T) %>% as.factor(),
  BIOMARKER1 = rexp(200, 1 / 80) %>% as.numeric(),
  DISEASE_STATUS = sample(c("PROGRESSED", "HEALED", "NO STATUS"), 200, replace = T) %>% as.factor()
) %>% as_tibble()

list_of_drags <- lapply(names(pat_data), function(x) {
  p(draggable = "true", ondragstart = "ziehen(event)", id = x, x)
})

ui <- bootstrapPage(
  verbatimTextOutput("results"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  tags$script(src = "dragdrop.js"),
  tags$script(src = "simulateDragDrop.js"),
  tags$input(type = "hidden", value = "", name = "x_columns_value"),
  tags$input(type = "hidden", value = "", name = "y_columns_value"),
  tags$input(type = "hidden", value = "", name = "facet_columns_value"),
  div(id = "help", "?"),
  div(class="helptext",
    tags$p("This is a nonsense help text."),
    tags$p("The text exists just for testing.")
  ),
  div(
    class = "grid-grab",
    div(class = "header", "Visualizing patient groups and measurements"),
    div(
      class = "grab",
      tags$label("Drag & Drop Columns to change the plot:"),
      div(style = "clear:both;"),
      do.call("div",
        args = append(
          list_of_drags,
          list(
            id = "grab_from",
            ondragover = "ablegenErlauben(event)",
            ondrop = "ablegen(event)",
            class = "drag grab",
            style = "grid-area: main"
          )
        )
      )
    ),
    div(
      class = "x-columns",
      tags$label("X-values (multiple allowed):"),
      div(style = "clear:both;"),
      div(id = "x_columns", class = "drag", droppable = "true", style = "grid-area: right", ondragover = "ablegenErlauben(event)", ondrop = "ablegen(event)")
    ),
    div(
      class = "y-columns",
      tags$label("Y-values (single value, character):"),
      div(style = "clear:both;"),
      div(id = "y_columns", class = "drag", style = "grid-area: right", ondragover = "ablegenErlauben(event)", ondrop = "ablegen(event)")
    ),
    div(
      class = "facet-columns",
      tags$label("Facet-values (single value, character):"),
      div(style = "clear:both;"),
      div(id = "facet_columns", class = "drag", style = "grid-area: right", ondragover = "ablegenErlauben(event)", ondrop = "ablegen(event)")
    )
  ),
  div(style = "clear:both"),
  div(
    class = "grid-container-tableplot",
    div(
      class = "table",
      dataTableOutput("table1")
    ),
    div(
      class = "plot",
      plotOutput("plot1")
    )
  )
)

server <- function(input, output) {
  split_cols <- function(x) {
    if (!is.null(x)) {
      columns_selected <- strsplit(x, split = ",")[[1]]
      columns_selected[columns_selected != ""]
    }
  }

  columns_x <- reactive({
    unique(split_cols(input$x_columns))
  })
  columns_y <- reactive({
    unique(split_cols(input$y_columns))
  })
  columns_facet <- reactive({
    unique(split_cols(input$facet_columns))
  })

  output$table1 <- renderDataTable({
    columns_to_use <- c(columns_x(), columns_y(), columns_facet())
    validate(need(length(columns_to_use) > 0, "Please select any column"))
    pat_data[columns_to_use]
  })
  output$plot1 <- renderPlot({
    validate(need(is.character(columns_x()) && length(columns_x()) > 0, "Please define X-variable"))
    validate(need(is.character(columns_y()) && length(columns_y()) == 1, "Please define single Y-variable"))
    factor_y <- vapply(
      X = columns_y(),
      FUN = function(x) is.factor(pat_data[[x]]),
      logical(1)
    )
    factor_x <- vapply(
      X = columns_x(),
      FUN = function(x) is.factor(pat_data[[x]]),
      logical(1)
    )
    validate(need(
      all(factor_y),
      "Please define a character variable as Y"
    ))

    if (all(factor_x) && all(factor_y)) {
      formula <- paste0("ggmosaic::product(", paste(columns_x(), collapse = ","), ")")
      
      if (length(columns_facet()) == 1 && !is.factor(pat_data[[columns_facet()]])) {
         showNotification("Please select a character facetting")
      }
      
      ggplot2::ggplot(pat_data) +
        ggmosaic::geom_mosaic(aes_string(x = formula, fill = columns_y()), na.rm = TRUE) +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        if (length(columns_facet()) == 1 && is.factor(pat_data[[columns_facet()]])) {
          facet_grid(reformulate(columns_facet()))
        } else {
          NULL
        }
    } else {
      
      if (length(columns_x()) == 1) {
        boxplot_intern(x = columns_x(), y = columns_y(), facet_cols = columns_facet(), pat_data = pat_data)
      } else {
        list_of_plots <- lapply(columns_x(), boxplot_intern, y = columns_y(), facet_cols = columns_facet(), pat_data = pat_data)
        do.call(grid.arrange, args = list_of_plots)
      }
    }
  })
}

shinyApp(ui, server)
