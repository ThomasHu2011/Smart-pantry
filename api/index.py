# Vercel serverless function entry point
# This file imports the Flask app from SmartPantryWeb directory

import sys
import os

# Get the project root directory (two levels up from api/)
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

# Add SmartPantryWeb to Python path so we can import app
smartpantry_web_path = os.path.join(project_root, 'SmartPantryWeb')
if smartpantry_web_path not in sys.path:
    sys.path.insert(0, smartpantry_web_path)

# Import the app from SmartPantryWeb/app.py
try:
    from app import app
except ImportError as e:
    # Fallback: try importing directly from the module path
    import importlib.util
    app_path = os.path.join(smartpantry_web_path, 'app.py')
    spec = importlib.util.spec_from_file_location("app", app_path)
    app_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(app_module)
    app = app_module.app

# Export handler for Vercel - this is what Vercel looks for
handler = app

