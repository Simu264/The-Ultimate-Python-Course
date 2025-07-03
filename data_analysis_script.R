#!/usr/bin/env Rscript

# ==============================================================================
# COMPREHENSIVE DATA ANALYSIS SCRIPT WITH CSV EXPORTS
# ==============================================================================
# This script performs automated data analysis and exports all results to CSV
# Author: AI Assistant
# Version: 2.0
# ==============================================================================

# --- Global Configuration ---
options(warn = -1)  # Suppress warnings during package installation
set.seed(42)  # For reproducible results

# Create output directories
output_dirs <- c("plots", "exports", "reports")
for (dir in output_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat(paste("Created directory:", dir, "\n"))
  }
}

# --- Enhanced Package Installation Function ---
install_if_missing <- function(packages) {
  cat("=== Checking and Installing Required Packages ===\n")
  
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(paste("Installing package:", pkg, "...\n"))
      tryCatch({
        install.packages(pkg, repos = "https://cran.rstudio.com/", dependencies = TRUE, quiet = TRUE)
        library(pkg, character.only = TRUE, quietly = TRUE)
        cat(paste("✓ Successfully installed and loaded:", pkg, "\n"))
      }, error = function(e) {
        cat(paste("✗ Failed to install", pkg, ":", e$message, "\n"))
        stop(paste("Required package", pkg, "could not be installed"))
      })
    } else {
      cat(paste("✓ Package already available:", pkg, "\n"))
    }
  }
  cat("=== All packages ready ===\n\n")
}

# Install and load required packages
required_packages <- c(
  "readr", "dplyr", "ggplot2", "corrplot", "GGally", 
  "rlang", "readxl", "gridExtra", "scales", "RColorBrewer",
  "reshape2", "knitr", "DT"
)

install_if_missing(required_packages)

# Load all libraries
suppressMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(corrplot)
  library(GGally)
  library(rlang)
  library(readxl)
  library(gridExtra)
  library(scales)
  library(RColorBrewer)
  library(reshape2)
  library(knitr)
})

# --- Enhanced Data Loading Function ---
load_data <- function(file_path) {
  cat(paste("Loading data from:", file_path, "\n"))
  file_ext <- tools::file_ext(tolower(file_path))
  
  tryCatch({
    if (file_ext == "csv") {
      data <- read_csv(file_path, show_col_types = FALSE)
    } else if (file_ext %in% c("xlsx", "xls")) {
      data <- read_excel(file_path)
    } else {
      stop("Unsupported file format. Please use CSV, XLS, or XLSX files.")
    }
    
    if (nrow(data) == 0) {
      stop("The dataset is empty.")
    }
    
    cat(paste("✓ Successfully loaded", nrow(data), "rows and", ncol(data), "columns\n"))
    return(data)
    
  }, error = function(e) {
    cat(paste("✗ Error loading data:", e$message, "\n"))
    stop(e$message)
  })
}

# --- Data Discovery and Sample Data Creation ---
discover_data <- function() {
  cat("=== Data Discovery ===\n")
  
  # Look for data files
  data_files <- list.files(pattern = "\\.(csv|xlsx|xls)$", ignore.case = TRUE)
  data_files <- data_files[!grepl("sample_data", data_files)]  # Exclude our sample data
  
  if (length(data_files) == 0) {
    cat("No data files found. Creating enhanced sample dataset...\n")
    
    # Create a more comprehensive sample dataset
    n <- 500
    df <- data.frame(
      ID = 1:n,
      Age = sample(18:80, n, replace = TRUE),
      Income = round(rnorm(n, 55000, 20000), 2),
      Education = sample(c("High School", "Bachelor", "Master", "PhD"), n, 
                        replace = TRUE, prob = c(0.3, 0.4, 0.2, 0.1)),
      City = sample(c("New York", "Los Angeles", "Chicago", "Houston", "Phoenix", 
                     "Philadelphia", "San Antonio", "San Diego"), n, replace = TRUE),
      Department = sample(c("Engineering", "Marketing", "Sales", "HR", "Finance"), 
                         n, replace = TRUE),
      Score = round(rnorm(n, 75, 15), 1),
      Years_Experience = sample(0:30, n, replace = TRUE),
      Satisfaction = sample(1:10, n, replace = TRUE),
      Salary_Bonus = round(rnorm(n, 5000, 2000), 2),
      Performance_Rating = sample(c("Poor", "Fair", "Good", "Excellent"), n, 
                                 replace = TRUE, prob = c(0.1, 0.2, 0.5, 0.2))
    )
    
    # Add some missing values for realism
    df$Income[sample(nrow(df), n * 0.02)] <- NA
    df$Score[sample(nrow(df), n * 0.01)] <- NA
    
    write_csv(df, "sample_data.csv")
    cat("✓ Enhanced sample data created: sample_data.csv\n")
    return("sample_data.csv")
    
  } else {
    file_path <- data_files[1]
    cat(paste("✓ Found data file:", file_path, "\n"))
    return(file_path)
  }
}

