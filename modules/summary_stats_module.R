# ============================================================================
# Summary Statistics Module
# Generates comprehensive statistical summaries
# ============================================================================

summaryStatsModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Numeric Variables Summary",
        status = "info",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        DTOutput(ns("summary_table"))
      )
    ),
    
    fluidRow(
      box(
        title = "Distribution Overview",
        status = "info",
        solidHeader = TRUE,
        width = 6,
        collapsible = TRUE,
        plotlyOutput(ns("distribution_plot"), height = "400px")
      ),
      
      box(
        title = "Variable Statistics",
        status = "info",
        solidHeader = TRUE,
        width = 6,
        collapsible = TRUE,
        uiOutput(ns("variable_selector")),
        plotlyOutput(ns("boxplot_overview"), height = "350px")
      )
    )
  )
}

summaryStatsModuleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # Generate summary statistics
    summary_data <- reactive({
      req(data())
      df <- data()
      
      numeric_cols <- names(df)[sapply(df, is.numeric)]
      
      if (length(numeric_cols) == 0) {
        return(NULL)
      }
      
      summary_list <- lapply(numeric_cols, function(col) {
        x <- df[[col]]
        data.frame(
          Variable = col,
          Count = sum(!is.na(x)),
          Missing = sum(is.na(x)),
          Mean = mean(x, na.rm = TRUE),
          Median = median(x, na.rm = TRUE),
          SD = sd(x, na.rm = TRUE),
          Min = min(x, na.rm = TRUE),
          Max = max(x, na.rm = TRUE),
          Q25 = quantile(x, 0.25, na.rm = TRUE),
          Q75 = quantile(x, 0.75, na.rm = TRUE),
          Skewness = calculate_skewness(x),
          stringsAsFactors = FALSE
        )
      })
      
      do.call(rbind, summary_list)
    })
    
    # Helper function to calculate skewness
    calculate_skewness <- function(x) {
      x <- x[!is.na(x)]
      n <- length(x)
      if (n < 3) return(NA)
      
      m <- mean(x)
      s <- sd(x)
      skew <- (sum((x - m)^3) / n) / (s^3)
      return(round(skew, 3))
    }
    
    # Render summary table
    output$summary_table <- renderDT({
      stats <- summary_data()
      
      if (is.null(stats)) {
        return(
          datatable(
            data.frame(Message = "No numeric variables found in the dataset!"),
            options = list(dom = 't'),
            rownames = FALSE
          )
        )
      }
      
      datatable(
        stats,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel'),
          columnDefs = list(
            list(className = 'dt-center', targets = "_all")
          )
        ),
        rownames = FALSE,
        class = 'cell-border stripe hover'
      ) %>%
        formatRound(columns = c('Mean', 'Median', 'SD', 'Min', 'Max', 'Q25', 'Q75'), 
                    digits = 2)
    })
    
    # Distribution comparison plot
    output$distribution_plot <- renderPlotly({
      req(data())
      df <- data()
      
      numeric_cols <- names(df)[sapply(df, is.numeric)]
      
      if (length(numeric_cols) == 0) {
        p <- ggplot() +
          annotate("text", x = 0.5, y = 0.5, 
                   label = "No Numeric Variables", 
                   size = 6) +
          theme_void()
        return(ggplotly(p))
      }
      
      # Select up to 6 variables for visualization
      selected_cols <- head(numeric_cols, 6)
      
      # Prepare data for plotting
      plot_data <- df %>%
        select(all_of(selected_cols)) %>%
        pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value") %>%
        filter(!is.na(Value))
      
      # Create violin plot
      p <- ggplot(plot_data, aes(x = Variable, y = Value, fill = Variable)) +
        geom_violin(alpha = 0.6, draw_quantiles = c(0.25, 0.5, 0.75)) +
        scale_fill_viridis_d(option = "D") +
        labs(
          title = "Distribution Comparison (Top 6 Numeric Variables)",
          x = "Variable",
          y = "Value"
        ) +
        theme_instaeda() +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 45, hjust = 1))
      
      ggplotly(p, tooltip = c("x", "y"))
    })
    
    # Variable selector
    output$variable_selector <- renderUI({
      req(data())
      df <- data()
      
      numeric_cols <- names(df)[sapply(df, is.numeric)]
      
      if (length(numeric_cols) == 0) {
        return(NULL)
      }
      
      selectInput(
        session$ns("selected_var"),
        "Select Variable:",
        choices = numeric_cols,
        selected = numeric_cols[1]
      )
    })
    
    # Boxplot for selected variable
    output$boxplot_overview <- renderPlotly({
      req(input$selected_var, data())
      df <- data()
      
      selected_data <- df[[input$selected_var]]
      selected_data <- selected_data[!is.na(selected_data)]
      
      # Create boxplot data
      plot_data <- data.frame(
        Variable = input$selected_var,
        Value = selected_data
      )
      
      p <- ggplot(plot_data, aes(x = Variable, y = Value)) +
        geom_boxplot(fill = "#4A90E2", alpha = 0.6, outlier.color = "#E74C3C") +
        geom_jitter(width = 0.2, alpha = 0.3, color = "#2C3E50", size = 1) +
        labs(
          title = paste("Distribution of", input$selected_var),
          x = "",
          y = "Value"
        ) +
        theme_instaeda()
      
      ggplotly(p, tooltip = c("y"))
    })
  })
}
