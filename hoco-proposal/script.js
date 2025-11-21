// Elements
const startBtn = document.getElementById('startBtn');
const nextBtn = document.getElementById('nextBtn');
const yesBtn = document.getElementById('yesBtn');
const noBtn = document.getElementById('noBtn');
const noMessage = document.getElementById('noMessage');
const sections = document.querySelectorAll('.section');
const bgMusic = document.getElementById('bgMusic');

let currentSection = 0;
let noButtonClickCount = 0;

// Navigate to next section
function goToSection(index) {
    sections.forEach((section, i) => {
        section.classList.remove('active');
        if (i === index) {
            section.classList.add('active');
        }
    });
    currentSection = index;
}

// Start button - go to memories
startBtn.addEventListener('click', () => {
    goToSection(1);
    animateMemories();
    // Uncomment to play music (requires audio file)
    // bgMusic.play().catch(e => console.log('Audio play prevented:', e));
});

// Animate memory cards
function animateMemories() {
    const memoryCards = document.querySelectorAll('.memory-card');
    memoryCards.forEach((card, index) => {
        setTimeout(() => {
            card.classList.add('visible');
        }, index * 800);
    });
}

// Next button - go to question
nextBtn.addEventListener('click', () => {
    goToSection(2);
});

// Yes button - go to final section
yesBtn.addEventListener('click', () => {
    goToSection(3);
    createConfetti();
    startCountdown();
});

// No button - playful interaction
noBtn.addEventListener('click', (e) => {
    noButtonClickCount++;
    noMessage.classList.add('show');
    
    // Move the button away
    const button = e.target;
    const maxX = window.innerWidth - button.offsetWidth - 100;
    const maxY = window.innerHeight - button.offsetHeight - 100;
    
    const randomX = Math.random() * maxX;
    const randomY = Math.random() * maxY;
    
    button.style.position = 'fixed';
    button.style.left = randomX + 'px';
    button.style.top = randomY + 'px';
    button.style.transition = 'all 0.3s ease';
    
    // Make Yes button bigger each time No is clicked
    const currentScale = 1 + (noButtonClickCount * 0.15);
    yesBtn.style.transform = `scale(${currentScale})`;
    
    setTimeout(() => {
        noMessage.classList.remove('show');
    }, 2000);
    
    // After 3 clicks, make No button really small and Yes button huge
    if (noButtonClickCount >= 3) {
        noBtn.style.transform = 'scale(0.5)';
        yesBtn.style.transform = 'scale(1.5)';
        noBtn.style.opacity = '0.5';
    }
});

// Make No button dodge on hover after first click
noBtn.addEventListener('mouseenter', () => {
    if (noButtonClickCount > 0) {
        const maxX = window.innerWidth - noBtn.offsetWidth - 100;
        const maxY = window.innerHeight - noBtn.offsetHeight - 100;
        
        const randomX = Math.random() * maxX;
        const randomY = Math.random() * maxY;
        
        noBtn.style.position = 'fixed';
        noBtn.style.left = randomX + 'px';
        noBtn.style.top = randomY + 'px';
    }
});

// Confetti effect
function createConfetti() {
    const container = document.getElementById('confetti-container');
    const colors = ['#f06292', '#ec407a', '#e91e63', '#c2185b', '#ff6090', '#ffc1e3'];
    const shapes = ['❤️', '💕', '💖', '💗', '💝', '✨', '⭐', '🌟'];
    
    // Create 100 confetti pieces
    for (let i = 0; i < 100; i++) {
        setTimeout(() => {
            const confetti = document.createElement('div');
            const isEmoji = Math.random() > 0.5;
            
            if (isEmoji) {
                confetti.textContent = shapes[Math.floor(Math.random() * shapes.length)];
                confetti.style.fontSize = Math.random() * 20 + 15 + 'px';
            } else {
                confetti.classList.add('confetti');
                confetti.style.background = colors[Math.floor(Math.random() * colors.length)];
                confetti.style.width = Math.random() * 15 + 5 + 'px';
                confetti.style.height = confetti.style.width;
            }
            
            confetti.style.position = 'absolute';
            confetti.style.left = Math.random() * 100 + '%';
            confetti.style.top = '-20px';
            confetti.style.opacity = '1';
            confetti.style.animation = `confetti-fall ${Math.random() * 3 + 2}s linear forwards`;
            
            container.appendChild(confetti);
            
            setTimeout(() => {
                confetti.remove();
            }, 5000);
        }, i * 30);
    }
    
    // Continue creating confetti every few seconds
    setInterval(() => {
        for (let i = 0; i < 20; i++) {
            setTimeout(() => {
                const confetti = document.createElement('div');
                const isEmoji = Math.random() > 0.5;
                
                if (isEmoji) {
                    confetti.textContent = shapes[Math.floor(Math.random() * shapes.length)];
                    confetti.style.fontSize = Math.random() * 20 + 15 + 'px';
                } else {
                    confetti.classList.add('confetti');
                    confetti.style.background = colors[Math.floor(Math.random() * colors.length)];
                    confetti.style.width = Math.random() * 15 + 5 + 'px';
                    confetti.style.height = confetti.style.width;
                }
                
                confetti.style.position = 'absolute';
                confetti.style.left = Math.random() * 100 + '%';
                confetti.style.top = '-20px';
                confetti.style.opacity = '1';
                confetti.style.animation = `confetti-fall ${Math.random() * 3 + 2}s linear forwards`;
                
                container.appendChild(confetti);
                
                setTimeout(() => {
                    confetti.remove();
                }, 5000);
            }, i * 100);
        }
    }, 3000);
}

// Countdown Timer
function startCountdown() {
    // May 31st, 2025, 7:00 PM - Our special date! 💕
    const specialDate = new Date(2025, 4, 31, 19, 0, 0).getTime();
    const countdownLabel = document.querySelector('.countdown-label');
    
    const countdown = setInterval(() => {
        const now = new Date().getTime();
        const distance = specialDate - now;
        
        // If the date has passed, count UP (days together)
        if (distance < 0) {
            const timeTogether = Math.abs(distance);
            const days = Math.floor(timeTogether / (1000 * 60 * 60 * 24));
            const hours = Math.floor((timeTogether % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((timeTogether % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((timeTogether % (1000 * 60)) / 1000);
            
            countdownLabel.textContent = 'We have been in love for...';
            
            document.getElementById('days').textContent = String(days).padStart(2, '0');
            document.getElementById('hours').textContent = String(hours).padStart(2, '0');
            document.getElementById('minutes').textContent = String(minutes).padStart(2, '0');
            document.getElementById('seconds').textContent = String(seconds).padStart(2, '0');
        } else {
            // Before the date, count DOWN
            const days = Math.floor(distance / (1000 * 60 * 60 * 24));
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            countdownLabel.textContent = 'Counting down to our special night...';
            
            document.getElementById('days').textContent = String(days).padStart(2, '0');
            document.getElementById('hours').textContent = String(hours).padStart(2, '0');
            document.getElementById('minutes').textContent = String(minutes).padStart(2, '0');
            document.getElementById('seconds').textContent = String(seconds).padStart(2, '0');
        }
    }, 1000);
}

// Keyboard shortcuts (optional)
document.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && currentSection < sections.length - 1) {
        if (currentSection === 0) startBtn.click();
        else if (currentSection === 1) nextBtn.click();
    }
});

