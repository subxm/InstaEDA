# ============================================================================
# InstaEDA - Architecture & Workflow Documentation
# Technical Design and Data Flow Diagrams
# ============================================================================

## 📐 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                        │
│                      (Shiny Dashboard)                       │
├─────────────────────────────────────────────────────────────┤
│  Sidebar              │         Main Content Area           │
│  ┌─────────────┐      │  ┌──────────────────────────────┐  │
│  │ File Upload │      │  │    Overview Tab              │  │
│  │ Select Vars │      │  │    Missing Data Tab          │  │
│  │ Download    │      │  │    Summary Stats Tab         │  │
│  └─────────────┘      │  │    Visualizations Tab        │  │
│                       │  │    Correlation Tab           │  │
│                       │  │    Outliers Tab              │  │
│                       │  └──────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER                       │
│                         (app.R)                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   UI Layer   │  │ Server Layer │  │   Reactive   │     │
│  │              │→ │              │→ │   Context    │     │
│  │ - Layout     │  │ - Logic      │  │ - Data Flow  │     │
│  │ - Components │  │ - Events     │  │ - Updates    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      MODULE LAYER                            │
│                    (Modular Components)                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Upload  │  │ Overview │  │ Missing  │  │ Summary  │   │
│  │  Module  │  │  Module  │  │  Module  │  │  Module  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Viz    │  │  Corr    │  │ Outliers │  │  Report  │   │
│  │  Module  │  │  Module  │  │  Module  │  │  Module  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                     UTILITY LAYER                            │
│                      (global.R)                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  • Helper Functions      • Theme Configuration              │
│  • Type Detection        • Color Schemes                    │
│  • Statistical Calcs     • Custom Styles                    │
│  • Data Validation       • Error Messages                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐          ┌──────────────┐                │
│  │  User Data   │          │   Reports    │                │
│  │  (CSV Files) │    →     │  (HTML/PDF)  │                │
│  └──────────────┘          └──────────────┘                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Diagram

```
┌──────────────┐
│     USER     │
└──────┬───────┘
       │
       │ 1. Upload CSV
       ↓
┌──────────────────┐
│  Upload Module   │
│  • Validate File │
│  • Read CSV      │
│  • Store Data    │
└──────┬───────────┘
       │
       │ 2. Reactive Data
       ↓
┌───────────────────────────────────────────────────┐
│              Reactive Expression                  │
│              (uploaded_data)                      │
│  • Automatically updates all dependent modules    │
└───────┬───────────────────────────────────────────┘
        │
        ├─→ Overview Module     → Display stats
        ├─→ Missing Module      → Analyze missing
        ├─→ Summary Module      → Calculate stats
        ├─→ Viz Module          → Generate plots
        ├─→ Correlation Module  → Compute correlations
        ├─→ Outliers Module     → Detect outliers
        └─→ Report Module       → Generate report
                │
                │ 3. User Interaction
                ↓
        ┌───────────────┐
        │  User Actions │
        │  • Select Var │
        │  • Choose Plot│
        │  • Adjust Par │
        └───────┬───────┘
                │
                │ 4. Update Display
                ↓
        ┌───────────────┐
        │   Plotly/DT   │
        │  Interactive  │
        │  Components   │
        └───────┬───────┘
                │
                │ 5. Download/Export
                ↓
        ┌───────────────┐
        │    Reports    │
        │  HTML or PDF  │
        └───────────────┘
```

---

## 🎯 Module Communication Pattern

