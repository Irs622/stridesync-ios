import math
from PIL import Image, ImageDraw

def generate_app_store_icon():
    size = 1024
    img = Image.new("RGB", (size, size), (255, 75, 0)) # App Store icons cannot have alpha
    draw = ImageDraw.Draw(img)
    
    # Premium Athletic Orange Gradient
    for y in range(size):
        ratio = y / float(size)
        r = int(255 * (1.0 - ratio * 0.15))
        g = int(80 * (1.0 - ratio * 0.5) + 30 * ratio)
        b = int(0 * (1.0 - ratio) + 40 * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
        
    # Athletic Energy Waves & Glyphs
    # Draw dynamic glowing speed streaks
    streak_color = (255, 255, 255, 50)
    for i in range(5):
        offset = i * 40
        draw.arc([150 - offset, 200 - offset, size - 150 + offset, size - 200 + offset], 
                 start=-30, end=70, fill=(255, 140, 60), width=18)
        
    # Central Dynamic Runner Emblem (White Bold Icon)
    # Head
    head_center = (512, 330)
    head_radius = 65
    draw.ellipse([head_center[0]-head_radius, head_center[1]-head_radius, 
                  head_center[0]+head_radius, head_center[1]+head_radius], fill=(255, 255, 255))
    
    # Torso & Striding Limbs (Stroked lines)
    # Torso
    draw.line([(512, 390), (475, 540)], fill=(255, 255, 255), width=58)
    
    # Forward Right Leg
    draw.line([(475, 540), (590, 640)], fill=(255, 255, 255), width=54)
    draw.line([(590, 640), (540, 770)], fill=(255, 255, 255), width=50)
    
    # Back Left Leg (Extended stride)
    draw.line([(475, 540), (380, 630)], fill=(255, 255, 255), width=54)
    draw.line([(380, 630), (330, 750)], fill=(255, 255, 255), width=50)
    
    # Forward Left Arm
    draw.line([(500, 420), (410, 480)], fill=(255, 255, 255), width=46)
    draw.line([(410, 480), (450, 560)], fill=(255, 255, 255), width=42)
    
    # Back Right Arm
    draw.line([(500, 420), (610, 460)], fill=(255, 255, 255), width=46)
    draw.line([(610, 460), (660, 390)], fill=(255, 255, 255), width=42)
    
    img.save("assets/AppIcon-1024.png", "PNG")
    print("Successfully generated assets/AppIcon-1024.png")

if __name__ == "__main__":
    generate_app_store_icon()

