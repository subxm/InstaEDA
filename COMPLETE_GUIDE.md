# ============================================================================
# InstaEDA - Complete Setup & Usage Guide
# Step-by-Step Instructions for Running Your EDA Dashboard
# ============================================================================

## 📦 PART 1: INSTALLATION

### Prerequisites
- **R**: Version 4.0 or higher
- **RStudio**: Recommended (optional but easier)
- **Internet Connection**: For package downloads

### Option A: Using RStudio (Recommended)

1. **Download and Install R**
   - Visit: https://cran.r-project.org/
   - Download for your OS (Windows/Mac/Linux)
   - Run installer and follow prompts

2. **Download and Install RStudio**
   - Visit: https://posit.co/download/rstudio-desktop/
   - Download free Desktop version
   - Run installer and follow prompts

3. **Extract Project Files**
   - Extract the InstaEDA folder to your desired location
   - Example: `C:/Users/YourName/Documents/InstaEDA`

4. **Open Project in RStudio**
   - Launch RStudio
   - File → Open File
   - Navigate to InstaEDA folder
   - Open `app.R`

5. **Install Required Packages**
   - In RStudio console, type:
   ```r
   setwd("C:/path/to/InstaEDA")  # Set your actual path
   source("install_packages.R")
   ```
   - Wait for all packages to install (5-10 minutes)

6. **Run the Application**
   - Click the "Run App" button (top-right of editor)
   - Or run in console:
   ```r
   shiny::runApp()
   ```

### Option B: Using R Console

1. **Open R Console**

2. **Set Working Directory**
   ```r
   setwd("C:/path/to/InstaEDA")
   ```

3. **Install Packages**
   ```r
   source("install_packages.R")
   ```

4. **Run App**
   ```r
   shiny::runApp()
   ```

---

## 🚀 PART 2: FIRST TIME USAGE

### Step 1: Launch the Application

When you run the app, a browser window will open showing the dashboard.

**Default URL**: http://127.0.0.1:XXXX (port number varies)

### Step 2: Upload Sample Data

1. **Locate the Upload Section**
   - Look at the left sidebar
   - Find "Upload CSV File" section
   
2. **Click "Browse..."**
   - Navigate to InstaEDA folder
   - Select `sample_data.csv`
   - Click "Open"

3. **Wait for Confirmation**
   - You'll see: "File uploaded successfully! (40 rows, 15 columns)"
   - The dashboard will automatically populate

### Step 3: Explore the Tabs

Navigate through each tab in the sidebar:

#### 📊 Overview Tab
- **What you'll see**:
  * Blue box: Number of rows (1,200)
  * Green box: Number of columns (15)
  * Yellow box: Numeric columns (8)
  * Red box: Factor columns (4)
  * Data preview table
  * Data type summary

#### ⚠️ Missing Data Tab
- **What you'll see**:
  * Table showing columns with missing values
  * Bar chart of missing percentages
  * Heatmap showing missing patterns

#### 📈 Summary Stats Tab
- **What you'll see**:
  * Comprehensive statistics table
  * Distribution overview plots
  * Individual variable statistics

#### 📉 Visualizations Tab
- **How to use**:
  1. Select plot type (Histogram, Boxplot, etc.)
  2. Choose X variable
  3. Choose Y variable (if applicable)
  4. Adjust parameters
  5. Click "Generate Plot"

#### 🔗 Correlation Tab
- **What you'll see**:
  * Interactive correlation heatmap
  * Correlation matrix table
  * Strong correlations table

#### 🎯 Outliers Tab
- **How to use**:
  1. Select a numeric variable
  2. Choose detection method
  3. Adjust threshold
  4. Click "Detect Outliers"

---

## 📖 PART 3: USING YOUR OWN DATA

### Data Preparation Checklist

Before uploading your CSV file, ensure:

✅ **Format**
- File extension is .csv
- First row contains column headers
- No merged cells
- No summary rows

✅ **Column Names**
- No spaces (use underscores: `column_name`)
- No special characters (except underscore)
- Start with letter (not number)
- No duplicate names

