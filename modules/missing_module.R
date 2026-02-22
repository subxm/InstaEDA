# ============================================================================
# Missing Data Module
# Analyzes and visualizes missing values
# ============================================================================

missingModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      # Missing values table
      box(
        title = "Missing Values Analysis",
        status = "warning",
        solidHeader = TRUE,
        width = 6,
        collapsible = TRUE,
        DTOutput(ns("missing_table"))
      ),
      
      # Missing values visualization
      box(
        title = "Missing Values Visualization",
        status = "warning",
        solidHeader = TRUE,
        width = 6,
        collapsible = TRUE,
        plotlyOutput(ns("missing_plot"), height = "400px")
      )
    ),
    
    fluidRow(
      box(
        title = "Missing Data Heatmap",
        status = "warning",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        plotlyOutput(ns("missing_heatmap"), height = "500px")
      )
    )
  )
}

missingModuleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # Calculate missing statistics
    missing_stats <- reactive({
      req(data())
      df <- data()
      
      missing_count <- colSums(is.na(df))
      missing_pct <- round((missing_count / nrow(df)) * 100, 2)
      
      result <- data.frame(
        Column = names(df),
        Missing_Count = missing_count,
        Missing_Percentage = missing_pct,
        Total_Rows = nrow(df),
        stringsAsFactors = FALSE
      )
      
      result <- result %>%
        arrange(desc(Missing_Percentage))
      
      return(result)
    })
    
    # Render missing values table
    output$missing_table <- renderDT({
      stats <- missing_stats()
      
      if (sum(stats$Missing_Count) == 0) {
        return(
          datatable(
            data.frame(Message = "No missing values found in the dataset!"),
            options = list(dom = 't'),
            rownames = FALSE
          )
        )
      }
      
      # Filter to show only columns with missing values
      stats_filtered <- stats %>%
        filter(Missing_Count > 0)
      
      datatable(
        stats_filtered,
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
        formatStyle(
          'Missing_Percentage',
          background = styleColorBar(range(stats_filtered$Missing_Percentage), '#F39C12'),
          backgroundSize = '100% 90%',
          backgroundRepeat = 'no-repeat',
          backgroundPosition = 'center'
        )
    })
    
    # Render missing values bar plot
    output$missing_plot <- renderPlotly({
      stats <- missing_stats()
      
      # Filter columns with missing values
      stats_filtered <- stats %>%
        filter(Missing_Count > 0)
      
      if (nrow(stats_filtered) == 0) {
        p <- ggplot() +
          annotate("text", x = 0.5, y = 0.5, 
                   label = "No Missing Values!", 
                   size = 6, color = "#27AE60") +
          theme_void()
        return(ggplotly(p))
      }
      
      # Create bar plot
      p <- ggplot(stats_filtered, aes(x = reorder(Column, Missing_Percentage), 
                                       y = Missing_Percentage)) +
        geom_bar(stat = "identity", fill = "#F39C12", alpha = 0.8) +
        geom_text(aes(label = paste0(Missing_Percentage, "%")), 
                  hjust = -0.1, size = 3) +
        coord_flip() +
        labs(
          title = "Missing Data by Column",
          x = "Column Name",
          y = "Missing Percentage (%)"
        ) +
        theme_instaeda() +
        ylim(0, max(stats_filtered$Missing_Percentage) * 1.15)
      
      ggplotly(p, tooltip = c("x", "y"))
    })
    
    # Render missing data heatmap
    output$missing_heatmap <- renderPlotly({
      req(data())
      df <- data()
      
      # Create missing data matrix (1 = missing, 0 = present)
      missing_matrix <- is.na(df) * 1
      
      # Sample rows if dataset is large
      if (nrow(missing_matrix) > 200) {
        sample_idx <- sample(1:nrow(missing_matrix), 200)
        missing_matrix <- missing_matrix[sample_idx, ]
      }
      
      # Check if there are any missing values
      if (sum(missing_matrix) == 0) {
        p <- ggplot() +
          annotate("text", x = 0.5, y = 0.5, 
                   label = "No Missing Values in Dataset!", 
                   size = 6, color = "#27AE60") +
          theme_void()
        return(ggplotly(p))
      }
      
      # Create heatmap using plotly
      plot_ly(
        z = t(as.matrix(missing_matrix)),
        x = 1:nrow(missing_matrix),
        y = colnames(missing_matrix),
        type = "heatmap",
        colors = c("#27AE60", "#E74C3C"),
        showscale = FALSE,
        hovertemplate = paste(
          '<b>Row:</b> %{x}<br>',
          '<b>Column:</b> %{y}<br>',
          '<b>Status:</b> %{z:,.0f}<br>',
          '<extra></extra>'
        )
      ) %>%
        layout(
          title = list(text = "Missing Data Pattern (Green = Present, Red = Missing)", 
                       x = 0.5),
          xaxis = list(title = "Row Index"),
          yaxis = list(title = "Columns", tickfont = list(size = 10)),
          margin = list(l = 150)
        )
    })
  })
}
