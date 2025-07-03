#!/usr/bin/env Rscript

# ==============================================================================
# SIMPLIFIED DATA ANALYSIS SCRIPT WITH CSV EXPORTS
# ==============================================================================
# This script performs data analysis using base R functions
# and exports all results to CSV format
# ==============================================================================

cat("╔══════════════════════════════════════════════════════════════╗\n")
cat("║              SIMPLIFIED DATA ANALYSIS TOOL                  ║\n")
cat("║                    WITH CSV EXPORTS                          ║\n")
cat("╚══════════════════════════════════════════════════════════════╝\n\n")

# --- Configuration ---
set.seed(42)
options(warn = -1)

# Create output directories
output_dirs <- c("plots", "exports", "reports")
for (dir in output_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat(paste("Created directory:", dir, "\n"))
  }
}

# --- Helper function to try installing packages ---
try_install_package <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(paste("Trying to install", pkg, "...\n"))
    tryCatch({
      install.packages(pkg, repos = "https://cloud.r-project.org/", quiet = TRUE)
      library(pkg, character.only = TRUE, quietly = TRUE)
      return(TRUE)
    }, error = function(e) {
      cat(paste("Could not install", pkg, "- will use alternatives\n"))
      return(FALSE)
    })
  }
  return(TRUE)
}

# --- Try to load essential packages (optional) ---
has_ggplot2 <- try_install_package("ggplot2")

# --- Data Discovery ---
discover_data <- function() {
  cat("=== Data Discovery ===\n")
  
  # Look for data files
  data_files <- list.files(pattern = "\\.(csv|xlsx|xls)$", ignore.case = TRUE)
  data_files <- data_files[!grepl("sample_data", data_files)]
  
  if (length(data_files) == 0) {
    cat("No data files found. Creating sample dataset...\n")
    
    # Create sample data
    n <- 500
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
      Performance_Rating = sample(c("Poor", "Fair", "Good", "Excellent"), n, 
                                 replace = TRUE, prob = c(0.1, 0.2, 0.5, 0.2)),
      stringsAsFactors = FALSE
    )
    
    # Add some missing values
    df$Income[sample(nrow(df), n * 0.02)] <- NA
    df$Score[sample(nrow(df), n * 0.01)] <- NA
    
    write.csv(df, "sample_data.csv", row.names = FALSE)
    cat("✓ Sample data created: sample_data.csv\n")
    return("sample_data.csv")
    
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
    # Use base R read.csv
    if (grepl("\\.csv$", file_path, ignore.case = TRUE)) {
      df <- read.csv(file_path, stringsAsFactors = FALSE)
    } else {
      stop("This version only supports CSV files. Please convert your data to CSV format.")
    }
    
    if (nrow(df) == 0) stop("Dataset is empty")
    
    cat(paste("✓ Loaded", nrow(df), "rows and", ncol(df), "columns\n"))
    return(df)
    
  }, error = function(e) {
    stop(paste("Error loading data:", e$message))
  })
}

