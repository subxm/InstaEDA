# 🚀 InstaEDA Deployment Quick Reference

## ⚡ Super Quick Deployment (3 Steps)

### 1️⃣ Install rsconnect
```r
install.packages("rsconnect")
```

### 2️⃣ Configure Account
```r
library(rsconnect)
rsconnect::setAccountInfo(
  name = "your-account-name",
  token = "YOUR-TOKEN",
  secret = "YOUR-SECRET"
)
```

Get credentials: https://connect.posit.cloud/ → Profile → Tokens

### 3️⃣ Deploy
```r
# Option A: Use the script
source("deploy.R")

# Option B: Manual deploy
rsconnect::deployApp(
  appDir = ".",
  appName = "InstaEDA"
)
```

---

## 🎯 Essential Commands

### Check Configuration
```r
rsconnect::accounts()  # View configured accounts
```

### Test App Locally First
```r
shiny::runApp()  # Must work locally before deploying
```

### Deploy with Options
```r
rsconnect::deployApp(
  appDir = ".",
  appName = "InstaEDA",
  appTitle = "InstaEDA Dashboard",
  launch.browser = FALSE,
  forceUpdate = TRUE
)
```

### Redeploy (Update)
```r
rsconnect::deployApp(forceUpdate = TRUE)
```

### View Deployments
```r
rsconnect::deployments(".")
```

---

## 📋 Pre-Deployment Checklist

- [ ] App runs locally (`shiny::runApp()`)
- [ ] All packages installed
- [ ] `manifest.json` present
- [ ] No absolute file paths in code
- [ ] rsconnect package installed
- [ ] Posit Connect account configured

---

## 🔧 Troubleshooting

### App Won't Deploy
```r
# Check package versions
installed.packages()[c("shiny", "shinydashboard"), "Version"]

# Verify files
list.files(".", recursive = TRUE)

# Test local deployment first
shiny::runApp()
```

### Deployment Fails Midway
```r
# Use verbose logging
rsconnect::deployApp(logLevel = "verbose")

# Check file size
options(rsconnect.max.bundle.size = 10485760)
```

### Can't Find Account
```r
# Reconfigure
rsconnect::setAccountInfo(name="...", token="...", secret="...")

# Verify
rsconnect::accounts()
```

---

## 🌐 After Deployment

### Your App URL Format:
```
https://[account-name].connect.posit.cloud/[app-name]/
```

### Configure in Dashboard:
1. Go to connect.posit.cloud
2. Find your app
3. Set **Access** (who can view)
4. Set **Resources** (memory, CPU)
5. View **Logs** (for errors)

---

## 💡 Pro Tips

✅ **Always test locally first**
✅ **Deploy during low-traffic hours**
✅ **Use meaningful app names**
✅ **Set proper access controls**
✅ **Monitor logs after deployment**

---

## 📞 Need Help?

- **Full Guide**: See `DEPLOYMENT_GUIDE.md`
- **Posit Docs**: https://docs.posit.co/connect/
- **Community**: https://community.rstudio.com/

---

## 🎉 Quick Start Script

Just run this:
```r
source("deploy.R")
```

It will:
1. Check prerequisites
2. Guide you through configuration
3. Deploy your app automatically

---

**That's it! You're ready to deploy InstaEDA!** 🚀

*One command deployment: `source("deploy.R")`*
