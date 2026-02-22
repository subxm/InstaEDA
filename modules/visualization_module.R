# ============================================================================
# Visualization Module
# Generates dynamic, interactive visualizations
# ============================================================================

visualizationModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Visualization Controls",
        status = "primary",
        solidHeader = TRUE,
        width = 3,
        
        selectInput(
          ns("plot_type"),
          "Select Plot Type:",
          choices = c(
            "Histogram" = "histogram",
            "Density Plot" = "density",
            "Box Plot" = "boxplot",
            "Violin Plot" = "violin",
            "Bar Chart" = "bar",
            "Scatter Plot" = "scatter",
            "Line Plot" = "line"
          ),
          selected = "histogram"
        ),
        
        uiOutput(ns("x_variable_ui")),
        uiOutput(ns("y_variable_ui")),
        uiOutput(ns("color_variable_ui")),
        
        hr(),
        
        sliderInput(
          ns("bins"),
          "Number of Bins (Histogram):",
          min = 5,
          max = 50,
          value = 30,
          step = 5
        ),
        
        checkboxInput(
          ns("show_mean"),
          "Show Mean Line",
          value = FALSE
        ),
        
        actionButton(
          ns("generate_plot"),
          "Generate Plot",
          class = "btn-primary btn-block",
          icon = icon("chart-line")
        )
      ),
      
      box(
        title = "Visualization",
        status = "primary",
        solidHeader = TRUE,
        width = 9,
        plotlyOutput(ns("main_plot"), height = "600px")
      )
    )
  )
}

visualizationModuleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # Dynamic X variable selector
    output$x_variable_ui <- renderUI({
      req(data())
      df <- data()
      
      # Get appropriate columns based on plot type
      if (input$plot_type %in% c("histogram", "density", "boxplot", "violin")) {
        choices <- names(df)[sapply(df, is.numeric)]
      } else if (input$plot_type == "bar") {
        choices <- names(df)[sapply(df, function(x) is.character(x) | is.factor(x))]
      } else {
        choices <- names(df)
      }
      
      selectInput(
        session$ns("x_var"),
        "X Variable:",
        choices = choices,
        selected = choices[1]
      )
    })
    
    # Dynamic Y variable selector (for scatter and line plots)
    output$y_variable_ui <- renderUI({
      req(data())
      
      if (input$plot_type %in% c("scatter", "line")) {
        df <- data()
        numeric_cols <- names(df)[sapply(df, is.numeric)]
        
        selectInput(
          session$ns("y_var"),
          "Y Variable:",
          choices = numeric_cols,
          selected = if(length(numeric_cols) > 1) numeric_cols[2] else numeric_cols[1]
        )
      }
    })
    
    # Dynamic color variable selector
    output$color_variable_ui <- renderUI({
      req(data())
      
      if (input$plot_type %in% c("scatter", "boxplot", "violin")) {
        df <- data()
        factor_cols <- names(df)[sapply(df, function(x) is.character(x) | is.factor(x))]
        
        if (length(factor_cols) > 0) {
          selectInput(
            session$ns("color_var"),
            "Color By (Optional):",
            choices = c("None" = "", factor_cols),
            selected = ""
          )
        }
      }
    })
    
    # Main plotting function
    plot_data <- eventReactive(input$generate_plot, {
      req(data(), input$x_var)
      
      list(
        data = data(),
        plot_type = input$plot_type,
        x_var = input$x_var,
        y_var = input$y_var,
        color_var = input$color_var,
        bins = input$bins,
        show_mean = input$show_mean
      )
    })
    
    # Render main plot
    output$main_plot <- renderPlotly({
      req(plot_data())
      
      params <- plot_data()
      df <- params$data
      
      # Generate plot based on type
      p <- switch(
        params$plot_type,
        "histogram" = create_histogram(df, params),
        "density" = create_density(df, params),
        "boxplot" = create_boxplot(df, params),
        "violin" = create_violin(df, params),
        "bar" = create_barplot(df, params),
        "scatter" = create_scatter(df, params),
        "line" = create_lineplot(df, params)
      )
      
      ggplotly(p, tooltip = "all") %>%
        layout(hovermode = 'closest')
    })
    
    # Histogram
    create_histogram <- function(df, params) {
      x_data <- df[[params$x_var]]
      x_data <- x_data[!is.na(x_data)]
      
      p <- ggplot(data.frame(x = x_data), aes(x = x)) +
        geom_histogram(bins = params$bins, fill = "#4A90E2", alpha = 0.7, color = "white") +
        labs(
          title = paste("Histogram of", params$x_var),
          x = params$x_var,
          y = "Frequency"
        ) +
        theme_instaeda()
      
      if (params$show_mean) {
        mean_val <- mean(x_data, na.rm = TRUE)
        p <- p + geom_vline(xintercept = mean_val, color = "#E74C3C", 
                            linetype = "dashed", size = 1)
      }
      
      return(p)
    }
    
    # Density plot
    create_density <- function(df, params) {
      x_data <- df[[params$x_var]]
      x_data <- x_data[!is.na(x_data)]
      
      p <- ggplot(data.frame(x = x_data), aes(x = x)) +
        geom_density(fill = "#4A90E2", alpha = 0.6, color = "#2C3E50") +
        labs(
          title = paste("Density Plot of", params$x_var),
          x = params$x_var,
          y = "Density"
        ) +
        theme_instaeda()
      
      if (params$show_mean) {
        mean_val <- mean(x_data, na.rm = TRUE)
        p <- p + geom_vline(xintercept = mean_val, color = "#E74C3C", 
                            linetype = "dashed", size = 1)
      }
      
      return(p)
    }
    
    # Boxplot
    create_boxplot <- function(df, params) {
      plot_df <- df %>%
        select(x = params$x_var) %>%
        filter(!is.na(x))
      
      if (!is.null(params$color_var) && params$color_var != "") {
        plot_df$color <- df[[params$color_var]]
        p <- ggplot(plot_df, aes(x = color, y = x, fill = color)) +
          geom_boxplot(alpha = 0.7) +
          scale_fill_viridis_d() +
          theme(legend.position = "none")
      } else {
        p <- ggplot(plot_df, aes(x = "", y = x)) +
          geom_boxplot(fill = "#4A90E2", alpha = 0.7)
      }
      
      p <- p +
        labs(
          title = paste("Box Plot of", params$x_var),
          x = "",
          y = params$x_var
        ) +
        theme_instaeda()
      
      return(p)
    }
    
    # Violin plot
    create_violin <- function(df, params) {
      plot_df <- df %>%
        select(x = params$x_var) %>%
        filter(!is.na(x))
      
      if (!is.null(params$color_var) && params$color_var != "") {
        plot_df$color <- df[[params$color_var]]
        p <- ggplot(plot_df, aes(x = color, y = x, fill = color)) +
          geom_violin(alpha = 0.7, draw_quantiles = c(0.25, 0.5, 0.75)) +
          scale_fill_viridis_d() +
          theme(legend.position = "none")
      } else {
        p <- ggplot(plot_df, aes(x = "", y = x)) +
          geom_violin(fill = "#4A90E2", alpha = 0.7, draw_quantiles = c(0.25, 0.5, 0.75))
      }
      
      p <- p +
        labs(
          title = paste("Violin Plot of", params$x_var),
          x = "",
          y = params$x_var
        ) +
        theme_instaeda()
      
      return(p)
    }
    
    # Bar chart
    create_barplot <- function(df, params) {
      x_data <- df[[params$x_var]]
      
      # Count frequencies
      freq_table <- as.data.frame(table(x_data))
      names(freq_table) <- c("Category", "Count")
      
      # Limit to top 20 categories if too many
      if (nrow(freq_table) > 20) {
        freq_table <- freq_table %>%
          arrange(desc(Count)) %>%
          head(20)
      }
      
      p <- ggplot(freq_table, aes(x = reorder(Category, Count), y = Count)) +
        geom_bar(stat = "identity", fill = "#4A90E2", alpha = 0.7) +
        coord_flip() +
        labs(
          title = paste("Bar Chart of", params$x_var),
          x = params$x_var,
          y = "Count"
        ) +
        theme_instaeda()
      
      return(p)
    }
    
    # Scatter plot
    create_scatter <- function(df, params) {
      req(params$y_var)
      
      plot_df <- df %>%
        select(x = params$x_var, y = params$y_var) %>%
        filter(!is.na(x) & !is.na(y))
      
      if (!is.null(params$color_var) && params$color_var != "") {
        plot_df$color <- df[[params$color_var]][!is.na(df[[params$x_var]]) & !is.na(df[[params$y_var]])]
        p <- ggplot(plot_df, aes(x = x, y = y, color = color)) +
          geom_point(alpha = 0.6, size = 2) +
          scale_color_viridis_d() +
          labs(color = params$color_var)
      } else {
        p <- ggplot(plot_df, aes(x = x, y = y)) +
          geom_point(alpha = 0.6, size = 2, color = "#4A90E2")
      }
      
      p <- p +
        geom_smooth(method = "lm", se = TRUE, color = "#E74C3C", linetype = "dashed") +
        labs(
          title = paste("Scatter Plot:", params$x_var, "vs", params$y_var),
          x = params$x_var,
          y = params$y_var
        ) +
        theme_instaeda()
      
      return(p)
    }
    
    # Line plot
    create_lineplot <- function(df, params) {
      req(params$y_var)
      
      plot_df <- df %>%
        select(x = params$x_var, y = params$y_var) %>%
        filter(!is.na(x) & !is.na(y)) %>%
        arrange(x)
      
      p <- ggplot(plot_df, aes(x = x, y = y)) +
        geom_line(color = "#4A90E2", size = 1) +
        geom_point(color = "#2C3E50", size = 2, alpha = 0.6) +
        labs(
          title = paste("Line Plot:", params$x_var, "vs", params$y_var),
          x = params$x_var,
          y = params$y_var
        ) +
        theme_instaeda()
      
      return(p)
    }
  })
}
