#!/usr/bin/env python3
"""
QR Code Generator for Homecoming Proposal Website
This script generates a QR code that Miss Panda can scan with her phone!
"""

import qrcode
import socket

def get_local_ip():
    """Get the local IP address of this computer"""
    try:
        # Create a socket to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except:
        return "localhost"

def create_qr_code(url):
    """Create a QR code for the given URL"""
    # Create QR code instance
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    
    # Add data
    qr.add_data(url)
    qr.make(fit=True)
    
    # Create image
    img = qr.make_image(fill_color="pink", back_color="white")
    
    # Save the QR code
    img.save("homecoming_qr_code.png")
    print(f"\n✅ QR Code created successfully!")
    print(f"📁 Saved as: homecoming_qr_code.png")
    print(f"\n🔗 URL: {url}")
    print(f"\n💕 Show this QR code to Miss Panda and have her scan it!")
    

if __name__ == "__main__":
    print("🎀 Homecoming Proposal QR Code Generator 💕\n")
    
    print("Choose an option:")
    print("1. Create QR for LOCAL network (both on same WiFi)")
    print("2. Create QR for HOSTED website (after you upload online)")
    
    choice = input("\nEnter 1 or 2: ").strip()
    
    if choice == "1":
        local_ip = get_local_ip()
        url = f"http://{local_ip}:8000"
        print(f"\n📍 Your local IP: {local_ip}")
        print(f"\n⚠️  IMPORTANT: After creating the QR code, run this command:")
        print(f"   python3 -m http.server 8000")
        print(f"\n   Then she can scan the QR code (must be on same WiFi!)")
        create_qr_code(url)
        
    elif choice == "2":
        print("\n📝 First, upload your website to:")
        print("   - Netlify.com (easiest)")
        print("   - GitHub Pages")
        print("   - Or any hosting service")
        website_url = input("\nEnter your hosted website URL: ").strip()
        
        if website_url:
            if not website_url.startswith("http"):
                website_url = "https://" + website_url
            create_qr_code(website_url)
        else:
            print("❌ No URL provided!")
    else:
        print("❌ Invalid choice!")

