# ============================================================================
# InstaEDA: Automated Exploratory Data Analysis Dashboard
# Global Configuration File
# ============================================================================

# Load Required Libraries
# ============================================================================
suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(dplyr)
  library(ggplot2)
  library(plotly)
  library(DT)
  library(tidyr)
  library(corrplot)
  library(scales)
  library(viridis)
  library(rmarkdown)
})

# Global Options
# ============================================================================
options(shiny.maxRequestSize = 50*1024^2)  # Max file size: 50MB
options(digits = 3)

# Custom Theme Colors
# ============================================================================
PRIMARY_COLOR <- "#4A90E2"
SECONDARY_COLOR <- "#2C3E50"
SUCCESS_COLOR <- "#27AE60"
WARNING_COLOR <- "#F39C12"
DANGER_COLOR <- "#E74C3C"

# Helper Functions
# ============================================================================

# Function to detect column types
detect_column_types <- function(df) {
  list(
    numeric_cols = names(df)[sapply(df, is.numeric)],
    factor_cols = names(df)[sapply(df, function(x) is.character(x) | is.factor(x))],
    all_cols = names(df)
  )
}

# Function to calculate missing value statistics
calculate_missing_stats <- function(df) {
  missing_count <- colSums(is.na(df))
  missing_pct <- round((missing_count / nrow(df)) * 100, 2)
  
  data.frame(
    Column = names(df),
    Missing_Count = missing_count,
    Missing_Percentage = missing_pct,
    stringsAsFactors = FALSE
  ) %>%
    filter(Missing_Count > 0) %>%
    arrange(desc(Missing_Percentage))
}

# Function to generate summary statistics
generate_summary_stats <- function(df) {
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  
  if (length(numeric_cols) == 0) {
    return(NULL)
  }
  
  summary_df <- df %>%
    select(all_of(numeric_cols)) %>%
    summarise(across(everything(), 
                     list(Mean = ~mean(.x, na.rm = TRUE),
                          Median = ~median(.x, na.rm = TRUE),
                          SD = ~sd(.x, na.rm = TRUE),
                          Min = ~min(.x, na.rm = TRUE),
                          Max = ~max(.x, na.rm = TRUE)),
                     .names = "{.col}_{.fn}"))
  
  # Reshape for better display
  summary_long <- summary_df %>%
    pivot_longer(cols = everything(),
                 names_to = c("Variable", "Statistic"),
                 names_sep = "_",
                 values_to = "Value") %>%
    pivot_wider(names_from = Statistic, values_from = Value)
  
  return(summary_long)
}

# Function to safely calculate correlation
safe_correlation <- function(df) {
  numeric_df <- df %>% select(where(is.numeric))
  
  if (ncol(numeric_df) < 2) {
    return(NULL)
  }
  
  cor_matrix <- cor(numeric_df, use = "pairwise.complete.obs")
  return(cor_matrix)
}

# Custom CSS for better styling
custom_css <- "
  .info-box {
    min-height: 90px;
  }
  
  .info-box-icon {
    height: 90px;
    line-height: 90px;
  }
  
  .info-box-content {
    padding: 5px 10px;
    margin-left: 90px;
  }
  
  .small-box .icon-large {
    font-size: 50px;
  }
  
  .content-wrapper {
    background-color: #ecf0f5;
  }
  
  .box {
    border-top: 3px solid #4A90E2;
  }
  
  .dataTables_wrapper .dataTables_length,
  .dataTables_wrapper .dataTables_filter {
    padding: 10px;
  }
"

# Visualization themes
# ============================================================================
theme_instaeda <- function() {
  theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 11, hjust = 0.5),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "right",
      legend.title = element_text(size = 10, face = "bold"),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA)
    )
}

# Print startup message
message("InstaEDA Global Configuration Loaded Successfully!")
