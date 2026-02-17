#!/usr/bin/env python3
"""Generate app icon and splash images for Burger Budget."""

from PIL import Image, ImageDraw, ImageFont
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
OUTPUT_DIR = os.path.join(PROJECT_DIR, 'assets', 'icons')

# Brand color
BG_COLOR = '#FF6B35'
WHITE = '#FFFFFF'


def create_app_icon(size=1024):
    """Create main app icon: orange circle with burger emoji."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Orange circular background
    margin = int(size * 0.02)
    draw.ellipse(
        [margin, margin, size - margin, size - margin],
        fill=BG_COLOR,
    )

    # Draw burger symbol (stylized lines)
    cx, cy = size // 2, size // 2
    r = int(size * 0.28)

    # Top bun (arc)
    bun_top = int(cy - r * 1.1)
    bun_bot = int(cy - r * 0.2)
    draw.ellipse(
        [cx - r, bun_top, cx + r, bun_bot + int(r * 0.3)],
        fill='#F4A460',
    )

    # Patty
    patty_y = int(cy + r * 0.05)
    patty_h = int(r * 0.3)
    draw.rounded_rectangle(
        [cx - r, patty_y, cx + r, patty_y + patty_h],
        radius=int(r * 0.1),
        fill='#8B4513',
    )

    # Lettuce (green wavy line)
    lettuce_y = int(cy - r * 0.1)
    lettuce_h = int(r * 0.2)
    draw.rounded_rectangle(
        [cx - int(r * 1.05), lettuce_y, cx + int(r * 1.05),
         lettuce_y + lettuce_h],
        radius=int(r * 0.08),
        fill='#228B22',
    )

    # Cheese (yellow)
    cheese_y = int(patty_y + patty_h)
    cheese_h = int(r * 0.15)
    draw.rounded_rectangle(
        [cx - int(r * 1.02), cheese_y, cx + int(r * 1.02),
         cheese_y + cheese_h],
        radius=int(r * 0.05),
        fill='#FFD700',
    )

    # Bottom bun
    bot_bun_y = int(cheese_y + cheese_h)
    bot_bun_h = int(r * 0.35)
    draw.rounded_rectangle(
        [cx - r, bot_bun_y, cx + r, bot_bun_y + bot_bun_h],
        radius=int(r * 0.15),
        fill='#DEB887',
    )

    # Sesame seeds on top bun
    seed_r = int(r * 0.04)
    seed_y = int(bun_top + (bun_bot - bun_top) * 0.35)
    for offset in [-int(r * 0.4), 0, int(r * 0.4)]:
        sx = cx + offset
        draw.ellipse(
            [sx - seed_r, seed_y - seed_r, sx + seed_r, seed_y + seed_r],
            fill=WHITE,
        )

    return img


def create_foreground(size=1024):
    """Create adaptive icon foreground (transparent bg + icon)."""
    # Adaptive icons need 108dp with 72dp safe zone (66.7%)
    # Add padding for the safe zone
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    icon = create_app_icon(int(size * 0.7))
    offset = (size - icon.width) // 2
    img.paste(icon, (offset, offset), icon)
    return img


def create_splash_icon(size=512):
    """Create splash screen icon (smaller, centered)."""
    return create_app_icon(size)


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Main app icon
    icon = create_app_icon(1024)
    icon_path = os.path.join(OUTPUT_DIR, 'app_icon.png')
    icon.save(icon_path, 'PNG')
    print(f'Generated: {icon_path}')

    # Adaptive foreground
    fg = create_foreground(1024)
    fg_path = os.path.join(OUTPUT_DIR, 'app_icon_foreground.png')
    fg.save(fg_path, 'PNG')
    print(f'Generated: {fg_path}')

    # Splash icon
    splash = create_splash_icon(512)
    splash_path = os.path.join(OUTPUT_DIR, 'splash_icon.png')
    splash.save(splash_path, 'PNG')
    print(f'Generated: {splash_path}')


if __name__ == '__main__':
    main()
