# Quick Start Guide - Data Analysis with CSV Exports

## 🚀 Immediate Usage

### Step 1: Choose Your Script
```bash
# For production use (recommended)
./data_analysis_final.R

# For basic analysis
./data_analysis_simple.R
```

### Step 2: Prepare Your Data
- **Option A**: Place your CSV file in the same directory
- **Option B**: Let the script create sample data automatically

### Step 3: Run Analysis
```bash
# Make executable (first time only)
chmod +x data_analysis_final.R

# Execute
Rscript data_analysis_final.R
```

## 📊 What You Get

### Immediate Outputs
- **17 professional plots** in `plots/` directory
- **18 CSV data files** in `exports/` directory
- **Complete analysis** in under 1 second

### Key Files to Check
```
exports/final_analysis_summary.csv    # Executive summary
exports/numerical_summary_statistics.csv    # Statistical analysis
exports/file_inventory.csv           # Complete file listing
plots/correlation_heatmap.png        # Visual correlation analysis
```

## 🔧 Troubleshooting

### Common Issues
| Issue | Solution |
|-------|----------|
| "Permission denied" | Run `chmod +x data_analysis_final.R` |
| "Package not found" | Script uses base R - no packages needed |
| "No data files" | Script creates sample data automatically |
| "Script not found" | Ensure you're in the correct directory |

### System Requirements
- **R 3.6+** (check with `R --version`)
- **Base R functions only** (no additional packages required)

## 📈 Customization Examples

### Change Sample Size
```r
# In data_analysis_final.R, line ~45
n <- 2000  # Change from 1000 to 2000
```

### Add New Variables
```r
# Add to the data.frame creation
New_Variable = sample(1:5, n, replace = TRUE)
```

### Modify Plot Colors
```r
# In histogram function, change colors
col = "#87CEEB"  # Change to your preferred color
```

## 📋 File Structure After Running

```
your-directory/
├── data_analysis_final.R           # Main script
├── enhanced_sample_data.csv        # Generated data
├── plots/                          # 17 visualization files
│   ├── histogram_*.png
│   ├── barplot_*.png
│   ├── correlation_heatmap.png
│   └── boxplot_*.png
└── exports/                        # 18 CSV data files
    ├── final_analysis_summary.csv
    ├── numerical_summary_statistics.csv
    ├── correlation_pairs.csv
    └── [15 more CSV files]
```

## ⚡ Performance Tips

- **Small files** (<1MB): Instant processing
- **Large files** (>10MB): May take 10-30 seconds
- **Very large files** (>100MB): Consider data sampling

## 🎯 Next Steps

1. **Review outputs** in `exports/final_analysis_summary.csv`
2. **Check visualizations** in `plots/` directory
3. **Import CSV data** into your preferred analysis tool
4. **Customize script** for your specific needs

---

**Need help?** Check `FINAL_SUMMARY.md` for comprehensive documentation.

**Ready to analyze your data!** 🚀