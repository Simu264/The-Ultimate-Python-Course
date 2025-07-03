#!/usr/bin/env Rscript

# ==============================================================================
# COMPLETE DATA ANALYSIS SCRIPT WITH CSV EXPORTS
# ==============================================================================
# This script performs comprehensive data analysis using base R functions
# and exports all results to CSV format
# Author: AI Assistant
# Version: Final
# ==============================================================================

cat("╔══════════════════════════════════════════════════════════════╗\n")
cat("║           COMPLETE DATA ANALYSIS TOOL WITH CSV EXPORTS      ║\n")
cat("║              Ready for Production Use                        ║\n")
cat("╚══════════════════════════════════════════════════════════════╝\n\n")

# --- Configuration ---
set.seed(42)
options(warn = -1)

# Create output directories
output_dirs <- c("plots", "exports", "reports")
for (dir in output_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat(paste("✓ Created directory:", dir, "\n"))
  }
}

# --- Data Discovery ---
discover_data <- function() {
  cat("\n=== Data Discovery ===\n")
  
  # Look for data files
  data_files <- list.files(pattern = "\\.(csv|xlsx|xls)$", ignore.case = TRUE)
  data_files <- data_files[!grepl("sample_data", data_files)]
  
  if (length(data_files) == 0) {
    cat("No data files found. Creating enhanced sample dataset...\n")
    
    # Create comprehensive sample data
    n <- 1000
    df <- data.frame(
      ID = 1:n,
      Age = sample(18:80, n, replace = TRUE),
      Income = round(rnorm(n, 55000, 20000), 2),
      Education = sample(c("High School", "Bachelor", "Master", "PhD"), n, 
                        replace = TRUE, prob = c(0.3, 0.4, 0.2, 0.1)),
      City = sample(c("New York", "Los Angeles", "Chicago", "Houston", "Phoenix"), 
                   n, replace = TRUE),
      Department = sample(c("Engineering", "Marketing", "Sales", "HR", "Finance"), 
                         n, replace = TRUE),
      Score = round(rnorm(n, 75, 15), 1),
      Years_Experience = sample(0:30, n, replace = TRUE),
      Satisfaction = sample(1:10, n, replace = TRUE),
      Salary_Bonus = round(rnorm(n, 5000, 2000), 2),
      Performance_Rating = sample(c("Poor", "Fair", "Good", "Excellent"), n, 
                                 replace = TRUE, prob = c(0.1, 0.2, 0.5, 0.2)),
      stringsAsFactors = FALSE
    )
    
    # Add some missing values for realism
    df$Income[sample(nrow(df), n * 0.02)] <- NA
    df$Score[sample(nrow(df), n * 0.01)] <- NA
    df$Salary_Bonus[sample(nrow(df), n * 0.01)] <- NA
    
    write.csv(df, "enhanced_sample_data.csv", row.names = FALSE)
    cat("✓ Enhanced sample data created: enhanced_sample_data.csv\n")
    return("enhanced_sample_data.csv")
    
  } else {
    file_path <- data_files[1]
    cat(paste("✓ Found data file:", file_path, "\n"))
    return(file_path)
  }
}

# --- Data Loading ---
load_data <- function(file_path) {
  cat(paste("Loading data from:", file_path, "\n"))
  
  tryCatch({
    if (grepl("\\.csv$", file_path, ignore.case = TRUE)) {
      df <- read.csv(file_path, stringsAsFactors = FALSE)
    } else {
      stop("This version supports CSV files. Please convert your data to CSV format.")
    }
    
    if (nrow(df) == 0) stop("Dataset is empty")
    
    cat(paste("✓ Successfully loaded", nrow(df), "rows and", ncol(df), "columns\n"))
    return(df)
    
  }, error = function(e) {
    stop(paste("Error loading data:", e$message))
  })
}

