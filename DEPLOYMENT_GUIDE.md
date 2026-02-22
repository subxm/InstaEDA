# 🚀 InstaEDA Deployment Guide for Posit Connect Cloud

This guide will walk you through deploying InstaEDA to Posit Connect Cloud (formerly RStudio Connect).

---

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Posit Connect Cloud Account**
   - Sign up at: https://connect.posit.cloud/
   - Free tier available for testing

2. **R and RStudio Installed**
   - R version 4.0 or higher
   - Latest version of RStudio Desktop

3. **rsconnect Package**
   ```r
   install.packages("rsconnect")
   ```

4. **All Project Files**
   - Complete InstaEDA folder
   - Including manifest.json

---

## 🔧 Method 1: Deploy Using RStudio (Recommended)

### Step 1: Open Project in RStudio

1. Launch RStudio
2. File → Open Project
3. Navigate to InstaEDA folder
4. Open `app.R`

### Step 2: Connect Your Account

1. In RStudio, go to **Tools → Global Options**
2. Click **Publishing** in left sidebar
3. Click **Connect...** button
4. Select **Posit Cloud**
5. Enter your credentials

**OR use R console:**
```r
library(rsconnect)

# Set up your account (get these from Posit Connect dashboard)
rsconnect::setAccountInfo(
  name = "your-account-name",
  token = "your-token-here",
  secret = "your-secret-here"
)
```

### Step 3: Deploy the App

**Option A: Using RStudio Button**

1. Open `app.R` in RStudio
2. Look for blue **"Publish"** button (top-right of editor)
3. Click it
4. Select **Posit Connect Cloud**
5. Choose all files to deploy
6. Click **Publish**

**Option B: Using Console**

```r
library(rsconnect)

# Set working directory to project folder
setwd("/path/to/InstaEDA")

# Deploy
rsconnect::deployApp(
  appDir = ".",
  appName = "InstaEDA",
  account = "your-account-name",
  server = "connect.posit.cloud"
)
```

### Step 4: Monitor Deployment

- Watch the deployment log in RStudio Console
- Wait for "Application successfully deployed" message
- Note the deployment URL

---

## 🔧 Method 2: Deploy Using R Console Only

### Step 1: Install rsconnect

```r
install.packages("rsconnect")
library(rsconnect)
```

### Step 2: Configure Your Account

Get your credentials from Posit Connect:
1. Log in to connect.posit.cloud
2. Click your name (top-right) → Tokens
3. Create new token
4. Copy token and secret

```r
# Configure account
rsconnect::setAccountInfo(
  name = "your-account-name",
  token = "PASTE-YOUR-TOKEN-HERE",
  secret = "PASTE-YOUR-SECRET-HERE"
)

# Verify connection
rsconnect::accounts()
```

### Step 3: Deploy

```r
# Navigate to project directory
setwd("/path/to/InstaEDA")

# Deploy the application
rsconnect::deployApp(
  appDir = ".",
  appName = "InstaEDA-Dashboard",
  appTitle = "InstaEDA: Automated EDA Tool",
  account = "your-account-name"
)
```

---

## 🔧 Method 3: Using Git-Based Deployment

### Step 1: Initialize Git Repository

```bash
cd /path/to/InstaEDA
git init
git add .
git commit -m "Initial commit"
```

### Step 2: Push to GitHub

```bash
# Create repo on GitHub first, then:
git remote add origin https://github.com/yourusername/InstaEDA.git
git branch -M main
git push -u origin main
```

### Step 3: Deploy from GitHub

1. Go to Posit Connect dashboard
2. Click **Publish** → **Import from Git**
3. Connect your GitHub account
4. Select InstaEDA repository
5. Set branch to `main`
6. Set entry point to `app.R`
7. Click **Deploy**

---

## 📝 Deployment Configuration

### Required Files Checklist

Ensure these files are in your project:

- [x] `app.R` - Main application
- [x] `global.R` - Global configuration
- [x] `manifest.json` - Deployment manifest
- [x] `modules/` folder - All 8 modules
- [x] `www/` folder - CSS files
- [x] `sample_data.csv` - Sample data

### manifest.json

The `manifest.json` file is already included in your project. It tells Posit Connect:
- Which R packages to install
- Which files to include
- App entry point (app.R)

---

## ⚙️ Advanced Deployment Settings

### Custom Resource Allocation

```r
rsconnect::deployApp(
  appDir = ".",
  appName = "InstaEDA",
  account = "your-account-name",
  launch.browser = FALSE,
  forceUpdate = TRUE,
  logLevel = "verbose"
)
```

### Environment Variables

If you need to set environment variables:

```r
# In a .Renviron file in project root
MAX_UPLOAD_SIZE=52428800
SHINY_PORT=3838
```

### Memory and CPU Settings

Configure in Posit Connect dashboard after deployment:
1. Go to your app
2. Click **Settings**
3. Adjust:
   - Memory (recommend 1GB minimum)
   - CPU (1 core minimum)
   - Max processes (2-4)

---

## 🔍 Troubleshooting Deployment

### Issue: Package Installation Fails

**Solution:**
```r
# Manually verify packages before deploying
source("install_packages.R")

# Check all packages installed
required <- c("shiny", "shinydashboard", "dplyr", "tidyr", 
              "ggplot2", "plotly", "DT", "corrplot", "scales", "viridis")
installed <- installed.packages()[,"Package"]
missing <- required[!required %in% installed]
if(length(missing) > 0) {
  print(paste("Missing:", missing))
}
```

### Issue: Deployment Timeout

**Solution:**
```r
# Use verbose logging
options(rsconnect.max.bundle.size = 10485760)  # 10MB
rsconnect::deployApp(logLevel = "verbose")
```

