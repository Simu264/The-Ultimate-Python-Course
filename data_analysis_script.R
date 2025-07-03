#!/usr/bin/env Rscript

# --- Install and Load Necessary R Libraries ---
# Function to install packages if they don't exist
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
      cat(paste("Installing package:", pkg, "\n"))
      install.packages(pkg, repos = "https://cran.rstudio.com/")
      library(pkg, character.only = TRUE)
    }
  }
}

# Install and load required packages
required_packages <- c("readr", "dplyr", "ggplot2", "corrplot", "GGally", "rlang", "readxl")
install_if_missing(required_packages)

library(readr)
library(dplyr)
library(ggplot2)
library(corrplot)
library(GGally)
library(rlang)
library(readxl)

# --- Configuration ---
# Look for data files in the current directory
data_files <- list.files(pattern = "\\.(csv|xlsx|xls)$", ignore.case = TRUE)

if (length(data_files) == 0) {
  cat("No data files found in the current directory.\n")
  cat("Please place your data file (CSV, XLS, or XLSX) in the same directory as this script.\n")
  cat("Creating sample data for demonstration...\n")
  
  # Create sample data for demonstration
  set.seed(42)
  df <- data.frame(
    ID = 1:100,
    Age = sample(18:80, 100, replace = TRUE),
    Income = rnorm(100, 50000, 15000),
    Education = sample(c("High School", "Bachelor", "Master", "PhD"), 100, replace = TRUE),
    City = sample(c("New York", "Los Angeles", "Chicago", "Houston", "Phoenix"), 100, replace = TRUE),
    Score = rnorm(100, 75, 10)
  )
  
  # Save sample data
  write_csv(df, "sample_data.csv")
  cat("Sample data created and saved as 'sample_data.csv'\n")
  file_path <- "sample_data.csv"
  
} else {
  # Use the first data file found
  file_path <- data_files[1]
  cat(paste("Found data file:", file_path, "\n"))
}

# --- Data Loading Function ---
load_data <- function(file_path) {
  file_ext <- tools::file_ext(tolower(file_path))
  
  if (file_ext == "csv") {
    return(read_csv(file_path, show_col_types = FALSE))
  } else if (file_ext %in% c("xlsx", "xls")) {
    return(read_excel(file_path))
  } else {
    stop("Unsupported file format. Please use CSV, XLS, or XLSX files.")
  }
}