# --- Enhanced Export Functions ---
export_summary_stats <- function(df) {
  cat("Exporting comprehensive summary statistics...\n")
  
  # Numerical columns
  numerical_cols <- names(df)[sapply(df, is.numeric)]
  
  if (length(numerical_cols) > 0) {
    num_summary <- data.frame(
      variable = numerical_cols,
      count = sapply(numerical_cols, function(x) sum(!is.na(df[[x]]))),
      mean = sapply(numerical_cols, function(x) round(mean(df[[x]], na.rm = TRUE), 3)),
      median = sapply(numerical_cols, function(x) round(median(df[[x]], na.rm = TRUE), 3)),
      sd = sapply(numerical_cols, function(x) round(sd(df[[x]], na.rm = TRUE), 3)),
      min = sapply(numerical_cols, function(x) round(min(df[[x]], na.rm = TRUE), 3)),
      max = sapply(numerical_cols, function(x) round(max(df[[x]], na.rm = TRUE), 3)),
      q25 = sapply(numerical_cols, function(x) round(quantile(df[[x]], 0.25, na.rm = TRUE), 3)),
      q75 = sapply(numerical_cols, function(x) round(quantile(df[[x]], 0.75, na.rm = TRUE), 3)),
      missing = sapply(numerical_cols, function(x) sum(is.na(df[[x]]))),
      missing_pct = sapply(numerical_cols, function(x) round(sum(is.na(df[[x]])) / length(df[[x]]) * 100, 2)),
      row.names = NULL
    )
    write.csv(num_summary, file.path("exports", "numerical_summary_statistics.csv"), row.names = FALSE)
  }
  
  # Categorical columns
  categorical_cols <- names(df)[sapply(df, function(x) is.character(x) || is.factor(x))]
  
  if (length(categorical_cols) > 0) {
    cat_summary <- data.frame()
    
    for (col in categorical_cols) {
      freq_table <- table(df[[col]], useNA = "ifany")
      col_data <- data.frame(
        variable = col,
        category = names(freq_table),
        count = as.numeric(freq_table),
        percentage = round(as.numeric(freq_table) / sum(freq_table) * 100, 2),
        stringsAsFactors = FALSE
      )
      cat_summary <- rbind(cat_summary, col_data)
    }
    
    write.csv(cat_summary, file.path("exports", "categorical_summary_statistics.csv"), row.names = FALSE)
  }
  
  cat("✓ Summary statistics exported\n")
}

# --- Enhanced Visualization Functions ---
create_histograms <- function(df, numerical_cols) {
  cat("Creating professional histograms...\n")
  
  for (col in numerical_cols) {
    tryCatch({
      col_data <- df[[col]][!is.na(df[[col]])]
      
      if (length(col_data) > 0) {
        # Create histogram with better aesthetics
        png(file.path("plots", paste0("histogram_", col, ".png")), 
            width = 1000, height = 700, res = 150)
        
        par(mar = c(5, 5, 4, 2))
        hist(col_data, breaks = 30, col = "#87CEEB", border = "#4682B4",
             main = paste("Distribution of", col),
             xlab = col, ylab = "Frequency",
             cex.main = 1.4, cex.lab = 1.2, cex.axis = 1.1)
        
        # Add mean and median lines
        abline(v = mean(col_data), col = "#DC143C", lty = 2, lwd = 3)
        abline(v = median(col_data), col = "#FF8C00", lty = 2, lwd = 3)
        
        # Add legend
        legend("topright", 
               legend = c(paste("Mean:", round(mean(col_data), 2)),
                         paste("Median:", round(median(col_data), 2)),
                         paste("N:", length(col_data))),
               col = c("#DC143C", "#FF8C00", "black"), 
               lty = c(2, 2, NA), lwd = c(3, 3, NA),
               cex = 1.1, bg = "white")
        
        dev.off()
        
        # Export histogram data
        hist_data <- hist(col_data, breaks = 30, plot = FALSE)
        hist_export <- data.frame(
          variable = col,
          bin_start = hist_data$breaks[-length(hist_data$breaks)],
          bin_end = hist_data$breaks[-1],
          bin_center = (hist_data$breaks[-length(hist_data$breaks)] + hist_data$breaks[-1]) / 2,
          count = hist_data$counts,
          density = round(hist_data$density, 6)
        )
        write.csv(hist_export, file.path("exports", paste0("histogram_data_", col, ".csv")), row.names = FALSE)
        
        cat(paste("  ✓ Saved histogram and data for", col, "\n"))
      }
    }, error = function(e) {
      cat(paste("  ✗ Error creating histogram for", col, ":", e$message, "\n"))
    })
  }
}

