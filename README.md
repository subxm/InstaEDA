# InstaEDA: Automated Exploratory Data Analysis Dashboard

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![R](https://img.shields.io/badge/R-4.0%2B-brightgreen)
![Shiny](https://img.shields.io/badge/Shiny-1.7%2B-red)
![License](https://img.shields.io/badge/license-MIT-green)

**A Professional, Production-Ready EDA Dashboard Built Entirely in R**

</div>

## Live Preview 
[https://subxm-insta-eda.share.connect.posit.cloud/]
---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Modules Explained](#modules-explained)
- [Screenshots](#screenshots)
- [Advanced Features](#advanced-features)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

**InstaEDA** is a sophisticated, web-based Exploratory Data Analysis (EDA) dashboard built entirely using R and Shiny. It provides instant, automated analysis of CSV datasets with interactive visualizations, comprehensive statistics, and professional reporting capabilities.

This project was designed as a **final-year academic project** showcasing advanced R programming, statistical analysis, and modern web dashboard development skills.

### Key Highlights

- ✅ **Zero-Code Analysis**: Upload and analyze data instantly
- ✅ **Interactive Dashboards**: Real-time, responsive visualizations
- ✅ **Comprehensive Statistics**: Automated summary statistics and distributions
- ✅ **Missing Value Analysis**: Detailed missing data detection and visualization
- ✅ **Correlation Analysis**: Interactive heatmaps and correlation matrices
- ✅ **Outlier Detection**: Multiple detection methods (IQR, Z-Score, Modified Z-Score)
- ✅ **Professional Reports**: Downloadable HTML/PDF reports
- ✅ **Modular Architecture**: Clean, maintainable code structure

---

## 🚀 Features

### 1. **Dataset Overview**
- Automatic detection of data types
- Row and column counts
- Data preview with interactive tables
- Type summary (numeric, factor, character)

### 2. **Missing Values Analysis**
- Missing value statistics
- Percentage calculations
- Interactive bar charts
- Missing data heatmap
- Pattern detection

### 3. **Summary Statistics**
- Mean, median, standard deviation
- Min, max, quartiles
- Skewness calculation
- Distribution comparisons
- Variable-specific boxplots

### 4. **Interactive Visualizations**
- Histogram
- Density plots
- Box plots
- Violin plots
- Bar charts
- Scatter plots
- Line plots
- Customizable bins and parameters

### 5. **Correlation Analysis**
- Pearson, Spearman, Kendall methods
- Interactive heatmaps
- Correlation matrices
- Strong correlation detection
- Threshold-based filtering

### 6. **Outlier Detection**
- IQR method
- Z-score method
- Modified Z-score method
- Visual outlier highlighting
- Detailed outlier statistics

### 7. **Report Generation**
- Customizable sections
- HTML/PDF formats
- Automatic content generation
- Professional formatting
- Timestamp inclusion

---

## 🛠 Tech Stack

### Core Technologies
- **R (4.0+)**: Primary programming language
- **Shiny**: Web application framework
- **shinydashboard**: Dashboard UI framework

### Data Manipulation & Analysis
- **dplyr**: Data manipulation
- **tidyr**: Data tidying
- **ggplot2**: Data visualization
- **plotly**: Interactive plots

### Additional Libraries
- **DT**: Interactive tables
- **corrplot**: Correlation visualization
- **scales**: Scale functions for visualization
- **viridis**: Color palettes
- **rmarkdown**: Report generation

---

## 📦 Installation

### Prerequisites

Ensure you have R (version 4.0 or higher) installed on your system.

### Step 1: Install R Packages

Open R or RStudio and run:

```r
# Install required packages
install.packages(c(
  "shiny",
  "shinydashboard",
  "dplyr",
  "tidyr",
  "ggplot2",
  "plotly",
  "DT",
  "corrplot",
  "scales",
  "viridis",
  "rmarkdown"
))
```

### Step 2: Clone/Download the Project

```bash
# Clone the repository (if using Git)
git clone https://github.com/yourusername/InstaEDA.git

# Or download and extract the ZIP file
```

### Step 3: Set Working Directory

```r
# In R/RStudio, set working directory to project folder
setwd("/path/to/InstaEDA")
```

---

## 🎮 Usage

### Running the Application

#### Method 1: Using RStudio
1. Open `app.R` in RStudio
2. Click the **"Run App"** button
3. The dashboard will open in your browser

#### Method 2: Using R Console
```r
# Navigate to project directory
setwd("/path/to/InstaEDA")

# Run the app
shiny::runApp()
```

### Using the Dashboard

1. **Upload Data**
   - Click "Browse..." in the sidebar
   - Select a CSV file (max 50MB)
   - Wait for upload confirmation

2. **Explore Tabs**
   - Navigate through different analysis tabs
   - View automated insights and visualizations

3. **Customize Analysis**
   - Select variables from dropdowns
   - Choose visualization types
   - Adjust parameters (bins, thresholds, etc.)

4. **Generate Reports**
   - Click "Download Report" in sidebar
   - Or use the Report tab for custom reports
   - Choose sections and format (HTML/PDF)

### Sample Data

A sample dataset (`sample_data.csv`) is included for testing. It contains:
- 40 rows
- 10 columns (mix of numeric and categorical)
- Realistic employee data

---

## 📁 Project Structure

```
InstaEDA/
│
├── app.R                    # Main application file
├── global.R                 # Global configuration and functions
│
├── modules/                 # Modular components
│   ├── upload_module.R      # File upload functionality
│   ├── overview_module.R    # Dataset overview
│   ├── missing_module.R     # Missing values analysis
│   ├── summary_stats_module.R  # Summary statistics
│   ├── visualization_module.R  # Interactive visualizations
│   ├── correlation_module.R    # Correlation analysis
│   ├── outliers_module.R       # Outlier detection
│   └── report_module.R         # Report generation
│
├── www/                     # Static files
│   └── custom.css           # Custom styling
│
├── reports/                 # Generated reports (auto-created)
│
├── sample_data.csv          # Sample dataset for testing
└── README.md                # This file
```

---

## 🧩 Modules Explained

### 1. Upload Module (`upload_module.R`)
Handles file upload, validation, and error handling. Supports CSV files up to 50MB.

### 2. Overview Module (`overview_module.R`)
Displays dataset dimensions, column types, data preview, and type summary.

### 3. Missing Module (`missing_module.R`)
Analyzes missing values with statistics, bar charts, and heatmaps.

### 4. Summary Stats Module (`summary_stats_module.R`)
Generates comprehensive statistical summaries for numeric variables.

### 5. Visualization Module (`visualization_module.R`)
Creates dynamic, interactive plots based on user selection and parameters.

### 6. Correlation Module (`correlation_module.R`)
Computes and visualizes correlations using various methods.

### 7. Outliers Module (`outliers_module.R`)
Detects outliers using IQR, Z-Score, or Modified Z-Score methods.

### 8. Report Module (`report_module.R`)
Generates downloadable HTML/PDF reports with customizable sections.

---

## 🎨 Screenshots

### Dashboard Overview
![Overview Tab](screenshots/overview.png)

### Interactive Visualizations
![Visualizations Tab](screenshots/visualizations.png)

### Correlation Heatmap
![Correlation Tab](screenshots/correlation.png)

---

## 🔥 Advanced Features

### Custom Themes
The application uses a professional blue theme with custom CSS for enhanced visual appeal.

### Reactive Programming
Efficient reactive expressions minimize unnecessary computations and ensure smooth performance.

### Error Handling
Comprehensive error handling with user-friendly notifications for common issues.

### Responsive Design
Dashboard adapts to different screen sizes and devices.

### Modular Architecture
Clean separation of concerns makes the code easy to maintain and extend.

---

## 🐛 Troubleshooting

### Common Issues

#### **Issue**: Packages not installing
**Solution**: 
```r
# Try installing with dependencies
install.packages("package_name", dependencies = TRUE)

# Or use BiocManager for some packages
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("package_name")
```

#### **Issue**: App not loading
**Solution**:
- Check that all packages are installed
- Ensure working directory is set correctly
- Check R console for error messages

#### **Issue**: File upload fails
**Solution**:
- Verify CSV format is correct
- Check file size (must be < 50MB)
- Ensure no special characters in column names

#### **Issue**: PDF report generation fails
**Solution**:
```r
# Install additional dependencies for PDF
install.packages("tinytex")
tinytex::install_tinytex()
```

---

## 📊 Performance Considerations

- **Large Datasets**: The app handles datasets up to 50MB efficiently
- **Sampling**: For very large datasets, consider sampling for visualizations
- **Memory**: Monitor R memory usage with `memory.size()` (Windows) or `gc()`

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com
- LinkedIn: [Your Profile](https://linkedin.com/in/yourprofile)

---

## 🙏 Acknowledgments

- R Core Team for the R language
- RStudio team for Shiny framework
- Hadley Wickham for tidyverse packages
- The R community for excellent documentation

---

## 📚 References

- [Shiny Documentation](https://shiny.rstudio.com/)
- [ggplot2 Documentation](https://ggplot2.tidyverse.org/)
- [dplyr Documentation](https://dplyr.tidyverse.org/)
- [R for Data Science Book](https://r4ds.had.co.nz/)

---

<div align="center">

**Built with ❤️ using R and Shiny**

⭐ Star this repository if you find it helpful!

</div>
