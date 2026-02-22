# ============================================================================
# InstaEDA - Quick Deployment Script for Posit Connect
# Run this script to deploy your app to Posit Connect Cloud
# ============================================================================

cat("
================================================================================
  InstaEDA - Posit Connect Cloud Deployment Script
================================================================================

This script will help you deploy InstaEDA to Posit Connect Cloud.

")

# Check if rsconnect is installed
if (!require("rsconnect", quietly = TRUE)) {
  cat("Installing rsconnect package...\n")
  install.packages("rsconnect")
  library(rsconnect)
} else {
  library(rsconnect)
  cat("✓ rsconnect package is installed\n\n")
}

# Function to configure account
configure_account <- function() {
  cat("================================================================================\n")
  cat("STEP 1: Configure Your Posit Connect Account\n")
  cat("================================================================================\n\n")
  
  cat("To get your credentials:\n")
  cat("1. Go to https://connect.posit.cloud/\n")
  cat("2. Log in to your account\n")
  cat("3. Click your name (top-right) → Tokens\n")
  cat("4. Click 'New Token'\n")
  cat("5. Copy the token and secret\n\n")
  
  account_name <- readline(prompt = "Enter your account name: ")
  token <- readline(prompt = "Enter your token: ")
  secret <- readline(prompt = "Enter your secret: ")
  
  tryCatch({
    rsconnect::setAccountInfo(
      name = account_name,
      token = token,
      secret = secret
    )
    cat("\n✓ Account configured successfully!\n\n")
    return(TRUE)
  }, error = function(e) {
    cat("\n✗ Error configuring account:", e$message, "\n")
    return(FALSE)
  })
}

# Function to verify files
verify_files <- function() {
  cat("================================================================================\n")
  cat("STEP 2: Verify Required Files\n")
  cat("================================================================================\n\n")
  
  required_files <- c(
    "app.R",
    "global.R",
    "manifest.json",
    "modules/upload_module.R",
    "modules/overview_module.R",
    "modules/missing_module.R",
    "modules/summary_stats_module.R",
    "modules/visualization_module.R",
    "modules/correlation_module.R",
    "modules/outliers_module.R",
    "modules/report_module.R",
    "www/custom.css",
    "sample_data.csv"
  )
  
  all_present <- TRUE
  
  for (file in required_files) {
    if (file.exists(file)) {
      cat("✓", file, "\n")
    } else {
      cat("✗", file, "- MISSING\n")
      all_present <- FALSE
    }
  }
  
  cat("\n")
  
  if (!all_present) {
    cat("⚠️  Some files are missing. Please ensure all files are present.\n")
    return(FALSE)
  } else {
    cat("✓ All required files are present!\n\n")
    return(TRUE)
  }
}

# Function to deploy app
deploy_app <- function() {
  cat("================================================================================\n")
  cat("STEP 3: Deploy to Posit Connect\n")
  cat("================================================================================\n\n")
  
  app_name <- readline(prompt = "Enter app name (default: InstaEDA): ")
  if (app_name == "") {
    app_name <- "InstaEDA"
  }
  
  cat("\nDeploying app...\n")
  cat("This may take 3-5 minutes...\n\n")
  
  tryCatch({
    deployment <- rsconnect::deployApp(
      appDir = ".",
      appName = app_name,
      appTitle = "InstaEDA: Automated EDA Tool",
      launch.browser = FALSE,
      logLevel = "verbose"
    )
    
    cat("\n================================================================================\n")
    cat("SUCCESS! App deployed successfully!\n")
    cat("================================================================================\n\n")
    
    # Get deployment info
    app_info <- rsconnect::deployments(".")
    if (nrow(app_info) > 0) {
      cat("Your app is now live at:\n")
      cat(paste0("https://", app_info$server[1], "/", app_info$account[1], "/", app_name, "/\n\n"))
    }
    
    return(TRUE)
    
  }, error = function(e) {
    cat("\n✗ Deployment failed:", e$message, "\n\n")
    cat("Troubleshooting tips:\n")
    cat("1. Check your internet connection\n")
    cat("2. Verify your credentials are correct\n")
    cat("3. Ensure all required packages are installed\n")
    cat("4. Check the deployment logs above for specific errors\n\n")
    return(FALSE)
  })
}

# Main deployment workflow
main <- function() {
  
  # Check if already configured
  accounts <- rsconnect::accounts()
  
  if (nrow(accounts) == 0) {
    cat("No Posit Connect account configured.\n\n")
    if (!configure_account()) {
      cat("\nDeployment cancelled.\n")
      return(invisible(NULL))
    }
  } else {
    cat("✓ Posit Connect account already configured\n")
    cat("  Account:", accounts$name[1], "\n\n")
    
    reconfigure <- readline(prompt = "Reconfigure account? (y/n): ")
    if (tolower(reconfigure) == "y") {
      if (!configure_account()) {
        cat("\nDeployment cancelled.\n")
        return(invisible(NULL))
      }
    }
  }
  
  # Verify files
  if (!verify_files()) {
    cat("\nDeployment cancelled due to missing files.\n")
    return(invisible(NULL))
  }
  
  # Confirm deployment
  cat("================================================================================\n")
  cat("Ready to Deploy!\n")
  cat("================================================================================\n\n")
  
  proceed <- readline(prompt = "Deploy InstaEDA now? (y/n): ")
  
  if (tolower(proceed) == "y") {
    if (deploy_app()) {
      cat("\n🎉 Deployment complete!\n")
      cat("Your InstaEDA dashboard is now live on Posit Connect Cloud.\n\n")
      cat("Next steps:\n")
      cat("1. Visit your app URL (shown above)\n")
      cat("2. Test the app with sample data\n")
      cat("3. Configure access controls in the Posit Connect dashboard\n")
      cat("4. Share the URL with your users\n\n")
    } else {
      cat("\nDeployment failed. Please check the errors above.\n")
    }
  } else {
    cat("\nDeployment cancelled by user.\n")
  }
}

# Run main deployment
cat("Starting deployment process...\n\n")
main()

cat("\nFor detailed deployment instructions, see DEPLOYMENT_GUIDE.md\n")
cat("For troubleshooting, visit: https://docs.posit.co/connect/user/\n\n")
