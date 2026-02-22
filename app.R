# ============================================================================
# InstaEDA: Automated Exploratory Data Analysis Dashboard
# Main Application File
# ============================================================================

# Source global configuration
source("global.R")

# Source all modules
source("modules/upload_module.R")
source("modules/overview_module.R")
source("modules/missing_module.R")
source("modules/summary_stats_module.R")
source("modules/visualization_module.R")
source("modules/correlation_module.R")
source("modules/outliers_module.R")
source("modules/report_module.R")

# ============================================================================
# USER INTERFACE
# ============================================================================

ui <- dashboardPage(
  skin = "blue",
  
  # Header
  dashboardHeader(
    title = "Automated EDA Tool",
    titleWidth = 300
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 300,
    
    sidebarMenu(
      id = "sidebar",
      
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Missing Data", tabName = "missing", icon = icon("exclamation-triangle")),
      menuItem("Summary Stats", tabName = "summary", icon = icon("chart-bar")),
      menuItem("Visualizations", tabName = "viz", icon = icon("chart-line")),
      menuItem("Correlation", tabName = "correlation", icon = icon("project-diagram")),
      menuItem("Outliers", tabName = "outliers", icon = icon("exclamation-circle"))
    ),
    
    br(),
    
    # File upload section
    div(style = "padding: 15px;",
      uploadModuleUI("upload")
    ),
    
    br(),
    
    # Variable selector
    div(style = "padding: 15px;",
      selectInput(
        "select_variable",
        "Select Variable:",
        choices = NULL
      )
    ),
    
    br(),
    
    # Download report button
    div(style = "padding: 15px;",
      downloadButton(
        "download_report_quick",
        "Download Report",
        class = "btn-primary btn-block",
        icon = icon("file-download")
      )
    )
  ),
  
  # Body
  dashboardBody(
    
    # Include custom CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
      tags$style(HTML(custom_css))
    ),
    
    # Tab items
    tabItems(
      
      # Overview tab
      tabItem(
        tabName = "overview",
        h2("Dataset Overview", style = "font-weight: bold;"),
        hr(),
        overviewModuleUI("overview")
      ),
      
      # Missing data tab
      tabItem(
        tabName = "missing",
        h2("Missing Values Analysis", style = "font-weight: bold;"),
        hr(),
        missingModuleUI("missing")
      ),
      
      # Summary statistics tab
      tabItem(
        tabName = "summary",
        h2("Summary Statistics", style = "font-weight: bold;"),
        hr(),
        summaryStatsModuleUI("summary")
      ),
      
      # Visualizations tab
      tabItem(
        tabName = "viz",
        h2("Data Visualizations", style = "font-weight: bold;"),
        hr(),
        visualizationModuleUI("viz")
      ),
      
      # Correlation tab
      tabItem(
        tabName = "correlation",
        h2("Correlation Analysis", style = "font-weight: bold;"),
        hr(),
        correlationModuleUI("correlation")
      ),
      
      # Outliers tab
      tabItem(
        tabName = "outliers",
        h2("Outlier Detection", style = "font-weight: bold;"),
        hr(),
        outliersModuleUI("outliers")
      )
    )
  )
)

# ============================================================================
# SERVER
# ============================================================================

