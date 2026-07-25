"""
generate_icons.py
-----------------
Generates two icon assets for King Wins Android:

1. assets/generated/king_wins_launcher_foreground.png
   - 1024x1024 RGBA canvas
   - Original logo centred, scaled to occupy ~68% of the canvas
   - Transparent padding around it so adaptive icon masks don't clip the crown

2. android/app/src/main/res/drawable/king_wins_notification_large.png
   - 256x256 RGBA copy of the original logo (no recoloring, no crop)
   - Used as FCM large icon
"""

from PIL import Image
import os, shutil

SRC = "assets/images/king-win-logo-transferent-crop.png"

# ── 1. Launcher foreground ──────────────────────────────────────────────────
CANVAS  = 1024          # total canvas size
SCALE   = 0.68          # logo occupies 68 % of canvas (safe zone compliant)

out_dir = "assets/generated"
os.makedirs(out_dir, exist_ok=True)

logo = Image.open(SRC).convert("RGBA")
lw, lh = logo.size

# Fit logo into SCALE × CANVAS square keeping aspect ratio
max_side = int(CANVAS * SCALE)
ratio    = min(max_side / lw, max_side / lh)
new_w    = int(lw * ratio)
new_h    = int(lh * ratio)
logo_scaled = logo.resize((new_w, new_h), Image.LANCZOS)

canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
x = (CANVAS - new_w) // 2
y = (CANVAS - new_h) // 2
canvas.paste(logo_scaled, (x, y), logo_scaled)

out_fg = os.path.join(out_dir, "king_wins_launcher_foreground.png")
canvas.save(out_fg, "PNG", optimize=True)
print(f"[OK] Launcher foreground -> {out_fg}  ({new_w}x{new_h} inside {CANVAS}x{CANVAS})")

# -- 2. Notification large icon ----------------------------------------------
LARGE   = 256
drw_dir = os.path.join("android", "app", "src", "main", "res", "drawable")
os.makedirs(drw_dir, exist_ok=True)

logo_large = logo.copy()
logo_large.thumbnail((LARGE, LARGE), Image.LANCZOS)

out_large = os.path.join(drw_dir, "king_wins_notification_large.png")
logo_large.save(out_large, "PNG", optimize=True)
lw2, lh2 = logo_large.size
print(f"[OK] Notification large  -> {out_large}  ({lw2}x{lh2})")

print("\nDone.")
