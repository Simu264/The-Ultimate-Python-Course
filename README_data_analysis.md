# Comprehensive Data Analysis Script with CSV Exports

## Overview

This enhanced R script performs automated exploratory data analysis on your datasets and exports all results in both visual (PNG) and tabular (CSV) formats. It's designed to be fully executable with minimal setup and provides comprehensive insights into your data.

## Features

### 🚀 **Automated Analysis**
- Automatic data discovery and loading (CSV, XLSX, XLS)
- Sample data generation if no data files are found
- Comprehensive statistical analysis
- Professional visualizations

### 📊 **Visualizations Generated**
- Enhanced histograms with density curves and statistics
- Bar plots for categorical variables with frequencies
- Correlation heatmaps (multiple styles)
- Box plots comparing numerical vs categorical variables
- All plots saved as high-resolution PNG files (300 DPI)

### 📈 **CSV Exports**
- **Summary Statistics**: Mean, median, SD, min, max for numerical columns
- **Frequency Tables**: Count and percentages for categorical columns
- **Correlation Matrix**: Both wide and long format correlation data
- **Missing Values Report**: Detailed missing data analysis
- **Histogram Data**: Bin information for all histograms
- **Box Plot Statistics**: Quartiles and summary stats by groups
- **Dataset Overview**: Comprehensive dataset metadata

## Installation and Setup

### Prerequisites
- R (version 3.6 or higher)
- Internet connection for package installation

### Quick Start

1. **Make the script executable**:
   ```bash
   chmod +x data_analysis_script.R
   ```

2. **Run the script**:
   ```bash
   ./data_analysis_script.R
   ```
   OR
   ```bash
   Rscript data_analysis_script.R
   ```

3. **In R console**:
   ```r
   source("data_analysis_script.R")
   main()
   ```

## Usage

### Using Your Own Data
1. Place your data file (CSV, XLSX, or XLS) in the same directory as the script
2. Run the script - it will automatically detect and analyze your data

### Using Sample Data
- If no data files are found, the script creates a comprehensive sample dataset
- Sample includes 500 observations with multiple data types
- Perfect for testing and demonstration

## Output Structure

The script creates organized output directories:

```
📁 plots/                          # All visualizations
├── histogram_*.png                 # Distribution plots
├── barplot_*.png                   # Categorical frequency plots
├── correlation_heatmap.png         # ggplot2 correlation heatmap
├── correlation_matrix_corrplot.png # corrplot correlation matrix
└── boxplot_*_by_*.png             # Comparative box plots

📁 exports/                         # All CSV data exports
├── dataset_overview.csv            # Basic dataset information
├── numerical_summary_statistics.csv # Numerical variable stats
├── categorical_summary_statistics.csv # Categorical variable stats
├── correlation_matrix.csv          # Correlation matrix (wide format)
├── correlation_pairs.csv           # Correlation pairs (long format)
├── missing_values_report.csv       # Missing data analysis
├── histogram_data_*.csv            # Histogram bin data
├── frequency_*.csv                 # Categorical frequency data
├── boxplot_stats_*_by_*.csv       # Box plot statistics
├── final_analysis_report.csv       # Comprehensive summary
└── generated_files_inventory.csv   # List of all generated files
```

## Script Features

### 🔧 **Enhanced Error Handling**
- Graceful package installation with fallback options
- Comprehensive error messages and troubleshooting guidance
- Automatic recovery from common issues

### 📊 **Smart Data Processing**
- Automatic column type detection (numerical vs categorical)
- Intelligent handling of missing values
- Optimal visualization choices based on data characteristics

### 🎨 **Professional Visualizations**
- Clean, publication-ready plots
- Consistent color schemes and styling
- Statistical annotations (means, medians, counts)
- High-resolution output suitable for presentations

### 📈 **Comprehensive Exports**
- All analysis results exported to CSV format
- Data underlying every visualization available as CSV
- Structured output for further analysis in other tools

## Customization

### Modifying Sample Data
Edit the `discover_data()` function to customize the sample dataset:
```r
# Modify sample size
n <- 1000  # Change from 500 to 1000

# Add new variables
df$new_variable <- sample(1:5, n, replace = TRUE)
```

### Adjusting Visualization Parameters
Modify the plotting functions:
```r
# Change histogram bins
bins = 50  # Change from 30

# Adjust plot size
width = 12, height = 8  # Change dimensions
```

### Adding New Analysis Types
The modular structure makes it easy to add new analysis functions:
```r
create_new_analysis <- function(df) {
  # Your custom analysis here
  # Export results as CSV
  write_csv(results, file.path("exports", "new_analysis.csv"))
}
```

## Troubleshooting

### Common Issues

**Package Installation Fails**:
```r
# Manual installation
install.packages(c("readr", "dplyr", "ggplot2", "corrplot"))
```

**Memory Issues with Large Datasets**:
- The script is optimized for datasets up to ~100K rows
- For larger datasets, consider sampling or chunking

**Permission Errors**:
```bash
# Ensure write permissions
chmod 755 ./
```

### Error Messages

The script provides detailed error messages:
- 📁 File not found → Check file location and permissions
- 📊 Empty dataset → Verify data file integrity
- 🔧 Package issues → Check internet connection and R version

## Output Examples

### Summary Statistics CSV Format
```csv
variable,count,mean,median,sd,min,max,missing
Age,500,49.2,49,18.1,18,80,0
Income,490,55123.45,54876.32,19876.54,12000,98000,10
```

### Correlation Matrix CSV Format
```csv
variable,Age,Income,Score,Years_Experience
Age,1.000,0.654,0.123,0.876
Income,0.654,1.000,0.234,0.543
...
```

## Performance

- **Small datasets** (<1K rows): ~30 seconds
- **Medium datasets** (1K-10K rows): ~1-2 minutes  
- **Large datasets** (10K-100K rows): ~3-5 minutes

## Version History

- **v2.0**: Complete rewrite with CSV exports and enhanced visualizations
- **v1.0**: Basic analysis with plot generation

## Support

For issues or customization requests, check:
1. Error messages in the console output
2. Generated log files in the exports directory
3. R documentation for package-specific issues

---

**Ready to analyze your data? Simply run the script and let it do the work!** 🚀