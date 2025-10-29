# SmartPantry API Documentation

Your SmartPantry app now works as a backend API for mobile/frontend applications!

## Base URL
```
http://127.0.0.1:5050
```

## API Endpoints

### 1. Health Check
**GET** `/api/health`

Check if the API is running and get basic status.

**Response:**
```json
{
  "success": true,
  "status": "healthy",
  "pantry_items": 5,
  "ai_available": true
}
```

### 2. Get Pantry Items
**GET** `/api/pantry`

Get all items in your pantry.

**Response:**
```json
{
  "success": true,
  "items": ["eggs", "bread", "cheese", "tomato", "milk"],
  "count": 5
}
```

### 3. Add Item to Pantry
**POST** `/api/pantry`

Add a new item to your pantry.

**Request Body:**
```json
{
  "item": "onions"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Added \"onions\" to pantry",
  "item": "onions",
  "total_items": 6
}
```

**Error Response (409 if duplicate):**
```json
{
  "success": false,
  "error": "\"eggs\" is already in pantry"
}
```

### 4. Delete Item from Pantry
**DELETE** `/api/pantry/{item_name}`

Remove an item from your pantry.

**Example:** `DELETE /api/pantry/eggs`

**Response:**
```json
{
  "success": true,
  "message": "Removed \"eggs\" from pantry",
  "total_items": 5
}
```

**Error Response (404 if not found):**
```json
{
  "success": false,
  "error": "\"eggs\" not found in pantry"
}
```

### 5. Get AI Recipe Suggestion
**POST** `/api/recipes/suggest`

Get an AI-generated recipe based on your pantry items.

**Response:**
```json
{
  "success": true,
  "recipe": {
    "name": "Cheesy Tomato Scramble",
    "description": "A delicious breakfast scramble with eggs, cheese, and tomatoes",
    "ingredients": [
      {"name": "eggs", "amount": "4", "unit": "large"},
      {"name": "cheese", "amount": "1/2", "unit": "cup"},
      {"name": "tomato", "amount": "1", "unit": "medium"},
      {"name": "salt", "amount": "1/4", "unit": "tsp"},
      {"name": "pepper", "amount": "1/4", "unit": "tsp"},
      {"name": "butter", "amount": "1", "unit": "tbsp"}
    ],
    "instructions": [
      "Heat butter in a non-stick pan over medium heat",
      "Add chopped tomatoes and cook for 2 minutes",
      "Beat eggs with salt and pepper",
      "Pour eggs into pan and scramble gently",
      "Add cheese and continue cooking until set",
      "Serve immediately"
    ],
    "prep_time": "5 minutes",
    "cook_time": "8 minutes",
    "difficulty": "Easy",
    "servings": 2,
    "nutrition": {
      "calories": "280 kcal",
      "carbs": "8g",
      "protein": "20g",
      "fat": "18g"
    }
  },
  "pantry_items_used": ["eggs", "cheese", "tomato"]
}
```

**Error Response (400 if no items):**
```json
{
  "success": false,
  "error": "No items in pantry"
}
```

### 6. Get Fallback Recipes
**GET** `/api/recipes/fallback`

Get static fallback recipes when AI is unavailable.

**Response:**
```json
{
  "success": true,
  "recipes": [
    {
      "name": "Pasta with Tomato Sauce",
      "description": "A simple and classic pasta dish",
      "ingredients": [
        {"name": "pasta", "amount": "8", "unit": "oz"},
        {"name": "tomato", "amount": "2", "unit": "medium"},
        {"name": "garlic", "amount": "2", "unit": "cloves"},
        {"name": "olive oil", "amount": "2", "unit": "tbsp"}
      ],
      "instructions": [
        "Boil water and cook pasta according to package directions",
        "Heat olive oil in a pan, add minced garlic",
        "Add chopped tomatoes and cook until softened",
        "Season with salt and pepper",
        "Toss cooked pasta with sauce and serve"
      ],
      "prep_time": "10 minutes",
      "cook_time": "15 minutes",
      "difficulty": "Easy",
      "servings": 2
    }
  ]
}
```

## Usage Examples

### JavaScript/Fetch
```javascript
// Get pantry items
const response = await fetch('http://127.0.0.1:5050/api/pantry');
const data = await response.json();
console.log(data.items);

// Add item
await fetch('http://127.0.0.1:5050/api/pantry', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ item: 'onions' })
});

// Get recipe suggestion
const recipeResponse = await fetch('http://127.0.0.1:5050/api/recipes/suggest', {
  method: 'POST'
});
const recipeData = await recipeResponse.json();
console.log(recipeData.recipe);
```

### cURL
```bash
# Get pantry
curl http://127.0.0.1:5050/api/pantry

# Add item
curl -X POST http://127.0.0.1:5050/api/pantry \
  -H "Content-Type: application/json" \
  -d '{"item": "onions"}'

# Get recipe
curl -X POST http://127.0.0.1:5050/api/recipes/suggest

# Delete item
curl -X DELETE http://127.0.0.1:5050/api/pantry/onions
```

## Features
- ✅ CORS enabled for cross-origin requests
- ✅ JSON responses for all API endpoints
- ✅ AI-powered recipe generation
- ✅ Fallback recipes when AI unavailable
- ✅ Error handling with proper HTTP status codes
- ✅ In-memory storage (can be replaced with database)

## Notes
- The app runs on port 5050
- All responses include a `success` field
- Error responses include an `error` field
- The pantry is stored in memory (resets when app restarts)
- AI recipes are generated using OpenAI GPT-4o
