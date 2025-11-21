# Vercel serverless function entry point
# This file imports the Flask app from SmartPantryWeb directory

import sys
import os

# Add SmartPantryWeb to Python path so we can import app
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'SmartPantryWeb'))

# Import the app from SmartPantryWeb/app.py
from app import app

# Export handler for Vercel - this is what Vercel looks for
handler = app