✅ **Data Quality**
- Consistent data types per column
- Date format: YYYY-MM-DD
- Remove trailing spaces
- UTF-8 encoding

### Example of Good vs Bad Data

**❌ BAD:**
```csv
Employee Name,Age,Salary ($),Date Joined
John Doe,25,"50,000",01/15/2020
Jane Smith,thirty,55000,2021-01-15
,28,60000,
```

**✅ GOOD:**
```csv
Employee_Name,Age,Salary,Date_Joined
John_Doe,25,50000,2020-01-15
Jane_Smith,30,55000,2021-01-15
Bob_Johnson,28,60000,2019-06-01
```

### Upload Steps

1. **Prepare your CSV file** (follow checklist above)
2. **Click "Browse..."** in sidebar
3. **Select your file** (max 50MB)
4. **Wait for upload** (progress bar will show)
5. **Check confirmation** (should see success message)

---

## 🎨 PART 4: CREATING VISUALIZATIONS

### Histogram Example

1. Go to **Visualizations** tab
2. Select **Plot Type**: Histogram
3. Select **X Variable**: Age (or any numeric variable)
4. Adjust **Number of Bins**: 30
5. Check **Show Mean Line** (optional)
6. Click **Generate Plot**

### Scatter Plot Example

1. Select **Plot Type**: Scatter Plot
2. Select **X Variable**: Age
3. Select **Y Variable**: Salary
4. Select **Color By**: Department (optional)
5. Click **Generate Plot**
   - You'll see correlation line automatically

### Box Plot Example

1. Select **Plot Type**: Box Plot
2. Select **X Variable**: Salary
3. Select **Color By**: Department
4. Click **Generate Plot**

---

## 📄 PART 5: GENERATING REPORTS

### Quick Report (Sidebar Button)

1. **Click "Download Report"** in sidebar
2. Report generates automatically
3. Opens download dialog
4. Save to your location

**Contents**: Overview, summary statistics, basic visualizations

### Custom Report (Not in sidebar - future feature)

For now, use the quick report or take screenshots of individual tabs.

---

## 🔧 PART 6: TROUBLESHOOTING

### Issue: Packages Won't Install

**Error**: "package 'xxx' is not available"

**Solutions**:
```r
# Try installing from CRAN directly
install.packages("package_name", repos="https://cran.r-project.org")

# Or install all dependencies
install.packages("package_name", dependencies = TRUE)

# Check R version
R.version.string  # Should be 4.0+
```

### Issue: App Won't Start

**Error**: "Error in shiny::runApp()"

**Solutions**:
```r
# Check working directory
getwd()
setwd("/correct/path/to/InstaEDA")

# Verify app.R exists
file.exists("app.R")

# Check for missing packages
source("install_packages.R")

# Restart R session
.rs.restartR()  # In RStudio
```

### Issue: File Upload Fails

**Error**: "Error reading file"

**Solutions**:
- Check file is valid CSV
- Verify file size < 50MB
- Remove special characters from file name
- Check for proper UTF-8 encoding
- Try opening CSV in Excel/text editor first

### Issue: Plots Not Showing

**Solutions**:
- Click "Generate Plot" button
- Check variable selection is valid
- Verify data has values (not all NA)
- Refresh browser page
- Check browser console for errors (F12)

### Issue: Report Download Fails

**Error**: "Error generating report"

**For HTML reports**:
```r
# Should work without additional setup
```

**For PDF reports**:
```r
# Install LaTeX
install.packages("tinytex")
tinytex::install_tinytex()
```

---

## 💡 PART 7: TIPS & BEST PRACTICES

### Performance Tips

1. **For Large Files**:
   - Consider sampling before upload
   - Close other browser tabs
   - Use Chrome/Firefox (not Safari)

2. **Memory Management**:
   ```r
   # Check memory usage
   memory.size()  # Windows
   gc()           # Garbage collection
   ```

3. **Faster Rendering**:
   - Reduce number of bins in histograms
   - Limit scatter plot points
   - Use simpler plot types first