```
┌─────────────────────────────────────────────────┐
│              PARENT (app.R)                     │
│                                                  │
│  uploaded_data <- uploadModuleServer("upload")  │
│                                                  │
│  overviewModuleServer("overview", uploaded_data)│
│  missingModuleServer("missing", uploaded_data)  │
│  ... (other modules)                            │
│                                                  │
└─────────────────────────────────────────────────┘
                     ↕ ↕ ↕
┌─────────────────────────────────────────────────┐
│           CHILD MODULES                         │
│                                                  │
│  Each module receives:                          │
│  • Reactive data from parent                    │
│  • Namespace for isolation                      │
│                                                  │
│  Each module provides:                          │
│  • UI components                                │
│  • Server logic                                 │
│  • Reactive outputs                             │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## 📊 Reactive Dependency Graph

```
                    ┌─────────────────┐
                    │  File Input     │
                    │  (User Upload)  │
                    └────────┬────────┘
                             │
                             ↓
                    ┌─────────────────┐
                    │ uploaded_data() │
                    │   (Reactive)    │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
           ↓                 ↓                 ↓
    ┌──────────┐      ┌──────────┐     ┌──────────┐
    │ Overview │      │ Missing  │     │ Summary  │
    │ Outputs  │      │ Analysis │     │  Stats   │
    └──────────┘      └──────────┘     └──────────┘
           │                 │                 │
           └─────────────────┼─────────────────┘
                             │
                             ↓
                    ┌─────────────────┐
                    │  User selects   │
                    │   variables     │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
           ↓                 ↓                 ↓
    ┌──────────┐      ┌──────────┐     ┌──────────┐
    │Visualiza │      │Correlati │     │ Outliers │
    │  tions   │      │   on     │     │Detection │
    └──────────┘      └──────────┘     └──────────┘
```

---

## 🔀 Module Interaction Workflow

### Example: Creating a Visualization

```
1. USER ACTION
   ↓
   Click "Visualizations" tab

2. UI RENDERS
   ↓
   visualizationModuleUI displays
   • Plot type selector
   • Variable selectors
   • Parameter controls

3. USER CONFIGURES
   ↓
   • Select: "Histogram"
   • Choose: "Age" variable
   • Set bins: 30
   • Click "Generate Plot"

4. SERVER PROCESSES
   ↓
   observeEvent(input$generate_plot)
   • Validate inputs
   • Retrieve data from uploaded_data()
   • Filter/prepare data
   • Create ggplot object
   • Convert to plotly

5. RENDER OUTPUT
   ↓
   renderPlotly()
   • Display interactive plot
   • Show hover information
   • Enable zoom/pan

6. USER INTERACTS
   ↓
   • Hover over bars
   • Zoom in/out
   • Pan around
   • Download plot
```

---

## 🏗️ File Structure & Responsibilities

```
InstaEDA/
│
├── app.R
│   ├── UI Definition
│   │   ├── dashboardHeader
│   │   ├── dashboardSidebar
│   │   └── dashboardBody (tabs)
│   │
│   └── Server Logic
│       ├── Module servers
│       ├── Reactive contexts
│       └── Event handlers
│
├── global.R
│   ├── Package loading
│   ├── Global variables
│   ├── Helper functions
│   └── Theme configuration
│
├── modules/
│   │
│   ├── upload_module.R
│   │   ├── File input UI
│   │   ├── Validation logic
│   │   └── Data storage
│   │
│   ├── overview_module.R
│   │   ├── Info boxes
│   │   ├── Data table
│   │   └── Type summary
│   │
│   ├── missing_module.R
│   │   ├── Missing stats
│   │   ├── Bar charts
│   │   └── Heatmaps
│   │
│   ├── summary_stats_module.R
│   │   ├── Statistical calculations
│   │   ├── Summary tables
│   │   └── Distribution plots
│   │
│   ├── visualization_module.R
│   │   ├── Plot type selection
│   │   ├── Variable selection
│   │   └── Dynamic plotting
│   │
│   ├── correlation_module.R
│   │   ├── Correlation matrix
│   │   ├── Heatmap
│   │   └── Strong correlations
│   │
│   ├── outliers_module.R
│   │   ├── Detection methods
│   │   ├── Threshold settings
│   │   └── Outlier visualization
│   │
│   └── report_module.R
│       ├── Section selection
│       ├── Format choice
│       └── Report generation
│
└── www/
    └── custom.css
        ├── Color schemes
        ├── Component styling
        └── Responsive design
