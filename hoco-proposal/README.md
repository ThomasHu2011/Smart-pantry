# Homecoming Proposal Website 💕

A beautiful, romantic website to ask Miss Panda to Homecoming!

## Features
- ✨ Smooth animations and transitions
- 💕 Romantic pink color scheme
- 🎵 Background music support
- 📸 Photo gallery with placeholders
- 🎉 Confetti and heart animations
- ⏰ Countdown timer to Homecoming
- 😄 Playful "No" button that dodges clicks
- 📱 Fully responsive design

## Setup Instructions

### 1. Add Your Photos ✅ DONE!
Your photos are already added:
- `photo1.png` - First memory photo ✓
- `photo2.png` - Second memory photo ✓
- `photo3.png` - Third memory photo ✓

To change photos, just replace these files with new ones (keep the same names)!

### 2. Add Background Music
To add "Soda Pop" by Kpop Demon Hunter:

**Option A - Use a local file:**
1. Download the song as an MP3 file
2. Name it `soda-pop.mp3`
3. Place it in the same folder as index.html
4. In `index.html`, uncomment line 11:
   ```html
   <source src="soda-pop.mp3" type="audio/mpeg">
   ```
5. In `script.js`, uncomment line 27:
   ```javascript
   bgMusic.play().catch(e => console.log('Audio play prevented:', e));
   ```

**Option B - Use YouTube or streaming link:**
1. Find an embeddable version of the song
2. Add it as a background iframe or use a streaming service API

### 3. Set Your Special Date
Currently set to **May 31st, 2025 at 7:00 PM**

The countdown will:
- Count DOWN before May 31st
- Count UP after May 31st showing "We have been in love for..."

To change the date, edit `script.js` line 175:
```javascript
const specialDate = new Date(2025, 4, 31, 19, 0, 0).getTime();
```
Format: `(Year, Month (0-11), Day, Hour, Minute)` - Note: January = 0, February = 1, etc.

### 4. Customize Text (Optional)
You can edit any text in `index.html`:
- Change memory messages
- Adjust the final love message
- Add more memory cards

## How to Open
1. Double-click `index.html` to open in your browser
2. Or right-click → Open With → Your favorite browser

## How It Works

### Section 1: Intro
- Beautiful title with her nickname
- Floating hearts background
- "Click to Start" button

### Section 2: Memories
- Shows 3 photo cards with romantic messages
- Smooth fade-in animations
- Your special phrase "I hope I would I am here"

### Section 3: The Question
- Big romantic question
- Yes button (gets bigger each time No is clicked!)
- No button (runs away when clicked - so playful!)

### Section 4: Celebration
- Success message
- Continuous confetti and hearts
- Live countdown to Homecoming night

## Tips
- Test it once before showing her to make sure everything works!
- Make sure photos are properly sized (the site will auto-fit them)
- If music doesn't autoplay, click anywhere on the page first (browser requirement)
- Take a screenshot/video when she clicks Yes! 📸

## Customization Ideas
- Change colors in `styles.css` (search for #d81b60 and #f06292)
- Add more memory sections
- Change emoji decorations
- Adjust animation speeds

---

Good luck! You've got this! 💕✨

