# ============================================================================
# InstaEDA Package Installation Script
# Run this script before launching the application for the first time
# ============================================================================

cat("
================================================================================
  InstaEDA - Automated Exploratory Data Analysis Dashboard
  Package Installation Script
================================================================================

This script will install all required R packages for InstaEDA.
Please wait while packages are being installed...

")

# List of required packages
required_packages <- c(
  "shiny",           # Web application framework
  "shinydashboard",  # Dashboard UI components
  "dplyr",           # Data manipulation
  "tidyr",           # Data tidying
  "ggplot2",         # Data visualization
  "plotly",          # Interactive plots
  "DT",              # Interactive tables
  "corrplot",        # Correlation plots
  "scales",          # Scale functions
  "viridis",         # Color palettes
  "rmarkdown"        # Report generation
)

# Function to check if package is installed
is_installed <- function(pkg) {
  return(pkg %in% installed.packages()[, "Package"])
}

# Function to install missing packages
install_missing_packages <- function(packages) {
  
  cat("\nChecking installed packages...\n")
  cat("================================\n\n")
  
  missing_packages <- c()
  installed_count <- 0
  
  # Check each package
  for (pkg in packages) {
    if (is_installed(pkg)) {
      cat(sprintf("✓ %s is already installed\n", pkg))
      installed_count <- installed_count + 1
    } else {
      cat(sprintf("✗ %s is NOT installed\n", pkg))
      missing_packages <- c(missing_packages, pkg)
    }
  }
  
  # Summary
  cat("\n================================\n")
  cat(sprintf("Summary: %d/%d packages installed\n", 
              installed_count, length(packages)))
  cat("================================\n\n")
  
  # Install missing packages
  if (length(missing_packages) > 0) {
    cat("Installing missing packages...\n")
    cat("This may take several minutes.\n\n")
    
    for (pkg in missing_packages) {
      cat(sprintf("Installing %s...\n", pkg))
      
      tryCatch({
        install.packages(pkg, 
                        dependencies = TRUE, 
                        repos = "https://cloud.r-project.org/",
                        quiet = FALSE)
        cat(sprintf("✓ %s installed successfully!\n\n", pkg))
      }, error = function(e) {
        cat(sprintf("✗ Failed to install %s: %s\n\n", pkg, e$message))
      })
    }
  } else {
    cat("All required packages are already installed!\n\n")
  }
}

# Run installation
install_missing_packages(required_packages)

# Verify installation
cat("\n================================================================================\n")
cat("Verifying installation...\n")
cat("================================================================================\n\n")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_installed(pkg)) {
    cat(sprintf("✓ %s: OK\n", pkg))
  } else {
    cat(sprintf("✗ %s: MISSING\n", pkg))
    all_installed <- FALSE
  }
}

# Final message
cat("\n================================================================================\n")
if (all_installed) {
  cat("SUCCESS! All packages installed successfully.\n")
  cat("You can now run the InstaEDA application.\n\n")
  cat("To start the app, run:\n")
  cat("  shiny::runApp()\n")
} else {
  cat("WARNING: Some packages failed to install.\n")
  cat("Please try installing them manually:\n\n")
  for (pkg in required_packages) {
    if (!is_installed(pkg)) {
      cat(sprintf("  install.packages('%s')\n", pkg))
    }
  }
}
cat("================================================================================\n")

# Optional: Install PDF dependencies
cat("\n\nOptional: Install PDF Report Dependencies\n")
cat("==========================================\n")
cat("For PDF report generation, you need LaTeX.\n")
cat("Would you like to install tinytex? (Recommended)\n\n")

install_tinytex <- readline(prompt = "Install tinytex for PDF support? (y/n): ")

if (tolower(install_tinytex) == "y") {
  cat("\nInstalling tinytex...\n")
  if (!is_installed("tinytex")) {
    install.packages("tinytex")
  }
  tinytex::install_tinytex()
  cat("✓ tinytex installed! PDF reports are now available.\n")
} else {
  cat("Skipping tinytex installation. HTML reports will still work.\n")
}

cat("\n\nSetup complete! Thank you for using InstaEDA.\n")