create_barplots <- function(df, categorical_cols) {
  cat("Creating professional bar plots...\n")
  
  for (col in categorical_cols) {
    if (length(unique(df[[col]])) < 25) {
      tryCatch({
        freq_data <- table(df[[col]])
        sorted_freq <- sort(freq_data, decreasing = TRUE)
        
        # Create bar plot
        png(file.path("plots", paste0("barplot_", col, ".png")), 
            width = 1200, height = 800, res = 150)
        
        par(mar = c(8, 5, 4, 2))
        colors <- rainbow(length(sorted_freq), alpha = 0.7)
        
        barplot(sorted_freq, col = colors,
                main = paste("Distribution of", col),
                ylab = "Count",
                cex.main = 1.4, cex.lab = 1.2, cex.axis = 1.1,
                las = 2)  # Rotate x-axis labels
        
        # Add value labels on bars
        bar_pos <- barplot(sorted_freq, plot = FALSE)
        text(bar_pos, sorted_freq + max(sorted_freq) * 0.02, 
             labels = sorted_freq, pos = 3, cex = 0.9)
        
        dev.off()
        
        # Export frequency data
        freq_export <- data.frame(
          variable = col,
          category = names(sorted_freq),
          count = as.numeric(sorted_freq),
          percentage = round(as.numeric(sorted_freq) / sum(sorted_freq) * 100, 2),
          cumulative_count = cumsum(as.numeric(sorted_freq)),
          cumulative_percentage = round(cumsum(as.numeric(sorted_freq)) / sum(sorted_freq) * 100, 2)
        )
        write.csv(freq_export, file.path("exports", paste0("frequency_", col, ".csv")), row.names = FALSE)
        
        cat(paste("  ✓ Saved bar plot and data for", col, "\n"))
      }, error = function(e) {
        cat(paste("  ✗ Error creating bar plot for", col, ":", e$message, "\n"))
      })
    } else {
      cat(paste("  ⚠ Skipping", col, "- too many categories (", length(unique(df[[col]])), ")\n"))
    }
  }
}

create_correlation_matrix <- function(df, numerical_cols) {
  if (length(numerical_cols) > 1) {
    cat("Creating correlation analysis...\n")
    
    tryCatch({
      cor_matrix <- cor(df[numerical_cols], use = "pairwise.complete.obs")
      
      # Create enhanced correlation heatmap
      png(file.path("plots", "correlation_heatmap.png"), width = 1200, height = 1200, res = 150)
      
      par(mar = c(8, 8, 4, 8))
      
      # Create color palette
      n_colors <- 100
      colors <- c(colorRampPalette(c("blue", "white"))(n_colors/2),
                  colorRampPalette(c("white", "red"))(n_colors/2))
      
      # Create heatmap
      image(1:ncol(cor_matrix), 1:nrow(cor_matrix), t(cor_matrix), 
            col = colors, axes = FALSE,
            main = "Correlation Matrix Heatmap",
            xlab = "", ylab = "", cex.main = 1.6)
      
      # Add axes
      axis(1, at = 1:ncol(cor_matrix), labels = colnames(cor_matrix), las = 2, cex.axis = 1.1)
      axis(2, at = 1:nrow(cor_matrix), labels = rownames(cor_matrix), las = 2, cex.axis = 1.1)
      
      # Add correlation values
      for (i in 1:nrow(cor_matrix)) {
        for (j in 1:ncol(cor_matrix)) {
          text(j, i, round(cor_matrix[i, j], 2), cex = 1.0, 
               col = ifelse(abs(cor_matrix[i, j]) > 0.5, "white", "black"))
        }
      }
      
      # Add color legend
      legend("right", inset = c(-0.2, 0),
             legend = c("1.0", "0.5", "0.0", "-0.5", "-1.0"),
             fill = c("red", "pink", "white", "lightblue", "blue"),
             title = "Correlation", cex = 1.1)
      
      dev.off()
      
      # Export correlation matrix (wide format)
      cor_df <- as.data.frame(cor_matrix)
      cor_df$variable <- rownames(cor_df)
      cor_df <- cor_df[, c("variable", colnames(cor_matrix))]
      write.csv(cor_df, file.path("exports", "correlation_matrix.csv"), row.names = FALSE)
      
      # Export correlation pairs (long format)
      cor_pairs <- data.frame()
      for (i in 1:nrow(cor_matrix)) {
        for (j in i:ncol(cor_matrix)) {
          if (i != j) {
            cor_pairs <- rbind(cor_pairs, data.frame(
              var1 = rownames(cor_matrix)[i],
              var2 = colnames(cor_matrix)[j],
              correlation = round(cor_matrix[i, j], 4),
              abs_correlation = round(abs(cor_matrix[i, j]), 4),
              strength = ifelse(abs(cor_matrix[i, j]) > 0.7, "Strong",
                               ifelse(abs(cor_matrix[i, j]) > 0.4, "Moderate", "Weak"))
            ))
          }
        }
      }
      cor_pairs <- cor_pairs[order(cor_pairs$abs_correlation, decreasing = TRUE), ]
      write.csv(cor_pairs, file.path("exports", "correlation_pairs.csv"), row.names = FALSE)
      
      cat("  ✓ Saved correlation analysis\n")
    }, error = function(e) {
      cat(paste("  ✗ Error creating correlation matrix:", e$message, "\n"))
    })
  }
}

