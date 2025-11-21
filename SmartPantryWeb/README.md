# SmartPantry Basic

A Flask web application for managing pantry items and getting AI-powered recipe suggestions.

## Features

- **Page 1**: Add pantry items manually
- **Page 2**: Get AI-generated recipe suggestions based on available ingredients
- **AI Integration**: Uses OpenAI GPT-4o-mini with structured output for creative recipes
- **Smart Filtering**: Only suggests recipes you can actually make with your ingredients
- **Fallback System**: Static recipes when AI is unavailable
- SQLite database for storing pantry items
- Bootstrap styling for a clean, responsive interface

## Setup

1. Set up your OpenAI API key:
```bash
export OPENAI_API_KEY="your-openai-api-key-here"
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the application:
```bash
python app.py
```

4. Open your browser and go to `http://localhost:5000`

## Usage

1. **Add Items**: Use the "Add Items" page to manually add ingredients to your pantry
2. **Get AI Recipes**: Click "Suggest Recipe" to get AI-generated recipes using your available ingredients
3. **Manage Items**: View all your pantry items and delete them if needed

## AI Recipe Generation

The app uses OpenAI's GPT-4o-mini model to generate creative, personalized recipes based on your pantry items. Each AI-generated recipe includes:

- Creative recipe name and description
- Detailed ingredients with amounts and units
- Step-by-step cooking instructions
- Prep time, cook time, difficulty level, and serving size
- Uses structured output (Pydantic models) for consistent formatting

## Fallback Recipes

When AI is unavailable, the app falls back to these static recipes:
- Pasta with Tomato Sauce (pasta, tomato, garlic, olive oil)
- Grilled Cheese Sandwich (bread, cheese, butter)

## Database

The app uses SQLite with a simple `items` table:
- `id`: Primary key
- `name`: Item name (unique)

## Technology Stack

- **Backend**: Flask
- **Database**: SQLite
- **AI**: OpenAI GPT-4o-mini with structured output
- **Frontend**: Bootstrap 5
- **Icons**: Bootstrap Icons
- **Data Validation**: Pydantic models


## run  the project

cd /path/to/your/flask/project
source venv/bin/activate  
python app.py


buggy? 
kill

lsof -i :5050

kill -9 12345




