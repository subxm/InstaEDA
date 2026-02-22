# ============================================================================
# Report Module
# Generates downloadable HTML/PDF reports
# ============================================================================

reportModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Report Generation",
        status = "info",
        solidHeader = TRUE,
        width = 12,
        
        fluidRow(
          column(
            width = 6,
            h4("Report Configuration"),
            checkboxGroupInput(
              ns("report_sections"),
              "Include Sections:",
              choices = c(
                "Overview" = "overview",
                "Summary Statistics" = "summary",
                "Missing Values" = "missing",
                "Correlation Analysis" = "correlation",
                "Visualizations" = "viz"
              ),
              selected = c("overview", "summary", "missing", "correlation")
            )
          ),
          column(
            width = 6,
            h4("Report Format"),
            radioButtons(
              ns("report_format"),
              "Output Format:",
              choices = c("HTML" = "html", "PDF" = "pdf"),
              selected = "html"
            ),
            br(),
            downloadButton(
              ns("download_report"),
              "Generate & Download Report",
              class = "btn-info btn-lg",
              icon = icon("download")
            )
          )
        )
      )
    ),
    
    fluidRow(
      box(
        title = "Report Preview",
        status = "info",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        htmlOutput(ns("report_preview"))
      )
    )
  )
}

reportModuleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # Report preview
    output$report_preview <- renderUI({
      req(data())
      
      tags$div(
        style = "padding: 20px; background-color: #f9f9f9; border-radius: 5px;",
        tags$h3("Your report will include:"),
        tags$ul(
          if ("overview" %in% input$report_sections) 
            tags$li(icon("check", class = "text-success"), " Dataset Overview & Dimensions"),
          if ("summary" %in% input$report_sections) 
            tags$li(icon("check", class = "text-success"), " Summary Statistics"),
          if ("missing" %in% input$report_sections) 
            tags$li(icon("check", class = "text-success"), " Missing Values Analysis"),
          if ("correlation" %in% input$report_sections) 
            tags$li(icon("check", class = "text-success"), " Correlation Analysis"),
          if ("viz" %in% input$report_sections) 
            tags$li(icon("check", class = "text-success"), " Key Visualizations")
        ),
        tags$hr(),
        tags$p(
          icon("info-circle"),
          " The report will be generated in ",
          tags$strong(toupper(input$report_format)),
          " format."
        )
      )
    })
    
    # Generate report
    output$download_report <- downloadHandler(
      filename = function() {
        paste0("InstaEDA_Report_", format(Sys.time(), "%Y%m%d_%H%M%S"), 
               ".", input$report_format)
      },
      
      content = function(file) {
        # Show progress notification
        progress <- shiny::Progress$new()
        progress$set(message = "Generating report...", value = 0)
        on.exit(progress$close())
        
        # Get data
        df <- data()
        
        # Create temporary Rmd file
        temp_rmd <- tempfile(fileext = ".Rmd")
        
        # Generate Rmd content
        rmd_content <- generate_rmd_content(
          df, 
          input$report_sections,
          progress
        )
        
        # Write Rmd file
        writeLines(rmd_content, temp_rmd)
        
        # Render report
        progress$set(value = 0.8, detail = "Rendering document...")
        
        tryCatch({
          rmarkdown::render(
            temp_rmd,
            output_format = if (input$report_format == "html") 
              "html_document" else "pdf_document",
            output_file = file,
            quiet = TRUE,
            envir = new.env()
          )
          
          progress$set(value = 1, detail = "Complete!")
          
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
    
    # Function to generate Rmd content
    generate_rmd_content <- function(df, sections, progress = NULL) {
      
      # Header
      content <- c(
        "---",
        "title: 'InstaEDA: Automated Exploratory Data Analysis Report'",
        paste0("date: '", format(Sys.time(), "%B %d, %Y %H:%M:%S"), "'"),
        "output:",
        "  html_document:",
        "    theme: cosmo",
        "    toc: true",
        "    toc_float: true",
        "    code_folding: hide",
        "  pdf_document:",
        "    toc: true",
        "---",
        "",
        "```{r setup, include=FALSE}",
        "knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)",
        "library(ggplot2)",
        "library(dplyr)",
        "library(knitr)",
        "```",
        "",
        "# Executive Summary",
        "",
        "This report presents an automated exploratory data analysis of the uploaded dataset.",
        ""
      )
      
      if (!is.null(progress)) progress$set(value = 0.2, detail = "Building overview...")
      
      # Overview section
      if ("overview" %in% sections) {
        content <- c(content,
          "# Dataset Overview",
          "",
          paste("- **Total Rows:**", nrow(df)),
          paste("- **Total Columns:**", ncol(df)),
          paste("- **Numeric Columns:**", sum(sapply(df, is.numeric))),
          paste("- **Factor Columns:**", sum(sapply(df, function(x) is.character(x) | is.factor(x)))),
          "",
          "## Data Structure",
          "",
          "```{r}",
          "str(data.frame(",
          paste0("  ", names(df), " = c('", sapply(df, class), "')"),
          "))",
          "```",
          ""
        )
      }
      
      if (!is.null(progress)) progress$set(value = 0.4, detail = "Adding statistics...")
      
      # Summary statistics section
      if ("summary" %in% sections) {
        numeric_cols <- names(df)[sapply(df, is.numeric)]
        
        if (length(numeric_cols) > 0) {
          content <- c(content,
            "# Summary Statistics",
            "",
            "```{r}",
            "summary_stats <- data.frame(",
            "  Variable = character(),",
            "  Mean = numeric(),",
            "  Median = numeric(),",
            "  SD = numeric(),",
            "  Min = numeric(),",
            "  Max = numeric(),",
            "  stringsAsFactors = FALSE",
            ")",
            "",
            paste0("for (col in c('", paste(numeric_cols, collapse = "', '"), "')) {"),
            "  x <- df[[col]]",
            "  summary_stats <- rbind(summary_stats, data.frame(",
            "    Variable = col,",
            "    Mean = mean(x, na.rm = TRUE),",
            "    Median = median(x, na.rm = TRUE),",
            "    SD = sd(x, na.rm = TRUE),",
            "    Min = min(x, na.rm = TRUE),",
            "    Max = max(x, na.rm = TRUE)",
            "  ))",
            "}",
            "",
            "kable(summary_stats, digits = 2, caption = 'Summary Statistics for Numeric Variables')",
            "```",
            ""
          )
        }
      }
      
      if (!is.null(progress)) progress$set(value = 0.6, detail = "Processing missing values...")
      
      # Missing values section
      if ("missing" %in% sections) {
        content <- c(content,
          "# Missing Values Analysis",
          "",
          "```{r}",
          "missing_count <- colSums(is.na(df))",
          "missing_pct <- round((missing_count / nrow(df)) * 100, 2)",
          "",
          "missing_df <- data.frame(",
          "  Column = names(df),",
          "  Missing_Count = missing_count,",
          "  Missing_Percentage = missing_pct",
          ")",
          "",
          "missing_df <- missing_df[missing_df$Missing_Count > 0, ]",
          "",
          "if (nrow(missing_df) > 0) {",
          "  kable(missing_df, row.names = FALSE, caption = 'Missing Values Summary')",
          "} else {",
          "  cat('No missing values found in the dataset!')",
          "}",
          "```",
          ""
        )
      }
      
      return(content)
    }
  })
}