# --- Export Functions ---
export_summary_stats <- function(df, filename = "summary_statistics.csv") {
  cat("Exporting summary statistics...\n")
  
  # Numerical summaries
  numerical_cols <- names(df)[sapply(df, is.numeric)]
  if (length(numerical_cols) > 0) {
    num_summary <- df %>%
      select(all_of(numerical_cols)) %>%
      summarise_all(list(
        count = ~sum(!is.na(.)),
        mean = ~round(mean(., na.rm = TRUE), 3),
        median = ~round(median(., na.rm = TRUE), 3),
        sd = ~round(sd(., na.rm = TRUE), 3),
        min = ~round(min(., na.rm = TRUE), 3),
        max = ~round(max(., na.rm = TRUE), 3),
        missing = ~sum(is.na(.))
      )) %>%
      pivot_longer(everything(), names_to = "variable_stat", values_to = "value") %>%
      separate(variable_stat, into = c("variable", "statistic"), sep = "_(?=[^_]+$)") %>%
      pivot_wider(names_from = statistic, values_from = value)
    
    write_csv(num_summary, file.path("exports", paste0("numerical_", filename)))
  }
  
  # Categorical summaries
  categorical_cols <- names(df)[sapply(df, function(x) is.character(x) || is.factor(x))]
  if (length(categorical_cols) > 0) {
    cat_summary <- data.frame()
    
    for (col in categorical_cols) {
      col_summary <- df %>%
        count(!!sym(col), name = "count") %>%
        mutate(
          variable = col,
          percentage = round(count / sum(count) * 100, 2)
        ) %>%
        rename(category = !!sym(col)) %>%
        select(variable, category, count, percentage)
      
      cat_summary <- rbind(cat_summary, col_summary)
    }
    
    write_csv(cat_summary, file.path("exports", paste0("categorical_", filename)))
  }
  
  cat("✓ Summary statistics exported\n")
}

export_correlation_matrix <- function(df, filename = "correlation_matrix.csv") {
  numerical_cols <- names(df)[sapply(df, is.numeric)]
  
  if (length(numerical_cols) > 1) {
    cat("Exporting correlation matrix...\n")
    
    cor_matrix <- cor(df[numerical_cols], use = "pairwise.complete.obs")
    cor_df <- as.data.frame(cor_matrix)
    cor_df$variable <- rownames(cor_df)
    cor_df <- cor_df %>% select(variable, everything())
    
    write_csv(cor_df, file.path("exports", filename))
    
    # Also export correlation pairs in long format
    cor_long <- cor_matrix %>%
      as.data.frame() %>%
      rownames_to_column("var1") %>%
      pivot_longer(-var1, names_to = "var2", values_to = "correlation") %>%
      filter(var1 != var2) %>%
      mutate(correlation = round(correlation, 4)) %>%
      arrange(desc(abs(correlation)))
    
    write_csv(cor_long, file.path("exports", "correlation_pairs.csv"))
    cat("✓ Correlation matrix exported\n")
  }
}

