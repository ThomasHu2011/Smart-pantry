# Deployment Fix Instructions

## Issue
Vercel is not installing `flask-cors` even though it's in `requirements.txt`.

## Solution Steps

### 1. Verify Files Are Committed
Make sure these files are committed and pushed:
```bash
git add requirements.txt vercel.json runtime.txt
git commit -m "Fix: Add flask-cors and deployment config"
git push
```

### 2. Clear Vercel Build Cache
1. Go to your Vercel dashboard
2. Select your project
3. Go to Settings → General
4. Scroll down to "Clear Build Cache"
5. Click "Clear Build Cache"
6. Redeploy

### 3. Force Redeploy
In Vercel dashboard:
- Go to Deployments
- Click the three dots on the latest deployment
- Select "Redeploy"
- Check "Use existing Build Cache" = **OFF** (unchecked)

### 4. Verify Build Logs
After redeploying, check the build logs to see:
- `Installing dependencies from requirements.txt`
- `Successfully installed flask-cors-6.0.1`

### 5. Alternative: Manual Verification
If still not working, try:
1. Delete the deployment
2. Create a new deployment from scratch
3. Or try deploying without version pins in requirements.txt:

```
Flask
openai
flask-cors
python-dotenv
Pillow
```

## Current Files Status
✅ `requirements.txt` - Contains flask-cors==6.0.1
✅ `vercel.json` - Configured for Python
✅ `runtime.txt` - Set to Python 3.11

## If Still Not Working
The issue might be:
1. **Caching**: Vercel is using cached build
2. **File location**: Ensure requirements.txt is in root directory
3. **Git ignore**: Make sure requirements.txt is not in .gitignore
4. **Build logs**: Check Vercel build logs for actual error messages