### Analysis Tips

1. **Start with Overview**
   - Always check data structure first
   - Verify row/column counts
   - Identify data types

2. **Check for Missing Data**
   - Go to Missing Data tab immediately
   - Decide on handling strategy
   - Document missing patterns

3. **Explore Distributions**
   - Use Summary Stats tab
   - Create histograms for key variables
   - Look for outliers

4. **Find Relationships**
   - Use Correlation tab
   - Create scatter plots
   - Look for patterns

### Documentation Tips

1. **Take Screenshots**
   - Use Snipping Tool (Windows) or Cmd+Shift+4 (Mac)
   - Capture interesting findings
   - Save for presentations

2. **Export Data**
   - Download reports regularly
   - Export correlation matrices
   - Save outlier lists

3. **Keep Notes**
   - Document your findings
   - Note interesting patterns
   - Record data issues

---

## 🎓 PART 8: FOR ACADEMIC PRESENTATION

### Demo Preparation

1. **Before Viva**:
   - Test app with multiple datasets
   - Prepare 2-3 example analyses
   - Have backup data ready
   - Practice navigation

2. **Key Points to Demonstrate**:
   - File upload process
   - Automated analysis features
   - Interactive visualizations
   - Report generation
   - Code structure (if asked)

3. **Expected Questions**:

   **Q**: Why did you choose Shiny?
   **A**: Shiny provides native R integration, reactive programming for efficiency, and professional UI components. It's ideal for data science applications.

   **Q**: How do you handle errors?
   **A**: Comprehensive try-catch blocks, input validation, user-friendly error messages, and graceful degradation.

   **Q**: Can this scale to big data?
   **A**: Current version handles up to 50MB. Can be extended with database connections, sampling strategies, and server-side processing.

   **Q**: What statistical methods are used?
   **A**: Descriptive statistics (mean, median, SD), correlation analysis (Pearson, Spearman), outlier detection (IQR, Z-score, Modified Z-score).

   **Q**: How is it different from existing tools?
   **A**: Combines automation, interactivity, and report generation in one platform. Modular design allows easy extension. Open source and R-based for reproducibility.

### Code Walkthrough Structure

1. **Start with `app.R`**
   - Explain overall structure
   - Show UI/Server separation

2. **Demonstrate Modules**
   - Pick 1-2 modules to explain
   - Show how they communicate

3. **Highlight Key Features**
   - Reactive programming
   - Error handling
   - Modular design

---

## 📞 PART 9: GETTING HELP

### Resources

**Documentation**:
- README.md - Comprehensive overview
- QUICK_START.md - Quick reference
- PROJECT_SUMMARY.md - Technical details

**R/Shiny Resources**:
- [Shiny Tutorial](https://shiny.rstudio.com/tutorial/)
- [R for Data Science](https://r4ds.had.co.nz/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/shiny)

**Statistical Help**:
- [Statistics How To](https://www.statisticshowto.com/)
- [R Documentation](https://www.rdocumentation.org/)

### Contact

For project-specific questions:
- Check troubleshooting section first
- Review error messages carefully
- Test with sample data
- Provide error details when asking for help

---

## ✅ PART 10: SUCCESS CHECKLIST

Before submitting/presenting, verify:

- [ ] All packages installed successfully
- [ ] App runs without errors
- [ ] Sample data uploads correctly
- [ ] All tabs display properly
- [ ] Visualizations generate correctly
- [ ] Reports download successfully
- [ ] Documentation is complete
- [ ] Code is commented
- [ ] Project is organized
- [ ] Demo is prepared

---

## 🎉 CONGRATULATIONS!

You now have a fully functional, professional EDA dashboard!

**Next Steps**:
1. Practice with sample data
2. Try your own datasets
3. Explore all features
4. Generate reports
5. Prepare for presentation

**Remember**: This is YOUR project. Understand it, customize it, and be proud of it!

Good luck with your project! 🚀📊✨

---

*Last Updated: February 2026*
*Version: 1.0.0*
