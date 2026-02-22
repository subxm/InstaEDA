# ============================================================================
# Upload Module
# Handles CSV file upload and validation
# ============================================================================

uploadModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fileInput(
      ns("file"),
      "Upload CSV File:",
      accept = c(".csv", "text/csv", "text/comma-separated-values"),
      buttonLabel = "Browse...",
      placeholder = "No file selected"
    ),
    uiOutput(ns("file_info"))
  )
}

uploadModuleServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Reactive value to store uploaded data
    uploaded_data <- reactiveVal(NULL)
    
    # Observe file upload
    observeEvent(input$file, {
      req(input$file)
      
      tryCatch({
        # Read CSV file
        df <- read.csv(
          input$file$datapath,
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
        
        # Validate data
        if (nrow(df) == 0) {
          showNotification(
            "Error: Uploaded file is empty!",
            type = "error",
            duration = 5
          )
          return(NULL)
        }
        
        if (ncol(df) == 0) {
          showNotification(
            "Error: No columns found in the file!",
            type = "error",
            duration = 5
          )
          return(NULL)
        }
        
        # Store the data
        uploaded_data(df)
        
        # Show success notification
        showNotification(
          paste0("File uploaded successfully! (", 
                 nrow(df), " rows, ", 
                 ncol(df), " columns)"),
          type = "message",
          duration = 3
        )
        
      }, error = function(e) {
        showNotification(
          paste("Error reading file:", e$message),
          type = "error",
          duration = 5
        )
        uploaded_data(NULL)
      })
    })
    
    # Display file information
    output$file_info <- renderUI({
      req(input$file)
      
      tags$div(
        style = "padding: 10px; background-color: #e8f4fd; border-radius: 5px; margin-top: 10px;",
        tags$strong("File Name: "), tags$span(input$file$name), tags$br(),
        tags$strong("File Size: "), tags$span(format(
          structure(input$file$size, class = "object_size"), 
          units = "auto"
        ))
      )
    })
    
    # Return the reactive data
    return(uploaded_data)
  })
}
