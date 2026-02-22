# ============================================================================
# Overview Module
# Displays dataset dimensions, structure, and preview
# ============================================================================

overviewModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      # Dataset dimensions
      column(
        width = 3,
        div(
          class = "info-box bg-aqua",
          span(class = "info-box-icon", icon("table")),
          div(
            class = "info-box-content",
            span(class = "info-box-text", "Rows"),
            span(class = "info-box-number", textOutput(ns("rows"), inline = TRUE))
          )
        )
      ),
      column(
        width = 3,
        div(
          class = "info-box bg-green",
          span(class = "info-box-icon", icon("columns")),
          div(
            class = "info-box-content",
            span(class = "info-box-text", "Columns"),
            span(class = "info-box-number", textOutput(ns("columns"), inline = TRUE))
          )
        )
      ),
      column(
        width = 3,
        div(
          class = "info-box bg-yellow",
          span(class = "info-box-icon", icon("hashtag")),
          div(
            class = "info-box-content",
            span(class = "info-box-text", "Numeric Columns"),
            span(class = "info-box-number", textOutput(ns("numeric_cols"), inline = TRUE))
          )
        )
      ),
      column(
        width = 3,
        div(
          class = "info-box bg-red",
          span(class = "info-box-icon", icon("font")),
          div(
            class = "info-box-content",
            span(class = "info-box-text", "Factor Columns"),
            span(class = "info-box-number", textOutput(ns("factor_cols"), inline = TRUE))
          )
        )
      )
    ),
    
    fluidRow(
      # Data Preview
      box(
        title = "Data Preview:",
        status = "primary",
        solidHeader = TRUE,
        width = 8,
        collapsible = TRUE,
        DTOutput(ns("data_preview"))
      ),
      
      # Data Type Summary
      box(
        title = "Data Type Summary:",
        status = "primary",
        solidHeader = TRUE,
        width = 4,
        collapsible = TRUE,
        htmlOutput(ns("data_type_summary"))
      )
    )
  )
}

overviewModuleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # Display number of rows
    output$rows <- renderText({
      req(data())
      format(nrow(data()), big.mark = ",")
    })
    
    # Display number of columns
    output$columns <- renderText({
      req(data())
      format(ncol(data()), big.mark = ",")
    })
    
    # Display number of numeric columns
    output$numeric_cols <- renderText({
      req(data())
      df <- data()
      num_count <- sum(sapply(df, is.numeric))
      format(num_count, big.mark = ",")
    })
    
    # Display number of factor columns
    output$factor_cols <- renderText({
      req(data())
      df <- data()
      factor_count <- sum(sapply(df, function(x) is.character(x) | is.factor(x)))
      format(factor_count, big.mark = ",")
    })
    
    # Data preview table
    output$data_preview <- renderDT({
      req(data())
      df <- data()
      
      datatable(
        head(df, 100),
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          scrollY = "400px",
          dom = 'Bfrtip',
          buttons = c('copy', 'csv'),
          autoWidth = TRUE,
          columnDefs = list(
            list(className = 'dt-center', targets = "_all")
          )
        ),
        rownames = TRUE,
        class = 'cell-border stripe hover'
      )
    })
    
    # Data type summary
    output$data_type_summary <- renderUI({
      req(data())
      df <- data()
      
      # Count by type
      numeric_count <- sum(sapply(df, is.numeric))
      char_count <- sum(sapply(df, is.character))
      factor_count <- sum(sapply(df, is.factor))
      
      # Create summary list
      summary_html <- tags$div(
        style = "padding: 10px;",
        tags$ul(
          style = "list-style-type: none; padding-left: 0;",
          tags$li(
            style = "padding: 8px; margin-bottom: 5px;",
            icon("circle", class = "text-aqua"),
            tags$strong(" Numeric: "),
            tags$span(numeric_count)
          ),
          tags$li(
            style = "padding: 8px; margin-bottom: 5px;",
            icon("circle", class = "text-red"),
            tags$strong(" Factor: "),
            tags$span(factor_count)
          ),
          tags$li(
            style = "padding: 8px; margin-bottom: 5px;",
            icon("circle", class = "text-yellow"),
            tags$strong(" Character: "),
            tags$span(char_count)
          )
        )
      )
      
      summary_html
    })
  })
}