# --- Export Functions ---
export_summary_stats <- function(df) {
  cat("Exporting summary statistics...\n")
  
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
      missing = sapply(numerical_cols, function(x) sum(is.na(df[[x]]))),
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

# --- Visualization Functions ---
create_histograms <- function(df, numerical_cols) {
  cat("Creating histograms...\n")
  
  for (col in numerical_cols) {
    tryCatch({
      col_data <- df[[col]][!is.na(df[[col]])]
      
      if (has_ggplot2) {
        # Use ggplot2 if available
        library(ggplot2)
        p <- ggplot(df, aes_string(x = col)) +
          geom_histogram(bins = 30, fill = "skyblue", color = "darkblue", alpha = 0.7) +
          geom_vline(xintercept = mean(col_data), color = "red", linetype = "dashed") +
          labs(title = paste("Distribution of", col),
               subtitle = paste("Mean:", round(mean(col_data), 2), "| N:", length(col_data))) +
          theme_minimal()
        
        ggsave(file.path("plots", paste0("histogram_", col, ".png")), 
               plot = p, width = 10, height = 6, dpi = 300)
      } else {
        # Use base R
        png(file.path("plots", paste0("histogram_", col, ".png")), 
            width = 800, height = 600, res = 100)
        hist(col_data, breaks = 30, col = "skyblue", border = "darkblue",
             main = paste("Distribution of", col),
             xlab = col, ylab = "Frequency")
        abline(v = mean(col_data), col = "red", lty = 2, lwd = 2)
        legend("topright", paste("Mean:", round(mean(col_data), 2)), col = "red", lty = 2)
        dev.off()
      }
      
      # Export histogram data
      hist_data <- hist(col_data, breaks = 30, plot = FALSE)
      hist_export <- data.frame(
        bin_start = hist_data$breaks[-length(hist_data$breaks)],
        bin_end = hist_data$breaks[-1],
        count = hist_data$counts,
        density = hist_data$density
      )
      write.csv(hist_export, file.path("exports", paste0("histogram_data_", col, ".csv")), row.names = FALSE)
      
      cat(paste("  ✓ Saved histogram for", col, "\n"))
    }, error = function(e) {
      cat(paste("  ✗ Error creating histogram for", col, "\n"))
    })
  }
}

create_barplots <- function(df, categorical_cols) {
  cat("Creating bar plots...\n")
  
  for (col in categorical_cols) {
    if (length(unique(df[[col]])) < 20) {
      tryCatch({
        freq_data <- table(df[[col]])
        
        if (has_ggplot2) {
          library(ggplot2)
          freq_df <- data.frame(category = names(freq_data), count = as.numeric(freq_data))
          
          p <- ggplot(freq_df, aes(x = reorder(category, count), y = count)) +
            geom_col(fill = "lightgreen", color = "darkgreen") +
            coord_flip() +
            labs(title = paste("Distribution of", col), x = col, y = "Count") +
            theme_minimal()
          
          ggsave(file.path("plots", paste0("barplot_", col, ".png")), 
                 plot = p, width = 10, height = 6, dpi = 300)
        } else {
          png(file.path("plots", paste0("barplot_", col, ".png")), 
              width = 800, height = 600, res = 100)
          barplot(sort(freq_data), horiz = TRUE, col = "lightgreen",
                  main = paste("Distribution of", col), xlab = "Count")
          dev.off()
        }
        
        # Export frequency data
        freq_export <- data.frame(
          category = names(freq_data),
          count = as.numeric(freq_data),
          percentage = round(as.numeric(freq_data) / sum(freq_data) * 100, 2)
        )
        write.csv(freq_export, file.path("exports", paste0("frequency_", col, ".csv")), row.names = FALSE)
        
        cat(paste("  ✓ Saved bar plot for", col, "\n"))
      }, error = function(e) {
        cat(paste("  ✗ Error creating bar plot for", col, "\n"))
      })
    }
  }
}

create_correlation_matrix <- function(df, numerical_cols) {
  if (length(numerical_cols) > 1) {
    cat("Creating correlation matrix...\n")
    
    tryCatch({
      cor_matrix <- cor(df[numerical_cols], use = "pairwise.complete.obs")
      
      # Create correlation plot
      png(file.path("plots", "correlation_matrix.png"), width = 800, height = 800, res = 100)
      
      # Simple heatmap using base R
      image(1:ncol(cor_matrix), 1:nrow(cor_matrix), t(cor_matrix), 
            col = heat.colors(100), axes = FALSE,
            main = "Correlation Matrix", xlab = "", ylab = "")
      axis(1, at = 1:ncol(cor_matrix), labels = colnames(cor_matrix), las = 2)
      axis(2, at = 1:nrow(cor_matrix), labels = rownames(cor_matrix), las = 2)
      
      # Add correlation values
      for (i in 1:nrow(cor_matrix)) {
        for (j in 1:ncol(cor_matrix)) {
          text(j, i, round(cor_matrix[i, j], 2), cex = 0.8)
        }
      }
      dev.off()
      
      # Export correlation matrix
      cor_df <- as.data.frame(cor_matrix)
      cor_df$variable <- rownames(cor_df)
      cor_df <- cor_df[, c("variable", colnames(cor_matrix))]
      write.csv(cor_df, file.path("exports", "correlation_matrix.csv"), row.names = FALSE)
      
      cat("  ✓ Saved correlation matrix\n")
    }, error = function(e) {
      cat(paste("  ✗ Error creating correlation matrix:", e$message, "\n"))
    })
  }
}

# --- Main Analysis Function ---
main_analysis <- function() {
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
  
  # Export basic info
  dataset_info <- data.frame(
    metric = c("Dataset Name", "Total Rows", "Total Columns", "Numerical Columns", 
              "Categorical Columns", "Total Missing Values"),
    value = c(basename(file_path), nrow(df), ncol(df), length(numerical_cols),
             length(categorical_cols), sum(is.na(df)))
  )
  write.csv(dataset_info, file.path("exports", "dataset_overview.csv"), row.names = FALSE)
  
  # Export missing values report
  missing_report <- data.frame(
    variable = names(df),
    missing_count = sapply(df, function(x) sum(is.na(x))),
    missing_percentage = round(sapply(df, function(x) sum(is.na(x)) / length(x) * 100), 2)
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
  
  # Generate file inventory
  plot_files <- list.files("plots", pattern = "\\.png$")
  export_files <- list.files("exports", pattern = "\\.csv$")
  
  file_inventory <- data.frame(
    file_type = c(rep("plot", length(plot_files)), rep("export", length(export_files))),
    file_name = c(plot_files, export_files),
    file_path = c(file.path("plots", plot_files), file.path("exports", export_files))
  )
  write.csv(file_inventory, file.path("exports", "file_inventory.csv"), row.names = FALSE)
  
  # Final summary
  cat("\n=== ANALYSIS COMPLETE ===\n")
  cat(paste("Generated", length(plot_files), "plots and", length(export_files), "CSV files\n"))
  cat("\n📊 Plots saved in: plots/\n")
  cat("📈 Data exported to: exports/\n")
  cat("📋 Summary report: exports/dataset_overview.csv\n\n")
  
  cat("Files generated:\n")
  for (file in plot_files) {
    cat(paste("  📊", file, "\n"))
  }
  for (file in export_files) {
    cat(paste("  📈", file, "\n"))
  }
  
  return(df)
}

# --- Execute Analysis ---
tryCatch({
  result <- main_analysis()
  cat("\n🎉 SUCCESS: Analysis completed!\n")
}, error = function(e) {
  cat(paste("\n❌ ERROR:", e$message, "\n"))
  cat("Please check your data file and try again.\n")
})