```

---

## 🔧 Technical Implementation Details

### Reactive Programming Pattern

```r
# In app.R
uploaded_data <- uploadModuleServer("upload")

# Reactive expression (cached, efficient)
processed_data <- reactive({
  req(uploaded_data())  # Ensure data exists
  df <- uploaded_data()
  # Process data...
  return(df)
})

# Reactive output
output$plot <- renderPlotly({
  req(processed_data())  # Only execute if data available
  # Create plot using processed_data()
})
```

### Module Pattern

```r
# Module UI
moduleUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("var"), "Variable:", choices = NULL),
    plotlyOutput(ns("plot"))
  )
}

# Module Server
moduleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    # Access data via data() reactive
    # Create outputs using session namespace
  })
}
```

### Error Handling Pattern

```r
tryCatch({
  # Risky operation
  df <- read.csv(file)
}, error = function(e) {
  # User-friendly error
  showNotification(
    paste("Error:", e$message),
    type = "error"
  )
  return(NULL)
})
```

---

## 📈 Performance Optimization Strategies

### 1. Reactive Expression Caching
```
uploaded_data() → Cached, only updates on new upload
summary_stats() → Cached, only recalculates when data changes
correlation()   → Cached, only updates when method changes
```

### 2. Lazy Evaluation
```
Plots only render when tab is visible
Tables only load when requested
Reports only generate on download
```

### 3. Efficient Data Structures
```
Use data.table for large datasets (future)
Filter before plotting (reduce points)
Sample for preview (if > 10,000 rows)
```

---

## 🎨 Design Principles

### 1. Modularity
- Each feature is a separate module
- Modules can be added/removed easily
- Clear interfaces between modules

### 2. Separation of Concerns
- UI logic separate from business logic
- Data processing separate from visualization
- Global utilities separate from specific modules

### 3. DRY (Don't Repeat Yourself)
- Helper functions in global.R
- Reusable module pattern
- Consistent naming conventions

### 4. User-Centered Design
- Intuitive navigation
- Clear feedback
- Helpful error messages
- Professional aesthetics

---

## 🔐 Data Security & Privacy

### Current Implementation
- Data stays local (not sent to external servers)
- No data persistence between sessions
- File uploads validated for type and size
- Error messages don't expose system details

### Production Recommendations
- Add user authentication
- Implement data encryption
- Add audit logging
- Use HTTPS in deployment

---

## 📝 Code Quality Metrics

```
├── Total Lines of Code: ~3,800
│   ├── app.R: 340
│   ├── global.R: 200
│   ├── Modules: 2,000+
│   ├── CSS: 200
│   └── Documentation: 1,000+
│
├── Modularity Score: 8/10
│   ├── Clear separation ✓
│   ├── Reusable components ✓
│   └── Minimal coupling ✓
│
├── Documentation: 9/10
│   ├── Inline comments ✓
│   ├── README ✓
│   ├── User guides ✓
│   └── API docs (could add)
│
└── Test Coverage: 6/10
    ├── Manual testing ✓
    ├── Sample data ✓
    └── Unit tests (future)
```

---

## 🚀 Deployment Options

### 1. Local Development
```r
shiny::runApp()
```

### 2. Shiny Server (Free)
```bash
# Install Shiny Server
# Copy app to /srv/shiny-server/
# Access via http://server-ip:3838/
```

### 3. ShinyApps.io
```r
library(rsconnect)
deployApp()
```

### 4. Docker Container
```dockerfile
FROM rocker/shiny
RUN R -e "install.packages(...)"
COPY . /srv/shiny-server/
```

---

This documentation provides a comprehensive technical overview of InstaEDA's architecture, design patterns, and implementation details.