export_missing_values_report <- function(df, filename = "missing_values_report.csv") {
  cat("Exporting missing values report...\n")
  
  missing_report <- df %>%
    summarise_all(~sum(is.na(.))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
    mutate(
      total_rows = nrow(df),
      missing_percentage = round(missing_count / total_rows * 100, 2)
    ) %>%
    arrange(desc(missing_count))
  
  write_csv(missing_report, file.path("exports", filename))
  cat("✓ Missing values report exported\n")
}

# --- Enhanced Visualization Functions ---
create_enhanced_histograms <- function(df, numerical_cols) {
  cat("Creating enhanced histograms...\n")
  
  for (col in numerical_cols) {
    tryCatch({
      # Basic statistics for the plot
      col_data <- df[[col]][!is.na(df[[col]])]
      mean_val <- mean(col_data)
      median_val <- median(col_data)
      
      p <- ggplot(df, aes(x = !!sym(col))) +
        geom_histogram(aes(y = after_stat(density)), bins = 30, 
                      fill = "skyblue", color = "darkblue", alpha = 0.7) +
        geom_density(color = "red", size = 1.2) +
        geom_vline(xintercept = mean_val, color = "darkgreen", 
                  linetype = "dashed", size = 1, alpha = 0.8) +
        geom_vline(xintercept = median_val, color = "orange", 
                  linetype = "dashed", size = 1, alpha = 0.8) +
        labs(
          title = paste("Distribution of", col),
          subtitle = paste0("Mean: ", round(mean_val, 2), 
                          " | Median: ", round(median_val, 2),
                          " | N: ", length(col_data)),
          x = col, 
          y = "Density"
        ) +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
          plot.subtitle = element_text(hjust = 0.5, size = 10)
        )
      
      ggsave(filename = file.path("plots", paste0("histogram_", col, ".png")), 
             plot = p, width = 10, height = 6, dpi = 300)
      
      # Export histogram data
      hist_data <- ggplot_build(p)$data[[1]]
      hist_export <- data.frame(
        bin_start = hist_data$xmin,
        bin_end = hist_data$xmax,
        bin_center = (hist_data$xmin + hist_data$xmax) / 2,
        count = hist_data$count,
        density = hist_data$density
      )
      write_csv(hist_export, file.path("exports", paste0("histogram_data_", col, ".csv")))
      
      cat(paste("  ✓ Saved histogram and data for", col, "\n"))
    }, error = function(e) {
      cat(paste("  ✗ Error creating histogram for", col, ":", e$message, "\n"))
    })
  }
}

create_enhanced_barplots <- function(df, categorical_cols) {
  cat("Creating enhanced bar plots...\n")
  
  for (col in categorical_cols) {
    unique_count <- length(unique(df[[col]]))
    if (unique_count < 50) {
      tryCatch({
        # Calculate frequencies
        freq_data <- df %>%
          count(!!sym(col), name = "count") %>%
          mutate(percentage = round(count / sum(count) * 100, 1)) %>%
          arrange(desc(count))
        
        p <- ggplot(freq_data, aes(x = reorder(!!sym(col), count), y = count)) +
          geom_col(fill = "lightgreen", color = "darkgreen", alpha = 0.8) +
          geom_text(aes(label = paste0(count, "\n(", percentage, "%)")), 
                   hjust = -0.1, size = 3) +
          coord_flip() +
          labs(
            title = paste("Distribution of", col),
            subtitle = paste0("Total categories: ", unique_count, 
                            " | Total observations: ", sum(freq_data$count)),
            x = col, 
            y = "Count"
          ) +
          theme_minimal() +
          theme(
            plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
            plot.subtitle = element_text(hjust = 0.5, size = 10)
          )
        
        ggsave(filename = file.path("plots", paste0("barplot_", col, ".png")), 
               plot = p, width = 10, height = max(6, unique_count * 0.3), dpi = 300)
        
        # Export bar plot data
        write_csv(freq_data, file.path("exports", paste0("frequency_", col, ".csv")))
        
        cat(paste("  ✓ Saved bar plot and data for", col, "\n"))
      }, error = function(e) {
        cat(paste("  ✗ Error creating bar plot for", col, ":", e$message, "\n"))
      })
    } else {
      cat(paste0("  ! Skipping bar plot for '", col, "' (too many categories: ", unique_count, ")\n"))
    }
  }
}