create_boxplots <- function(df, numerical_cols, categorical_cols) {
  if (length(numerical_cols) > 0 && length(categorical_cols) > 0) {
    cat("Creating box plot comparisons...\n")
    
    # Create box plots for first 2 numerical vs first 2 categorical
    for (num_col in head(numerical_cols, 2)) {
      for (cat_col in head(categorical_cols, 2)) {
        if (length(unique(df[[cat_col]])) <= 10) {
          tryCatch({
            png(file.path("plots", paste0("boxplot_", num_col, "_by_", cat_col, ".png")), 
                width = 1200, height = 800, res = 150)
            
            par(mar = c(8, 5, 4, 2))
            boxplot(df[[num_col]] ~ df[[cat_col]], 
                    col = rainbow(length(unique(df[[cat_col]])), alpha = 0.7),
                    main = paste(num_col, "by", cat_col),
                    xlab = cat_col, ylab = num_col,
                    cex.main = 1.4, cex.lab = 1.2, cex.axis = 1.1,
                    las = 2)
            
            dev.off()
            
            # Export box plot statistics
            box_stats <- aggregate(df[[num_col]], by = list(df[[cat_col]]), 
                                 function(x) c(
                                   count = length(x[!is.na(x)]),
                                   mean = round(mean(x, na.rm = TRUE), 3),
                                   median = round(median(x, na.rm = TRUE), 3),
                                   q1 = round(quantile(x, 0.25, na.rm = TRUE), 3),
                                   q3 = round(quantile(x, 0.75, na.rm = TRUE), 3),
                                   min = round(min(x, na.rm = TRUE), 3),
                                   max = round(max(x, na.rm = TRUE), 3)
                                 ))
            
            box_stats_df <- data.frame(
              category = box_stats[, 1],
              do.call(rbind, box_stats[, 2])
            )
            names(box_stats_df)[1] <- cat_col
            
            write.csv(box_stats_df, 
                     file.path("exports", paste0("boxplot_stats_", num_col, "_by_", cat_col, ".csv")), 
                     row.names = FALSE)
            
            cat(paste("  ✓ Saved box plot:", num_col, "by", cat_col, "\n"))
          }, error = function(e) {
            cat(paste("  ✗ Error creating box plot for", num_col, "by", cat_col, "\n"))
          })
        }
      }
    }
  }
}