server <- function(input, output, session) {
  
  # Upload module - returns reactive data
  uploaded_data <- uploadModuleServer("upload")
  
  # Update variable selector when data is uploaded
  observe({
    req(uploaded_data())
    df <- uploaded_data()
    
    updateSelectInput(
      session,
      "select_variable",
      choices = c("Choose Variable" = "", names(df)),
      selected = ""
    )
  })
  
  # Call all module servers
  overviewModuleServer("overview", uploaded_data)
  missingModuleServer("missing", uploaded_data)
  summaryStatsModuleServer("summary", uploaded_data)
  visualizationModuleServer("viz", uploaded_data)
  correlationModuleServer("correlation", uploaded_data)
  outliersModuleServer("outliers", uploaded_data)
  
  # Quick download report functionality
  output$download_report_quick <- downloadHandler(
    filename = function() {
      paste0("InstaEDA_Report_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".html")
    },
    
    content = function(file) {
      req(uploaded_data())
      
      tryCatch({
        df <- uploaded_data()
        
        # Calculate statistics
        numeric_cols <- names(df)[sapply(df, is.numeric)]
        factor_cols <- names(df)[sapply(df, function(x) is.character(x) | is.factor(x))]
        missing_count <- colSums(is.na(df))
        
        # Generate HTML report
        html_content <- paste0('
<!DOCTYPE html>
<html>
<head>
    <title>InstaEDA Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #4A90E2; border-bottom: 3px solid #4A90E2; padding-bottom: 10px; }
        h2 { color: #2C3E50; margin-top: 30px; border-bottom: 2px solid #ecf0f1; padding-bottom: 8px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th { background-color: #4A90E2; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f1f8ff; }
        .stat-box { display: inline-block; background: #e8f4fd; padding: 15px 25px; margin: 10px; border-radius: 8px; border-left: 4px solid #4A90E2; }
        .stat-label { font-weight: bold; color: #2C3E50; }
        .stat-value { font-size: 24px; color: #4A90E2; font-weight: bold; }
        .section { margin-bottom: 40px; }
        .success { color: #27AE60; font-weight: bold; }
        .warning { color: #F39C12; font-weight: bold; }
        .footer { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 InstaEDA: Automated EDA Report</h1>
        <p><strong>Generated:</strong> ', format(Sys.time(), "%B %d, %Y at %H:%M:%S"), '</p>
        
        <div class="section">
            <h2>📋 Dataset Overview</h2>
            <div class="stat-box">
                <div class="stat-label">Total Rows</div>
                <div class="stat-value">', format(nrow(df), big.mark = ","), '</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">Total Columns</div>
                <div class="stat-value">', format(ncol(df), big.mark = ","), '</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">Numeric Columns</div>
                <div class="stat-value">', length(numeric_cols), '</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">Factor Columns</div>
                <div class="stat-value">', length(factor_cols), '</div>
            </div>
        </div>
        
        <div class="section">
            <h2>📊 Column Information</h2>
            <table>
                <tr>
                    <th>Column Name</th>
                    <th>Data Type</th>
                    <th>Missing Values</th>
                    <th>Missing %</th>
                </tr>',
                paste(sapply(names(df), function(col) {
                  paste0('<tr>
                    <td>', col, '</td>
                    <td>', class(df[[col]])[1], '</td>
                    <td>', missing_count[col], '</td>
                    <td>', round((missing_count[col] / nrow(df)) * 100, 2), '%</td>
                </tr>')
                }), collapse = "\n"),
            '</table>
        </div>
        
        <div class="section">
            <h2>📈 Summary Statistics (Numeric Variables)</h2>',
            if (length(numeric_cols) > 0) {
              paste0('<table>
                <tr>
                    <th>Variable</th>
                    <th>Mean</th>
                    <th>Median</th>
                    <th>Std Dev</th>
                    <th>Min</th>
                    <th>Max</th>
                </tr>',
                paste(sapply(numeric_cols, function(col) {
                  x <- df[[col]]
                  paste0('<tr>
                    <td>', col, '</td>
                    <td>', round(mean(x, na.rm = TRUE), 2), '</td>
                    <td>', round(median(x, na.rm = TRUE), 2), '</td>
                    <td>', round(sd(x, na.rm = TRUE), 2), '</td>
                    <td>', round(min(x, na.rm = TRUE), 2), '</td>
                    <td>', round(max(x, na.rm = TRUE), 2), '</td>
                </tr>')
                }), collapse = "\n"),
              '</table>')
            } else {
              '<p>No numeric variables found in the dataset.</p>'
            },
        '</div>
        
        <div class="section">
            <h2>⚠️ Missing Values Analysis</h2>',
            if (sum(missing_count) > 0) {
              paste0('<p class="warning">Total missing values: ', sum(missing_count), '</p>
              <table>
                <tr>
                    <th>Column</th>
                    <th>Missing Count</th>
                    <th>Missing Percentage</th>
                </tr>',
                paste(sapply(names(df)[missing_count > 0], function(col) {
                  paste0('<tr>
                    <td>', col, '</td>
                    <td>', missing_count[col], '</td>
                    <td>', round((missing_count[col] / nrow(df)) * 100, 2), '%</td>
                </tr>')
                }), collapse = "\n"),
              '</table>')
            } else {
              '<p class="success">✓ No missing values found in the dataset!</p>'
            },
        '</div>
        
        <div class="footer">
            <p>Generated by <strong>InstaEDA</strong> - Automated Exploratory Data Analysis Dashboard</p>
            <p>Built with R and Shiny</p>
        </div>
    </div>
</body>
</html>')
        
        # Write HTML to file
        writeLines(html_content, file)
        
        showNotification(
          "Report generated successfully!",
          type = "message",
          duration = 3
        )
        
      }, error = function(e) {
        showNotification(
          paste("Error generating report:", e$message),
          type = "error",
          duration = 5
        )
      })
    }
  )
  
  # Welcome message on startup
  observe({
    showNotification(
      "Welcome to InstaEDA! Upload a CSV file to begin analysis.",
      type = "message",
      duration = 5
    )
  })
}

# ============================================================================
# RUN APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)