create_enhanced_correlation_plot <- function(df, numerical_cols) {
  if (length(numerical_cols) > 1) {
    cat("Creating enhanced correlation matrix...\n")
    
    tryCatch({
      cor_matrix <- cor(df[numerical_cols], use = "pairwise.complete.obs")
      
      # Create correlation heatmap with ggplot2
      cor_melted <- melt(cor_matrix)
      
      p <- ggplot(cor_melted, aes(Var1, Var2, fill = value)) +
        geom_tile(color = "white") +
        geom_text(aes(label = round(value, 2)), color = "black", size = 3) +
        scale_fill_gradient2(low = "blue", mid = "white", high = "red", 
                           midpoint = 0, limit = c(-1, 1), space = "Lab",
                           name = "Correlation") +
        theme_minimal() +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
        ) +
        labs(title = "Correlation Matrix Heatmap", x = "", y = "") +
        coord_fixed()
      
      ggsave(filename = file.path("plots", "correlation_heatmap.png"), 
             plot = p, width = 12, height = 10, dpi = 300)
      
      # Also create the corrplot version
      png(file.path("plots", "correlation_matrix_corrplot.png"), 
          width = 1200, height = 1200, res = 300)
      corrplot(cor_matrix, method = "color", type = "upper", 
               tl.col = "black", tl.srt = 45, addCoef.col = "black",
               title = "Correlation Matrix", mar = c(0,0,1,0))
      dev.off()
      
      cat("  ✓ Saved correlation plots\n")
    }, error = function(e) {
      cat(paste("  ✗ Error creating correlation matrix:", e$message, "\n"))
    })
  }
}

# --- Main Analysis Function ---
perform_comprehensive_analysis <- function(file_path) {
  cat("\n=== COMPREHENSIVE DATA ANALYSIS STARTING ===\n")
  
  # Load data
  df <- load_data(file_path)
  
  # Basic information
  cat("\n=== DATASET OVERVIEW ===\n")
  cat(paste("Dataset:", basename(file_path), "\n"))
  cat(paste("Dimensions:", nrow(df), "rows ×", ncol(df), "columns\n"))
  
  # Show first few rows
  cat("\nFirst 6 rows:\n")
  print(head(df))
  
  # Column classification
  numerical_cols <- names(df)[sapply(df, is.numeric)]
  categorical_cols <- names(df)[sapply(df, function(x) is.character(x) || is.factor(x))]
  
  cat(paste("\nNumerical columns (", length(numerical_cols), "):", 
            paste(numerical_cols, collapse = ", "), "\n"))
  cat(paste("Categorical columns (", length(categorical_cols), "):", 
            paste(categorical_cols, collapse = ", "), "\n"))
  
  # Export basic dataset info
  dataset_info <- data.frame(
    dataset_name = basename(file_path),
    total_rows = nrow(df),
    total_columns = ncol(df),
    numerical_columns = length(numerical_cols),
    categorical_columns = length(categorical_cols),
    total_missing_values = sum(is.na(df)),
    missing_percentage = round(sum(is.na(df)) / (nrow(df) * ncol(df)) * 100, 2)
  )
  write_csv(dataset_info, file.path("exports", "dataset_overview.csv"))
  
  # Export all data analysis results
  cat("\n=== EXPORTING ANALYSIS RESULTS ===\n")
  export_summary_stats(df)
  export_correlation_matrix(df)
  export_missing_values_report(df)
  
  # Create visualizations
  cat("\n=== CREATING VISUALIZATIONS ===\n")
  if (length(numerical_cols) > 0) {
    create_enhanced_histograms(df, numerical_cols)
  }
  
  if (length(categorical_cols) > 0) {
    create_enhanced_barplots(df, categorical_cols)
  }
  
  if (length(numerical_cols) > 1) {
    create_enhanced_correlation_plot(df, numerical_cols)
  }
  
  # Create box plots for numerical vs categorical
  if (length(numerical_cols) > 0 && length(categorical_cols) > 0) {
    cat("Creating box plots...\n")
    
    for (num_col in head(numerical_cols, 3)) {
      for (cat_col in head(categorical_cols, 2)) {
        if (length(unique(df[[cat_col]])) < 15) {
          tryCatch({
            # Calculate box plot statistics
            box_stats <- df %>%
              group_by(!!sym(cat_col)) %>%
              summarise(
                count = n(),
                mean = round(mean(!!sym(num_col), na.rm = TRUE), 3),
                median = round(median(!!sym(num_col), na.rm = TRUE), 3),
                q1 = round(quantile(!!sym(num_col), 0.25, na.rm = TRUE), 3),
                q3 = round(quantile(!!sym(num_col), 0.75, na.rm = TRUE), 3),
                min = round(min(!!sym(num_col), na.rm = TRUE), 3),
                max = round(max(!!sym(num_col), na.rm = TRUE), 3),
                .groups = 'drop'
              )
            
            p <- ggplot(df, aes(x = !!sym(cat_col), y = !!sym(num_col))) +
              geom_boxplot(fill = "lightcoral", alpha = 0.7, outlier.color = "red") +
              stat_summary(fun = mean, geom = "point", shape = 18, size = 3, color = "blue") +
              labs(
                title = paste(num_col, "Distribution by", cat_col),
                subtitle = "Blue diamonds show means",
                x = cat_col, 
                y = num_col
              ) +
              theme_minimal() +
              theme(
                axis.text.x = element_text(angle = 45, hjust = 1),
                plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
                plot.subtitle = element_text(hjust = 0.5, size = 10)
              )
            
            ggsave(filename = file.path("plots", paste0("boxplot_", num_col, "_by_", cat_col, ".png")), 
                   plot = p, width = 12, height = 8, dpi = 300)
            
            # Export box plot statistics
            write_csv(box_stats, file.path("exports", paste0("boxplot_stats_", num_col, "_by_", cat_col, ".csv")))
            
            cat(paste("  ✓ Saved box plot and stats:", num_col, "by", cat_col, "\n"))
          }, error = function(e) {
            cat(paste("  ✗ Error creating box plot for", num_col, "by", cat_col, ":", e$message, "\n"))
          })
        }
      }
    }
  }
  
  # Generate final report
  cat("\n=== GENERATING FINAL REPORT ===\n")
  generate_final_report(df, file_path, numerical_cols, categorical_cols)
  
  return(df)
}