### Issue: File Not Found During Deployment

**Solution:**
```r
# Check all files are present
list.files(".", recursive = TRUE)

# Ensure manifest.json lists all files correctly
```

### Issue: App Crashes After Deployment

**Solution:**
1. Check logs in Posit Connect dashboard
2. Look for missing package errors
3. Verify file paths are relative, not absolute
4. Check that all modules are sourced correctly

---

## 📊 Post-Deployment Configuration

### 1. Set Access Controls

In Posit Connect dashboard:
1. Go to your app
2. Click **Access** tab
3. Choose:
   - **Anyone** - Public access
   - **Anyone with the link** - Semi-private
   - **Specific people** - Private

### 2. Configure Upload Limits

1. Go to **Settings** → **Runtime**
2. Set **Max Upload Size**: 50 MB
3. Set **Idle Timeout**: 5 minutes
4. Set **Connection Timeout**: 60 seconds

### 3. Enable Scheduled Reports (Optional)

If you add scheduling:
1. Go to **Schedule** tab
2. Add schedule (daily, weekly, etc.)
3. Configure email recipients

### 4. Set Up Vanity URL

1. Go to **Info** tab
2. Click **Change URL**
3. Set custom URL: `your-org.connect.posit.cloud/instaeda`

---

## 🎯 Quick Deployment Checklist

Before deploying:

- [ ] All packages installed locally
- [ ] App runs successfully locally
- [ ] manifest.json is present
- [ ] No absolute file paths in code
- [ ] Sample data is included
- [ ] rsconnect package installed
- [ ] Posit Connect account configured
- [ ] All modules in `modules/` folder
- [ ] CSS file in `www/` folder

During deployment:

- [ ] Choose correct account
- [ ] Set meaningful app name
- [ ] Include all required files
- [ ] Monitor deployment logs
- [ ] Note deployment URL

After deployment:

- [ ] Test app in browser
- [ ] Upload test CSV
- [ ] Test all features
- [ ] Set access controls
- [ ] Configure resource limits
- [ ] Share URL with users

---

## 🌐 Accessing Your Deployed App

After successful deployment:

1. **Your App URL**: 
   ```
   https://your-account.connect.posit.cloud/InstaEDA/
   ```

2. **Dashboard Access**:
   ```
   https://connect.posit.cloud/
   ```

3. **Share with Users**:
   - Copy the app URL
   - Set appropriate access controls
   - Share via email or Slack

---

## 📈 Monitoring Your App

### View Usage Statistics

In Posit Connect dashboard:
1. Go to your app
2. Click **Metrics** tab
3. View:
   - Number of visitors
   - Active sessions
   - Resource usage
   - Error logs

### Check Logs

```r
# Or via dashboard:
# App → Logs → View real-time logs
```

### Performance Monitoring

Monitor these metrics:
- Response time
- Memory usage
- CPU usage
- Active connections

---

## 🔄 Updating Your Deployed App

### Method 1: Redeploy from RStudio

1. Make changes to your code
2. Test locally
3. Click **Publish** button again
4. Choose **Update Existing**
5. Wait for deployment

### Method 2: Using Console

```r
rsconnect::deployApp(
  appDir = ".",
  appName = "InstaEDA",
  forceUpdate = TRUE
)
```

### Method 3: Git-Based Update

```bash
git add .
git commit -m "Update app"
git push origin main

# Posit Connect will auto-deploy if configured
```

---

## 💰 Pricing Considerations

### Free Tier Includes:
- 25 active hours per month
- 1GB RAM
- Basic support
- Public apps only

### Paid Plans:
- Starter: $9/month
- Standard: $49/month
- Professional: $99/month

**Recommendation**: Start with free tier for testing

---

## 🔐 Security Best Practices

### 1. Environment Variables

Never hardcode sensitive data:
```r
# Use environment variables instead
api_key <- Sys.getenv("API_KEY")
```

### 2. Input Validation

Already implemented in InstaEDA:
- File type validation
- File size limits
- Error handling

### 3. Access Control

Set appropriate permissions:
- Development: Private
- Testing: Link only
- Production: Based on use case

---

## 📚 Additional Resources

### Official Documentation
- [Posit Connect User Guide](https://docs.posit.co/connect/user/)
- [rsconnect Package Docs](https://rstudio.github.io/rsconnect/)
- [Shiny Deployment Guide](https://shiny.rstudio.com/deploy/)

### Video Tutorials
- [Deploying Shiny Apps](https://www.youtube.com/rstudio)
- [Posit Connect Overview](https://posit.co/products/connect/)

### Community Support
- [Posit Community](https://community.rstudio.com/)
- [Stack Overflow - shiny tag](https://stackoverflow.com/questions/tagged/shiny)

---

## ✅ Deployment Complete!

Once deployed, your InstaEDA dashboard will be:
- ✅ Accessible via web browser
- ✅ Available 24/7
- ✅ Shareable with colleagues
- ✅ Professionally hosted
- ✅ Automatically maintained

**Your App URL Format:**
```
https://[your-account].connect.posit.cloud/InstaEDA/
```

---

## 🆘 Getting Help

If you encounter issues:

1. **Check Deployment Logs**
   - Look for red error messages
   - Note which package failed

2. **Verify Locally First**
   - Always test local deployment
   - Fix issues before deploying

3. **Posit Support**
   - Email: support@posit.co
   - Community: community.rstudio.com

4. **Common Issues FAQ**
   - See troubleshooting section above

---

**Congratulations! Your InstaEDA dashboard is now ready for cloud deployment!** 🎉🚀

---

*Last Updated: February 22, 2026*
*Version: 1.0.1*
