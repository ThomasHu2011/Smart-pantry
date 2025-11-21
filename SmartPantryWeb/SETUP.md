# SmartPantry Setup Guide

## Issues Fixed ✅

1. **Virtual Environment**: Recreated the virtual environment and installed all dependencies
2. **OpenAI API Key**: Made the API key optional - app will run without it (but AI features won't work)
3. **Error Handling**: Added proper error handling for missing API key

## How to Run the App

### 1. Activate Virtual Environment
```bash
cd /Users/hushide/Documents/code/SmartPantryWeb
source venv/bin/activate
```

### 2. Set Up OpenAI API Key (Optional but Recommended)

Create a `.env` file in the `SmartPantryWeb` directory:
```bash
echo "OPENAI_API_KEY=your_api_key_here" > .env
```

Replace `your_api_key_here` with your actual OpenAI API key.

**Note**: Without the API key, the app will still run, but these features won't work:
- Photo recognition
- Recipe suggestions
- AI-powered recipe generation

### 3. Run the App
```bash
python3 app.py
```

The app will start on `http://0.0.0.0:5050` (accessible from any device on your network)

## Common Issues

### Issue: "ModuleNotFoundError: No module named 'flask'"
**Solution**: Make sure you've activated the virtual environment:
```bash
source venv/bin/activate
```

### Issue: "OPENAI_API_KEY not found"
**Solution**: Create a `.env` file with your API key (see step 2 above)

### Issue: App won't start
**Solution**: Check if port 5050 is already in use:
```bash
lsof -i :5050
```

If something is using the port, either stop that process or change the port in `app.py` (line 1234).

## Dependencies

All dependencies are installed in the virtual environment:
- Flask
- OpenAI
- python-dotenv
- flask-cors
- Pillow

## Testing

1. Open your browser and go to: `http://localhost:5050`
2. You should see the login page
3. Create an account or log in
4. Try adding items to your pantry

## Need Help?

If you encounter any issues:
1. Make sure the virtual environment is activated
2. Check that all dependencies are installed: `pip list`
3. Verify your `.env` file exists and has the correct API key format
4. Check the terminal for error messages

