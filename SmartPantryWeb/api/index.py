# Vercel serverless function entry point
# This file imports the Flask app from the parent directory

import sys
import os

# Get the SmartPantryWeb directory (parent of api/)
smartpantry_web_dir = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))

# Add SmartPantryWeb directory to Python path
if smartpantry_web_dir not in sys.path:
    sys.path.insert(0, smartpantry_web_dir)

# Import the Flask app
try:
    from app import app
except ImportError as e:
    # Enhanced error handling for debugging
    import traceback
    print(f"ERROR: Failed to import app: {e}")
    print(f"Python path: {sys.path}")
    print(f"SmartPantryWeb dir: {smartpantry_web_dir}")
    print(f"Current working directory: {os.getcwd()}")
    traceback.print_exc()
    raise

# Verify app exists and has handler
if not app:
    raise ValueError("Flask app not found or is None")

# Export handler for Vercel - this is what Vercel looks for
handler = app