# --- Main Analysis Function ---
main_analysis <- function() {
  start_time <- Sys.time()
  
  # Discover and load data
  file_path <- discover_data()
  df <- load_data(file_path)
  
  # Basic overview
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
    metric = c("Dataset Name", "Total Rows", "Total Columns", "Numerical Columns", 
              "Categorical Columns", "Total Missing Values", "Missing Percentage"),
    value = c(basename(file_path), nrow(df), ncol(df), length(numerical_cols),
             length(categorical_cols), sum(is.na(df)), 
             paste0(round(sum(is.na(df)) / (nrow(df) * ncol(df)) * 100, 2), "%"))
  )
  write.csv(dataset_info, file.path("exports", "dataset_overview.csv"), row.names = FALSE)
  
  # Export missing values report
  missing_report <- data.frame(
    variable = names(df),
    missing_count = sapply(df, function(x) sum(is.na(x))),
    missing_percentage = round(sapply(df, function(x) sum(is.na(x)) / length(x) * 100), 2),
    data_type = sapply(df, class)
  )
  write.csv(missing_report, file.path("exports", "missing_values_report.csv"), row.names = FALSE)
  
  # Export summary statistics
  cat("\n=== EXPORTING ANALYSIS RESULTS ===\n")
  export_summary_stats(df)
  
  # Create visualizations
  cat("\n=== CREATING VISUALIZATIONS ===\n")
  if (length(numerical_cols) > 0) {
    create_histograms(df, numerical_cols)
  }
  
  if (length(categorical_cols) > 0) {
    create_barplots(df, categorical_cols)
  }
  
  if (length(numerical_cols) > 1) {
    create_correlation_matrix(df, numerical_cols)
  }
  
  # Create box plots
  create_boxplots(df, numerical_cols, categorical_cols)
  
  # Generate comprehensive file inventory
  plot_files <- list.files("plots", pattern = "\\.png$")
  export_files <- list.files("exports", pattern = "\\.csv$")
  
  file_inventory <- data.frame(
    file_type = c(rep("plot", length(plot_files)), rep("export", length(export_files))),
    file_name = c(plot_files, export_files),
    file_path = c(file.path("plots", plot_files), file.path("exports", export_files)),
    file_size_kb = c(
      round(file.info(file.path("plots", plot_files))$size / 1024, 1),
      round(file.info(file.path("exports", export_files))$size / 1024, 1)
    )
  )
  write.csv(file_inventory, file.path("exports", "file_inventory.csv"), row.names = FALSE)
  
  # Calculate processing time
  end_time <- Sys.time()
  processing_time <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)
  
  # Create final analysis report
  analysis_summary <- data.frame(
    metric = c("Analysis Timestamp", "Processing Time (seconds)", "Dataset Name", 
              "Total Rows", "Total Columns", "Plots Generated", "CSV Files Generated",
              "Total Missing Values", "Analysis Status"),
    value = c(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), processing_time, basename(file_path),
             nrow(df), ncol(df), length(plot_files), length(export_files),
             sum(is.na(df)), "Complete")
  )
  write.csv(analysis_summary, file.path("exports", "final_analysis_summary.csv"), row.names = FALSE)
  
  # Final summary
  cat("\n╔══════════════════════════════════════════════════════════════╗\n")
  cat("║                    ANALYSIS COMPLETE                        ║\n")
  cat("╚══════════════════════════════════════════════════════════════╝\n")
  cat(paste("📊 Generated", length(plot_files), "plots and", length(export_files), "CSV files\n"))
  cat(paste("⏱️  Processing time:", processing_time, "seconds\n"))
  cat("\n📂 Output Locations:\n")
  cat("   📊 Visualizations: plots/\n")
  cat("   📈 Data exports: exports/\n")
  cat("   📋 Summary: exports/final_analysis_summary.csv\n\n")
  
  cat("📊 Generated Plots:\n")
  for (file in plot_files) {
    cat(paste("   •", file, "\n"))
  }
  
  cat("\n📈 Generated CSV Files:\n")
  for (file in export_files) {
    cat(paste("   •", file, "\n"))
  }
  
  return(df)
}

# --- Execute Analysis ---
tryCatch({
  result <- main_analysis()
  cat("\n🎉 SUCCESS: Comprehensive analysis completed successfully!\n")
  cat("All visualizations and data exports are ready for use.\n\n")
}, error = function(e) {
  cat(paste("\n❌ ERROR:", e$message, "\n"))
  cat("Please check your data file and try again.\n")
})