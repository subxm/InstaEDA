# ============================================================================
# Correlation Module
# Analyzes and visualizes correlations between numeric variables
# ============================================================================

correlationModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Correlation Heatmap",
        status = "success",
        solidHeader = TRUE,
        width = 8,
        collapsible = TRUE,
        plotlyOutput(ns("correlation_heatmap"), height = "600px")
      ),
      
      box(
        title = "Settings",
        status = "success",
        solidHeader = TRUE,
        width = 4,
        collapsible = TRUE,
        
        selectInput(
          ns("cor_method"),
          "Correlation Method:",
          choices = c("Pearson" = "pearson", 
                     "Spearman" = "spearman", 
                     "Kendall" = "kendall"),
          selected = "pearson"
        ),
        
        sliderInput(
          ns("cor_threshold"),
          "Highlight Threshold:",
          min = 0,
          max = 1,
          value = 0.7,
          step = 0.1
        ),
        
        hr(),
        
        h4("Correlation Strength Guide:"),
        tags$ul(
          tags$li("0.0 - 0.3: Weak"),
          tags$li("0.3 - 0.7: Moderate"),
          tags$li("0.7 - 1.0: Strong")
        )
      )
    ),
    
    fluidRow(
      box(
        title = "Correlation Matrix",
        status = "success",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        DTOutput(ns("correlation_table"))
      )
    ),
    
    fluidRow(
      box(
        title = "Strong Correlations",
        status = "success",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        DTOutput(ns("strong_correlations"))
      )
    )
  )
}

correlationModuleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # Calculate correlation matrix
    cor_matrix <- reactive({
      req(data())
      df <- data()
      
      # Get numeric columns
      numeric_df <- df %>% select(where(is.numeric))
      
      if (ncol(numeric_df) < 2) {
        return(NULL)
      }
      
      # Calculate correlation
      cor_mat <- cor(numeric_df, 
                     use = "pairwise.complete.obs", 
                     method = input$cor_method)
      
      return(cor_mat)
    })
    
    # Render correlation heatmap
    output$correlation_heatmap <- renderPlotly({
      cor_mat <- cor_matrix()
      
      if (is.null(cor_mat)) {
        p <- ggplot() +
          annotate("text", x = 0.5, y = 0.5, 
                   label = "Need at least 2 numeric variables\nfor correlation analysis", 
                   size = 6) +
          theme_void()
        return(ggplotly(p))
      }
      
      # Create heatmap
      plot_ly(
        z = cor_mat,
        x = colnames(cor_mat),
        y = rownames(cor_mat),
        type = "heatmap",
        colors = colorRamp(c("#E74C3C", "white", "#4A90E2")),
        zauto = FALSE,
        zmin = -1,
        zmax = 1,
        hovertemplate = paste(
          '<b>%{x} vs %{y}</b><br>',
          'Correlation: %{z:.3f}<br>',
          '<extra></extra>'
        )
      ) %>%
        layout(
          title = list(text = paste("Correlation Heatmap (", 
                                   tools::toTitleCase(input$cor_method), 
                                   "Method)"),
                      x = 0.5),
          xaxis = list(title = "", tickangle = -45),
          yaxis = list(title = ""),
          margin = list(l = 100, b = 100)
        ) %>%
        colorbar(title = "Correlation\nCoefficient")
    })
    
    # Render correlation table
    output$correlation_table <- renderDT({
      cor_mat <- cor_matrix()
      
      if (is.null(cor_mat)) {
        return(
          datatable(
            data.frame(Message = "Insufficient numeric variables for correlation analysis"),
            options = list(dom = 't'),
            rownames = FALSE
          )
        )
      }
      
      # Convert to data frame
      cor_df <- as.data.frame(cor_mat)
      cor_df <- round(cor_df, 3)
      
      datatable(
        cor_df,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          scrollY = "400px",
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel'),
          columnDefs = list(
            list(className = 'dt-center', targets = "_all")
          )
        ),
        rownames = TRUE,
        class = 'cell-border stripe hover'
      ) %>%
        formatStyle(
          columns = colnames(cor_df),
          backgroundColor = styleInterval(
            cuts = c(-0.7, -0.3, 0.3, 0.7),
            values = c('#E74C3C', '#F39C12', 'white', '#4A90E2', '#27AE60')
          )
        )
    })
    
    # Identify strong correlations
    strong_cor <- reactive({
      cor_mat <- cor_matrix()
      
      if (is.null(cor_mat)) {
        return(NULL)
      }
      
      # Get upper triangle
      cor_mat[lower.tri(cor_mat, diag = TRUE)] <- NA
      
      # Convert to long format
      cor_long <- as.data.frame(as.table(cor_mat))
      names(cor_long) <- c("Variable1", "Variable2", "Correlation")
      
      # Filter by threshold
      cor_long <- cor_long %>%
        filter(!is.na(Correlation)) %>%
        filter(abs(Correlation) >= input$cor_threshold) %>%
        mutate(
          Abs_Correlation = abs(Correlation),
          Strength = case_when(
            Abs_Correlation >= 0.7 ~ "Strong",
            Abs_Correlation >= 0.3 ~ "Moderate",
            TRUE ~ "Weak"
          ),
          Direction = ifelse(Correlation > 0, "Positive", "Negative")
        ) %>%
        arrange(desc(Abs_Correlation))
      
      return(cor_long)
    })
    
    # Render strong correlations table
    output$strong_correlations <- renderDT({
      strong <- strong_cor()
      
      if (is.null(strong)) {
        return(
          datatable(
            data.frame(Message = "Insufficient data for correlation analysis"),
            options = list(dom = 't'),
            rownames = FALSE
          )
        )
      }
      
      if (nrow(strong) == 0) {
        return(
          datatable(
            data.frame(Message = paste("No correlations found above threshold:", 
                                      input$cor_threshold)),
            options = list(dom = 't'),
            rownames = FALSE
          )
        )
      }
      
      # Select columns to display
      display_df <- strong %>%
        select(Variable1, Variable2, Correlation, Strength, Direction)
      
      datatable(
        display_df,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv'),
          columnDefs = list(
            list(className = 'dt-center', targets = "_all")
          )
        ),
        rownames = FALSE,
        class = 'cell-border stripe hover'
      ) %>%
        formatRound('Correlation', 3) %>%
        formatStyle(
          'Correlation',
          background = styleColorBar(range(display_df$Correlation), '#4A90E2'),
          backgroundSize = '100% 90%',
          backgroundRepeat = 'no-repeat',
          backgroundPosition = 'center'
        ) %>%
        formatStyle(
          'Strength',
          backgroundColor = styleEqual(
            c('Strong', 'Moderate', 'Weak'),
            c('#27AE60', '#F39C12', '#E74C3C')
          ),
          color = 'white',
          fontWeight = 'bold'
        )
    })
  })
}
