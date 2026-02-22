# ============================================================================
# Outliers Module
# Detects and visualizes outliers in numeric variables
# ============================================================================

outliersModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Outlier Detection Settings",
        status = "danger",
        solidHeader = TRUE,
        width = 3,
        
        selectInput(
          ns("outlier_var"),
          "Select Variable:",
          choices = NULL
        ),
        
        selectInput(
          ns("outlier_method"),
          "Detection Method:",
          choices = c(
            "IQR Method" = "iqr",
            "Z-Score" = "zscore",
            "Modified Z-Score" = "modified_z"
          ),
          selected = "iqr"
        ),
        
        sliderInput(
          ns("iqr_multiplier"),
          "IQR Multiplier:",
          min = 1,
          max = 3,
          value = 1.5,
          step = 0.5
        ),
        
        sliderInput(
          ns("zscore_threshold"),
          "Z-Score Threshold:",
          min = 2,
          max = 4,
          value = 3,
          step = 0.5
        ),
        
        hr(),
        
        actionButton(
          ns("detect_outliers"),
          "Detect Outliers",
          class = "btn-danger btn-block",
          icon = icon("exclamation-triangle")
        )
      ),
      
      box(
        title = "Outlier Visualization",
        status = "danger",
        solidHeader = TRUE,
        width = 9,
        plotlyOutput(ns("outlier_plot"), height = "600px")
      )
    ),
    
    fluidRow(
      box(
        title = "Outlier Statistics",
        status = "danger",
        solidHeader = TRUE,
        width = 6,
        collapsible = TRUE,
        htmlOutput(ns("outlier_stats"))
      ),
      
      box(
        title = "Detected Outliers",
        status = "danger",
        solidHeader = TRUE,
        width = 6,
        collapsible = TRUE,
        DTOutput(ns("outlier_table"))
      )
    )
  )
}

outliersModuleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # Update variable choices
    observe({
      req(data())
      df <- data()
      numeric_cols <- names(df)[sapply(df, is.numeric)]
      
      updateSelectInput(
        session,
        "outlier_var",
        choices = numeric_cols,
        selected = numeric_cols[1]
      )
    })
    
    # Detect outliers
    outlier_results <- eventReactive(input$detect_outliers, {
      req(data(), input$outlier_var)
      
      df <- data()
      var_data <- df[[input$outlier_var]]
      var_data_clean <- var_data[!is.na(var_data)]
      
      if (length(var_data_clean) == 0) {
        return(NULL)
      }
      
      # Detect outliers based on method
      outliers <- switch(
        input$outlier_method,
        "iqr" = detect_iqr_outliers(var_data_clean, input$iqr_multiplier),
        "zscore" = detect_zscore_outliers(var_data_clean, input$zscore_threshold),
        "modified_z" = detect_modified_z_outliers(var_data_clean, input$zscore_threshold)
      )
      
      list(
        data = var_data_clean,
        outliers = outliers,
        outlier_indices = which(outliers),
        outlier_values = var_data_clean[outliers],
        method = input$outlier_method,
        variable = input$outlier_var
      )
    })
    
    # IQR method
    detect_iqr_outliers <- function(x, multiplier = 1.5) {
      Q1 <- quantile(x, 0.25, na.rm = TRUE)
      Q3 <- quantile(x, 0.75, na.rm = TRUE)
      IQR <- Q3 - Q1
      
      lower_bound <- Q1 - multiplier * IQR
      upper_bound <- Q3 + multiplier * IQR
      
      return(x < lower_bound | x > upper_bound)
    }
    
    # Z-score method
    detect_zscore_outliers <- function(x, threshold = 3) {
      z_scores <- abs((x - mean(x)) / sd(x))
      return(z_scores > threshold)
    }
    
    # Modified Z-score method
    detect_modified_z_outliers <- function(x, threshold = 3.5) {
      median_x <- median(x)
      mad_x <- median(abs(x - median_x))
      modified_z_scores <- 0.6745 * (x - median_x) / mad_x
      return(abs(modified_z_scores) > threshold)
    }
    
    # Render outlier plot
    output$outlier_plot <- renderPlotly({
      results <- outlier_results()
      
      if (is.null(results)) {
        p <- ggplot() +
          annotate("text", x = 0.5, y = 0.5, 
                   label = "Select a variable and click 'Detect Outliers'", 
                   size = 6) +
          theme_void()
        return(ggplotly(p))
      }
      
      # Create data frame for plotting
      plot_df <- data.frame(
        Index = 1:length(results$data),
        Value = results$data,
        Outlier = results$outliers
      )
      
      # Create combined plot
      p1 <- ggplot(plot_df, aes(x = Index, y = Value, color = Outlier)) +
        geom_point(size = 2, alpha = 0.6) +
        scale_color_manual(values = c("FALSE" = "#4A90E2", "TRUE" = "#E74C3C")) +
        labs(
          title = paste("Outlier Detection:", results$variable),
          subtitle = paste("Method:", toupper(results$method)),
          x = "Index",
          y = "Value"
        ) +
        theme_instaeda() +
        theme(legend.position = "bottom")
      
      ggplotly(p1, tooltip = c("x", "y", "color"))
    })
    
    # Render outlier statistics
    output$outlier_stats <- renderUI({
      results <- outlier_results()
      
      if (is.null(results)) {
        return(tags$p("No outlier detection performed yet."))
      }
      
      n_total <- length(results$data)
      n_outliers <- sum(results$outliers)
      pct_outliers <- round((n_outliers / n_total) * 100, 2)
      
      if (n_outliers > 0) {
        min_outlier <- min(results$outlier_values)
        max_outlier <- max(results$outlier_values)
      } else {
        min_outlier <- NA
        max_outlier <- NA
      }
      
      tags$div(
        style = "padding: 15px;",
        tags$h4("Detection Summary:"),
        tags$hr(),
        tags$div(
          class = "info-box bg-aqua",
          style = "margin-bottom: 10px;",
          tags$div(
            style = "padding: 10px;",
            tags$strong("Total Observations: "),
            tags$span(format(n_total, big.mark = ","))
          )
        ),
        tags$div(
          class = "info-box bg-red",
          style = "margin-bottom: 10px;",
          tags$div(
            style = "padding: 10px;",
            tags$strong("Outliers Detected: "),
            tags$span(format(n_outliers, big.mark = ",")),
            tags$span(paste0(" (", pct_outliers, "%)"))
          )
        ),
        if (n_outliers > 0) {
          tagList(
            tags$div(
              class = "info-box bg-yellow",
              style = "margin-bottom: 10px;",
              tags$div(
                style = "padding: 10px;",
                tags$strong("Min Outlier: "),
                tags$span(round(min_outlier, 3))
              )
            ),
            tags$div(
              class = "info-box bg-yellow",
              tags$div(
                style = "padding: 10px;",
                tags$strong("Max Outlier: "),
                tags$span(round(max_outlier, 3))
              )
            )
          )
        }
      )
    })
    
    # Render outlier table
    output$outlier_table <- renderDT({
      results <- outlier_results()
      
      if (is.null(results)) {
        return(
          datatable(
            data.frame(Message = "No outliers detected yet"),
            options = list(dom = 't'),
            rownames = FALSE
          )
        )
      }
      
      if (length(results$outlier_indices) == 0) {
        return(
          datatable(
            data.frame(Message = "No outliers found with current settings"),
            options = list(dom = 't'),
            rownames = FALSE
          )
        )
      }
      
      outlier_df <- data.frame(
        Index = results$outlier_indices,
        Value = results$outlier_values,
        stringsAsFactors = FALSE
      )
      
      datatable(
        outlier_df,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          scrollY = "300px",
          dom = 'Bfrtip',
          buttons = c('copy', 'csv'),
          columnDefs = list(
            list(className = 'dt-center', targets = "_all")
          )
        ),
        rownames = FALSE,
        class = 'cell-border stripe hover'
      ) %>%
        formatRound('Value', 3)
    })
  })
}
