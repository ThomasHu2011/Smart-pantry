# Troubleshooting Guide - Still Not Working After Cache Clear

## Current Status Check

### ✅ Code is Correct Locally
- Line 7: `from openai import OpenAI` (not flask_cors) ✅
- Handler export exists: `handler = app` ✅
- No flask_cors imports ✅
- Requirements.txt correct ✅

### ❓ What Error Are You Seeing Now?

Please check Vercel logs and share:

1. **What error message appears?**
   - Still showing `ModuleNotFoundError: flask_cors`?
   - Or a different error now?
   - Runtime error (500)?
   - Import error?

2. **When does it occur?**
   - During build?
   - During function invocation?
   - On first request?
   - On all requests?

## Step-by-Step Debugging

### Step 1: Verify Deployment

1. **Check Build Logs**
   - Vercel Dashboard → Your Project → Deployments
   - Click latest deployment
   - Go to "Build Logs" tab
   - Look for:
     - ✅ `Installing dependencies from requirements.txt`
     - ✅ `Successfully installed Flask-3.1.2 ...`
     - ❌ Any errors during build

2. **Check Runtime Logs**
   - Same deployment → "Logs" tab (runtime logs)
   - Look for error messages
   - Check timestamps - when did error occur?

### Step 2: Test Minimal Endpoint

Try accessing: `/api/health`

This is the simplest endpoint with minimal dependencies.

**Expected Response:**
```json
{
  "success": true,
  "status": "healthy",
  "pantry_items": 0,
  "ai_available": false
}
```

### Step 3: Check File Structure

Verify these files are in the root:
```
SmartPantryWeb/
├── app.py              ✅ Must exist
├── requirements.txt    ✅ Must exist
├── vercel.json         ✅ Must exist
├── runtime.txt         ✅ Must exist
└── templates/          ✅ Must exist
```

### Step 4: Verify Handler Export

In `app.py`, check line ~1395:
```python
handler = app  # This line must exist
```

### Step 5: Check Vercel Configuration

In `vercel.json`:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "app.py",  // Must point to your app.py
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "app.py"  // Must match builds src
    }
  ]
}
```

## Common Issues After Cache Clear

### Issue 1: Still Using Old Deployment

**Symptom**: Still seeing old errors

**Solution**:
1. Delete the old deployment completely
2. Create a NEW deployment from scratch
3. Or trigger a new deployment via Git push

### Issue 2: Git Not Synced

**Symptom**: Local changes not reflected in Vercel

**Solution**:
```bash
cd /Users/hushide/Documents/code/SmartPantryWeb
git status
git add app.py requirements.txt vercel.json
git commit -m "Fix: Remove flask-cors, add handler export"
git push
```

### Issue 3: Wrong Root Directory

**Symptom**: Vercel looking in wrong folder

**Check**:
- Vercel Dashboard → Settings → General
- "Root Directory" should be empty or `SmartPantryWeb`
- If wrong, set it correctly and redeploy

### Issue 4: Runtime Error (Not Import Error)

**Symptom**: Build succeeds but runtime crashes

**Check**:
- Runtime logs in Vercel
- Look for `ERROR [...]` messages
- Check the global error handler output

### Issue 5: Python Version Mismatch

**Check**:
- `runtime.txt` says: `python-3.11`
- But Vercel might default to different version

**Solution**: Ensure runtime.txt is committed and pushed

## Diagnostic Test

Create a minimal test file to verify everything works:

### Test 1: Minimal Flask App

Create `test_app.py`:
```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({'status': 'ok'})

handler = app
```

Deploy this separately to test if Vercel Python works at all.

### Test 2: Check Current Error

Run this locally (if you have venv activated):
```bash
cd /Users/hushide/Documents/code/SmartPantryWeb
python3 -c "import sys; sys.path.insert(0, '.'); exec(open('app.py').read()); print('✅ App loaded successfully'); print('✅ Handler exists:', hasattr(__import__('sys').modules['__main__'], 'handler'))"
```

## What Information We Need

Please provide:

1. **Exact error message from Vercel logs**
   - Full traceback if available
   - Error type and line number

2. **Build logs output**
   - Did dependencies install correctly?
   - Any warnings or errors?

3. **Runtime logs**
   - What happens when you access a route?
   - Any ERROR messages?

4. **What URL are you accessing?**
   - Root `/`?
   - `/api/health`?
   - Another route?

5. **Deployment method**
   - Git push (automatic)?
   - Manual upload?
   - Vercel CLI?

## Quick Fixes to Try

### Fix 1: Force Complete Rebuild

1. Delete latest deployment
2. Settings → General → Clear Build Cache
3. Create new deployment
4. Ensure "Use Build Cache" is OFF

### Fix 2: Verify All Files Committed

```bash
git status
git add -A
git commit -m "Complete fix"
git push
```

### Fix 3: Check Environment Variables

Vercel Dashboard → Settings → Environment Variables

Ensure:
- `OPENAI_API_KEY` (if using AI features)
- `FLASK_SECRET_KEY` (optional)
- No conflicting variables

### Fix 4: Simplify vercel.json

Try this minimal vercel.json:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "app.py",
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "app.py"
    }
  ]
}
```

## Next Steps

Once you share:
1. The exact error message from Vercel logs
2. What happens when you access `/api/health`
3. Whether build succeeded or failed

We can identify the specific issue and fix it!

