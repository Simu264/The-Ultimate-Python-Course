#!/usr/bin/env Rscript

# Package Installation Script for Data Analysis
# This script handles package installation with user library fallback

cat("=== R Package Installation Script ===\n")

# Set up user library if system library is not writable
user_lib <- file.path(Sys.getenv("HOME"), "R", "library")
if (!dir.exists(user_lib)) {
  dir.create(user_lib, recursive = TRUE)
  cat("Created user library at:", user_lib, "\n")
}

# Add user library to library paths
.libPaths(c(user_lib, .libPaths()))
cat("Library paths:", paste(.libPaths(), collapse = ", "), "\n")

# Required packages
required_packages <- c(
  "readr", "dplyr", "ggplot2", "corrplot", "GGally", 
  "rlang", "readxl", "gridExtra", "scales", "RColorBrewer",
  "reshape2", "knitr"
)

# Enhanced installation function
install_packages_safely <- function(packages) {
  cat("\n=== Installing Required Packages ===\n")
  
  failed_packages <- c()
  
  for (pkg in packages) {
    cat(paste("Checking package:", pkg, "...\n"))
    
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(paste("Installing", pkg, "...\n"))
      
      tryCatch({
        install.packages(pkg, 
                        repos = "https://cloud.r-project.org/", 
                        lib = user_lib,
                        dependencies = TRUE, 
                        quiet = FALSE)
        
        # Try to load the package
        if (require(pkg, character.only = TRUE, quietly = TRUE)) {
          cat(paste("✓ Successfully installed and loaded:", pkg, "\n"))
        } else {
          failed_packages <- c(failed_packages, pkg)
          cat(paste("✗ Failed to load after installation:", pkg, "\n"))
        }
        
      }, error = function(e) {
        failed_packages <<- c(failed_packages, pkg)
        cat(paste("✗ Failed to install", pkg, ":", e$message, "\n"))
      })
    } else {
      cat(paste("✓ Package already available:", pkg, "\n"))
    }
  }
  
  if (length(failed_packages) > 0) {
    cat("\n=== Installation Summary ===\n")
    cat("Failed packages:", paste(failed_packages, collapse = ", "), "\n")
    cat("You may need to install these manually or check your internet connection.\n")
    return(FALSE)
  } else {
    cat("\n✓ All packages installed successfully!\n")
    return(TRUE)
  }
}

# Run installation
success <- install_packages_safely(required_packages)

if (success) {
  cat("\n🎉 Package installation complete! You can now run the data analysis script.\n")
} else {
  cat("\n⚠️ Some packages failed to install. The script may not work properly.\n")
}