# --- Data Loading and Initial Exploration ---
cat("--- Data Loading and Initial Exploration ---\n")
tryCatch({
  df <- load_data(file_path)
  
  if (nrow(df) == 0) {
    stop("The dataset is empty. No data to analyze or plot.")
  }
  
  cat("\nData loaded successfully. Here's a preview of the first 6 rows:\n")
  print(head(df))
  
  cat("\nDataset dimensions:", nrow(df), "rows x", ncol(df), "columns\n")
  
  cat("\nColumn information (data types and structure):\n")
  print(glimpse(df))
  
  cat("\nDescriptive statistics for all columns:\n")
  print(summary(df))
  
  cat("\nMissing values per column:\n")
  missing_values <- colSums(is.na(df))
  print(missing_values)
  
  # Identify numerical and categorical columns
  numerical_cols <- names(df)[sapply(df, is.numeric)]
  categorical_cols <- names(df)[sapply(df, function(x) is.character(x) || is.factor(x))]
  
  cat(paste0("\nIdentified Numerical columns (", length(numerical_cols), "): ", 
             paste(numerical_cols, collapse = ", "), "\n"))
  cat(paste0("Identified Categorical columns (", length(categorical_cols), "): ", 
             paste(categorical_cols, collapse = ", "), "\n"))
  
  # --- Data Analysis and Visualization ---
  cat("\n--- Generating Visualizations ---\n")
  
  # Create output directory for plots
  if (!dir.exists("plots")) {
    dir.create("plots")
  }
  
  # 1. Distribution of Numerical Data (Histograms with Density)
  if (length(numerical_cols) > 0) {
    cat("\nGenerating histograms for numerical columns...\n")
    
    for (col in numerical_cols) {
      tryCatch({
        p <- ggplot(df, aes(x = !!sym(col))) +
          geom_histogram(aes(y = after_stat(density)), bins = 20, fill = "skyblue", 
                        color = "black", alpha = 0.7) +
          geom_density(color = "red", size = 1) +
          labs(title = paste("Distribution of", col), x = col, y = "Density") +
          theme_minimal() +
          theme(plot.title = element_text(hjust = 0.5))
        
        ggsave(filename = file.path("plots", paste0("histogram_", col, ".png")), 
               plot = p, width = 8, height = 6, dpi = 300)
        cat(paste("  - Saved histogram for", col, "\n"))
      }, error = function(e) {
        cat(paste("  - Error creating histogram for", col, ":", e$message, "\n"))
      })
    }
  } else {
    cat("No numerical columns found to generate histograms.\n")
  }
  
  # 2. Distribution of Categorical Data (Bar Plots)
  if (length(categorical_cols) > 0) {
    cat("\nGenerating bar plots for categorical columns...\n")
    
    for (col in categorical_cols) {
      unique_count <- length(unique(df[[col]]))
      if (unique_count < 50) {
        tryCatch({
          p <- ggplot(df, aes(y = reorder(!!sym(col), !!sym(col), function(x) length(x)))) +
            geom_bar(fill = "lightgreen", color = "black", alpha = 0.7) +
            labs(title = paste("Count of", col), x = "Count", y = col) +
            theme_minimal() +
            theme(plot.title = element_text(hjust = 0.5))
          
          ggsave(filename = file.path("plots", paste0("barplot_", col, ".png")), 
                 plot = p, width = 8, height = 6, dpi = 300)
          cat(paste("  - Saved bar plot for", col, "\n"))
        }, error = function(e) {
          cat(paste("  - Error creating bar plot for", col, ":", e$message, "\n"))
        })
      } else {
        cat(paste0("  - Skipping bar plot for '", col, "' due to too many unique categories (", 
                   unique_count, ").\n"))
      }
    }
  } else {
    cat("No categorical columns found to generate bar plots.\n")
  }
  
  # 3. Correlation Matrix (Heatmap) for Numerical Columns
  if (length(numerical_cols) > 1) {
    cat("\nGenerating correlation matrix for numerical columns...\n")
    tryCatch({
      # Calculate correlation matrix
      cor_matrix <- cor(df[numerical_cols], use = "pairwise.complete.obs")
      
      # Save correlation plot
      png(file.path("plots", "correlation_matrix.png"), width = 800, height = 800, res = 300)
      corrplot(cor_matrix, method = "circle", type = "upper", tl.col = "black", tl.srt = 45,
               title = "Correlation Matrix of Numerical Features", mar = c(0,0,1,0))
      dev.off()
      cat("  - Saved correlation matrix plot\n")
    }, error = function(e) {
      cat(paste("  - Error creating correlation matrix:", e$message, "\n"))
    })
  } else {
    cat("Not enough numerical columns (at least 2) to generate a correlation matrix.\n")
  }
  
  # 4. Box Plots (Numerical vs. Categorical)
  if (length(numerical_cols) > 0 && length(categorical_cols) > 0) {
    cat("\nGenerating box plots for numerical vs. categorical columns...\n")
    combinations_plotted <- 0
    
    for (num_col in head(numerical_cols, 3)) {  # Limit to first 3 numerical columns
      for (cat_col in head(categorical_cols, 2)) {  # Limit to first 2 categorical columns
        unique_categories <- length(unique(df[[cat_col]]))
        if (unique_categories < 15 && combinations_plotted < 6) {
          tryCatch({
            p <- ggplot(df, aes(x = !!sym(cat_col), y = !!sym(num_col))) +
              geom_boxplot(fill = "lightcoral", alpha = 0.7) +
              labs(title = paste(num_col, "Distribution by", cat_col),
                   x = cat_col, y = num_col) +
              theme_minimal() +
              theme(axis.text.x = element_text(angle = 45, hjust = 1),
                    plot.title = element_text(hjust = 0.5))
            
            ggsave(filename = file.path("plots", paste0("boxplot_", num_col, "_by_", cat_col, ".png")), 
                   plot = p, width = 10, height = 6, dpi = 300)
            cat(paste("  - Saved box plot:", num_col, "by", cat_col, "\n"))
            combinations_plotted <- combinations_plotted + 1
          }, error = function(e) {
            cat(paste("  - Error creating box plot for", num_col, "by", cat_col, ":", e$message, "\n"))
          })
        }
      }
    }
    
    if (combinations_plotted == 0) {
      cat("No suitable numerical and categorical column combinations found for box plots.\n")
    }
  } else {
    cat("Could not generate box plots: Need both numerical and categorical columns.\n")
  }
  
  # 5. Pair Plot (for a subset of numerical columns)
  if (length(numerical_cols) > 1) {
    cat("\nGenerating pair plot for numerical columns...\n")
    subset_numerical_cols <- head(numerical_cols, min(length(numerical_cols), 4))
    
    if (length(subset_numerical_cols) > 1) {
      tryCatch({
        p_pairs <- ggpairs(df, columns = subset_numerical_cols,
                          title = "Pair Plot of Selected Numerical Features") +
          theme_minimal()
        
        ggsave(filename = file.path("plots", "pair_plot.png"), 
               plot = p_pairs, width = 12, height = 12, dpi = 300)
        cat("  - Saved pair plot\n")
      }, error = function(e) {
        cat(paste("  - Error creating pair plot:", e$message, "\n"))
      })
    }
  } else {
    cat("Not enough numerical columns for a pair plot.\n")
  }
  
  # --- Summary Report ---
  cat("\n--- Analysis Summary ---\n")
  cat(paste("Dataset:", basename(file_path), "\n"))
  cat(paste("Rows:", nrow(df), "\n"))
  cat(paste("Columns:", ncol(df), "\n"))
  cat(paste("Numerical columns:", length(numerical_cols), "\n"))
  cat(paste("Categorical columns:", length(categorical_cols), "\n"))
  cat(paste("Missing values:", sum(is.na(df)), "\n"))
  
  cat("\n--- Analysis Complete ---\n")
  cat("All plots have been saved to the 'plots' directory.\n")
  cat("Check the following files:\n")
  plot_files <- list.files("plots", pattern = "\\.png$", full.names = FALSE)
  for (file in plot_files) {
    cat(paste("  -", file, "\n"))
  }
  
}, error = function(e) {
  if (grepl("The dataset is empty", e$message)) {
    cat(paste0("Error: ", e$message, "\n"))
  } else if (grepl("cannot open file", e$message) || grepl("No such file or directory", e$message)) {
    cat(paste0("Error: The file '", file_path, "' was not found.\n"))
    cat("Please ensure your data file is in the same directory as this R script.\n")
  } else if (grepl("empty file", e$message)) {
    cat(paste0("Error: The file '", file_path, "' is empty or contains no data.\n"))
  } else {
    cat(paste0("An unexpected error occurred: ", e$message, "\n"))
    cat("Please check your data file for any inconsistencies or corrupted entries.\n")
  }
})

cat("\nScript execution completed.\n")