# --- Report Generation Function ---
generate_final_report <- function(df, file_path, numerical_cols, categorical_cols) {
  
  # Create comprehensive summary
  summary_report <- list(
    dataset_info = data.frame(
      metric = c("Dataset Name", "Total Rows", "Total Columns", "Numerical Columns", 
                "Categorical Columns", "Total Missing Values", "Missing Percentage"),
      value = c(basename(file_path), nrow(df), ncol(df), length(numerical_cols),
               length(categorical_cols), sum(is.na(df)), 
               paste0(round(sum(is.na(df)) / (nrow(df) * ncol(df)) * 100, 2), "%"))
    )
  )
  
  # Export comprehensive report
  write_csv(summary_report$dataset_info, file.path("exports", "final_analysis_report.csv"))
  
  # List all generated files
  plot_files <- list.files("plots", pattern = "\\.png$", full.names = FALSE)
  export_files <- list.files("exports", pattern = "\\.csv$", full.names = FALSE)
  
  file_inventory <- data.frame(
    file_type = c(rep("plot", length(plot_files)), rep("export", length(export_files))),
    file_name = c(plot_files, export_files),
    file_path = c(
      file.path("plots", plot_files),
      file.path("exports", export_files)
    )
  )
  
  write_csv(file_inventory, file.path("exports", "generated_files_inventory.csv"))
  
  cat("✓ Final report generated\n")
  
  # Print summary
  cat("\n=== ANALYSIS COMPLETE ===\n")
  cat(paste("Generated", length(plot_files), "plots and", length(export_files), "CSV exports\n"))
  cat("\nPlot files:\n")
  for (file in plot_files) {
    cat(paste("  •", file, "\n"))
  }
  cat("\nExport files:\n")
  for (file in export_files) {
    cat(paste("  •", file, "\n"))
  }
}

# --- Main Execution ---
main <- function() {
  cat("╔══════════════════════════════════════════════════════════════╗\n")
  cat("║              COMPREHENSIVE DATA ANALYSIS TOOL               ║\n")
  cat("║                    WITH CSV EXPORTS                          ║\n")
  cat("╚══════════════════════════════════════════════════════════════╝\n\n")
  
  tryCatch({
    # Discover and load data
    file_path <- discover_data()
    
    # Perform comprehensive analysis
    df <- perform_comprehensive_analysis(file_path)
    
    cat("\n🎉 SUCCESS: Analysis completed successfully!\n")
    cat("📊 Check the 'plots' directory for visualizations\n")
    cat("📈 Check the 'exports' directory for CSV data\n")
    cat("📋 Check 'exports/final_analysis_report.csv' for the summary\n\n")
    
  }, error = function(e) {
    cat(paste("\n❌ ERROR:", e$message, "\n"))
    cat("Please check your data file and try again.\n")
  })
}

# Execute main function
if (!interactive()) {
  main()
} else {
  cat("Script loaded. Run main() to execute the analysis.\n")
}