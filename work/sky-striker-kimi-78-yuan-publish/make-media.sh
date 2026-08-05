#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_ROOT="/Users/joe/code/sky_striker"
SOURCE_VIDEO="$SOURCE_ROOT/sky_striker_demo.mp4"
SESSION_FILE="/Users/joe/.codex/sessions/2026/08/05/rollout-2026-08-05T11-10-24-019fcfe6-9b85-77e1-86fd-f2e4a841f210.jsonl"
OUTPUT_DIR="$REPO_ROOT/blog/assets/sky-striker-kimi-78-yuan"
FONT_FILE="${SKY_STRIKER_FONT:-/Users/joe/Library/Fonts/NotoSansSC[wght].ttf}"
TEMP_DIR="$(mktemp -d /tmp/sky-striker-media.XXXXXX)"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

for command_name in ffmpeg ffprobe python3; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  }
done

python3 - <<'PY'
try:
    import PIL  # noqa: F401
except ImportError as exc:
    raise SystemExit("Pillow is required to compose the evidence sheets and covers") from exc
PY

for required_file in "$SOURCE_VIDEO" "$SESSION_FILE" "$FONT_FILE"; do
  if [[ ! -r "$required_file" ]]; then
    printf 'Required source is not readable: %s\n' "$required_file" >&2
    exit 1
  fi
done

mkdir -p "$OUTPUT_DIR"

ffmpeg -hide_banner -loglevel error -y \
  -i "$SOURCE_VIDEO" \
  -map 0 -c copy -movflags +faststart \
  "$OUTPUT_DIR/gameplay-full.mp4"

extract_still() {
  local timestamp="$1"
  local filename="$2"
  ffmpeg -hide_banner -loglevel error -y \
    -ss "$timestamp" -i "$SOURCE_VIDEO" \
    -frames:v 1 -q:v 2 \
    "$OUTPUT_DIR/$filename"
}

extract_still "00:00:08" "still-levelup.jpg"
extract_still "00:00:24" "still-boss-entrance.jpg"
extract_still "00:00:28" "still-ultimate.jpg"
extract_still "00:00:34" "still-phase-two.jpg"
extract_still "00:00:40" "still-victory.jpg"

make_gif() {
  local filename="$1"
  local start_time="$2"
  local duration="$3"
  local palette="$TEMP_DIR/${filename%.gif}-palette.png"

  ffmpeg -hide_banner -loglevel error -y \
    -ss "$start_time" -t "$duration" -i "$SOURCE_VIDEO" \
    -vf "fps=12,scale=360:-1:flags=lanczos,palettegen=stats_mode=diff" \
    -frames:v 1 -update 1 "$palette"

  ffmpeg -hide_banner -loglevel error -y \
    -ss "$start_time" -t "$duration" -i "$SOURCE_VIDEO" -i "$palette" \
    -lavfi "fps=12,scale=360:-1:flags=lanczos[scaled];[scaled][1:v]paletteuse=dither=sierra2_4a:diff_mode=rectangle" \
    -loop 0 "$OUTPUT_DIR/$filename"
}

make_gif "gif-gameplay-levelup.gif" "00:00:04" "6"
make_gif "gif-boss-entrance.gif" "00:00:21" "6"
make_gif "gif-ultimate.gif" "00:00:27" "3"
make_gif "gif-phase-two.gif" "00:00:31" "7"
make_gif "gif-victory.gif" "00:00:38" "6"

# Recover the literal add-file patch from the named Codex session. This is the
# source of truth for the first aircraft-only sprite set; no shapes are inferred.
python3 - "$SESSION_FILE" "$TEMP_DIR" <<'PY'
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

session_path = Path(sys.argv[1])
temporary_root = Path(sys.argv[2])
marker = "*** Add File: /Users/joe/code/sky_striker/tools/gen_sprites.py"
patch_text = None

for raw_line in session_path.read_text(encoding="utf-8").splitlines():
    event = json.loads(raw_line)
    payload = event.get("payload", {})
    if not (
        event.get("type") == "response_item"
        and payload.get("type") == "custom_tool_call"
        and payload.get("name") == "exec"
    ):
        continue
    source = payload.get("input", "")
    if marker not in source:
        continue
    match = re.search(r'const patch = ("(?:\\.|[^"\\])*");', source)
    if match is None:
        raise SystemExit("Found the generator call but could not decode its patch string")
    patch_text = json.loads(match.group(1))
    break

if patch_text is None:
    raise SystemExit("The exact original gen_sprites.py add-file patch was not found")

lines = patch_text.splitlines()
try:
    start = lines.index(marker) + 1
    end = lines.index("*** End Patch", start)
except ValueError as exc:
    raise SystemExit("The recovered generator patch has unexpected boundaries") from exc

added_lines = lines[start:end]
if not added_lines or any(not line.startswith("+") for line in added_lines):
    raise SystemExit("The recovered add-file patch contains a non-added source line")

generator_source = "\n".join(line[1:] for line in added_lines) + "\n"
generator_path = temporary_root / "tools" / "gen_sprites.py"
generator_path.parent.mkdir(parents=True, exist_ok=True)
generator_path.write_text(generator_source, encoding="utf-8")
PY

python3 "$TEMP_DIR/tools/gen_sprites.py"

python3 - "$TEMP_DIR/assets/sprites" "$SOURCE_ROOT/assets" "$OUTPUT_DIR" "$FONT_FILE" <<'PY'
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

initial_dir = Path(sys.argv[1])
source_assets = Path(sys.argv[2])
output_dir = Path(sys.argv[3])
font_path = Path(sys.argv[4])

TITLE = "花了 78 元，说了 14 句话，我用 Kimi 做了一款魂系飞行射击游戏"
COMPARISON_LABEL = "根据会话原始代码复现的初版 / 最终拟人版"
CHARACTERS = [
    ("player.png", "Player"),
    ("enemy_drone.png", "Drone"),
    ("enemy_weaver.png", "Weaver"),
    ("enemy_gunner.png", "Gunner"),
    ("enemy_dasher.png", "Dasher"),
    ("enemy_tank.png", "Tank"),
    ("boss.png", "Boss"),
]
HUD_FILES = [
    "hud_panel.png",
    "bar_frame.png",
    "bar_fill_red.png",
    "bar_fill_blue.png",
    "bar_fill_green.png",
    "boss_bar_frame.png",
    "boss_bar_fill.png",
    "icon_hp.png",
    "icon_energy.png",
    "icon_exp.png",
    "icon_weapon.png",
    "portrait_player.png",
    "ult_icon.png",
]

BG = (13, 18, 30, 255)
PANEL = (24, 32, 50, 255)
BORDER = (75, 96, 128, 255)
TEXT = (239, 244, 255, 255)
MUTED = (166, 180, 205, 255)
GOLD = (255, 205, 77, 255)


def font(size: int, weight: str = "Regular") -> ImageFont.FreeTypeFont:
    selected = ImageFont.truetype(str(font_path), size=size)
    try:
        selected.set_variation_by_name(weight)
    except (AttributeError, OSError):
        pass
    return selected


def contain_nearest(image: Image.Image, max_width: int, max_height: int) -> Image.Image:
    width, height = image.size
    integer_scale = max(1, min(max_width // width, max_height // height))
    return image.resize((width * integer_scale, height * integer_scale), Image.Resampling.NEAREST)


def draw_sprite_grid(
    canvas: Image.Image,
    draw: ImageDraw.ImageDraw,
    root: Path,
    area: tuple[int, int, int, int],
    heading: str,
) -> None:
    left, top, right, bottom = area
    draw.rounded_rectangle(area, radius=18, fill=PANEL, outline=BORDER, width=2)
    draw.text((left + 24, top + 20), heading, font=font(34), fill=GOLD)
    grid_top = top + 78
    columns = 4
    rows = 2
    cell_width = (right - left - 32) // columns
    cell_height = (bottom - grid_top - 20) // rows
    for index, (filename, label) in enumerate(CHARACTERS):
        column = index % columns
        row = index // columns
        cell_left = left + 16 + column * cell_width
        cell_top = grid_top + row * cell_height
        sprite = Image.open(root / filename).convert("RGBA")
        scaled = contain_nearest(sprite, cell_width - 30, cell_height - 72)
        x = cell_left + (cell_width - scaled.width) // 2
        y = cell_top + 10 + (cell_height - 62 - scaled.height) // 2
        canvas.alpha_composite(scaled, (x, y))
        label_box = draw.textbbox((0, 0), label, font=font(22))
        label_width = label_box[2] - label_box[0]
        draw.text(
            (cell_left + (cell_width - label_width) // 2, cell_top + cell_height - 42),
            label,
            font=font(22),
            fill=MUTED,
        )


comparison = Image.new("RGBA", (1600, 900), BG)
comparison_draw = ImageDraw.Draw(comparison)
comparison_draw.text((42, 26), COMPARISON_LABEL, font=font(48), fill=TEXT)
draw_sprite_grid(comparison, comparison_draw, initial_dir, (36, 104, 782, 870), "根据会话原始代码复现的初版")
draw_sprite_grid(
    comparison,
    comparison_draw,
    source_assets / "sprites",
    (818, 104, 1564, 870),
    "最终拟人版",
)
comparison.convert("RGB").save(output_dir / "sprites-before-after.png", optimize=True)

characters = Image.new("RGBA", (1600, 720), BG)
characters_draw = ImageDraw.Draw(characters)
characters_draw.text((42, 26), "最终角色素材", font=font(48), fill=TEXT)
draw_sprite_grid(
    characters,
    characters_draw,
    source_assets / "sprites",
    (36, 104, 1564, 690),
    "Final anthropomorphic character sprites",
)
characters.convert("RGB").save(output_dir / "characters-final.png", optimize=True)

hud = Image.new("RGBA", (1600, 900), BG)
hud_draw = ImageDraw.Draw(hud)
hud_draw.text((42, 26), "最终 HUD 素材", font=font(48), fill=TEXT)
hud_draw.rounded_rectangle((36, 104, 1564, 870), radius=18, fill=PANEL, outline=BORDER, width=2)

panel = Image.open(source_assets / "ui" / "hud_panel.png").convert("RGBA")
panel_scaled = panel.resize((1080, 144), Image.Resampling.NEAREST)
hud.alpha_composite(panel_scaled, (260, 138))
hud_draw.text((260, 294), "hud_panel.png", font=font(22), fill=MUTED)

wide_files = HUD_FILES[1:7]
for index, filename in enumerate(wide_files):
    image = Image.open(source_assets / "ui" / filename).convert("RGBA")
    scaled = contain_nearest(image, 660, 72)
    column = index % 2
    row = index // 2
    x = 100 + column * 770
    y = 350 + row * 112
    hud.alpha_composite(scaled, (x, y))
    hud_draw.text((x, y + scaled.height + 8), filename, font=font(20), fill=MUTED)

small_files = HUD_FILES[7:]
for index, filename in enumerate(small_files):
    image = Image.open(source_assets / "ui" / filename).convert("RGBA")
    scaled = contain_nearest(image, 150, 150)
    cell_width = 205
    x = 85 + index * cell_width + (cell_width - scaled.width) // 2
    y = 700 + (130 - scaled.height) // 2
    hud.alpha_composite(scaled, (x, y))
    label_box = hud_draw.textbbox((0, 0), filename, font=font(18))
    label_width = label_box[2] - label_box[0]
    hud_draw.text((85 + index * cell_width + (cell_width - label_width) // 2, 835), filename, font=font(18), fill=MUTED)

hud.convert("RGB").save(output_dir / "hud-assets.png", optimize=True)

stills = [
    ("still-levelup.jpg", "00:08  LEVEL UP"),
    ("still-boss-entrance.jpg", "00:24  BOSS ENTRANCE"),
    ("still-ultimate.jpg", "00:28  ULTIMATE"),
    ("still-phase-two.jpg", "00:34  PHASE TWO"),
    ("still-victory.jpg", "00:40  VICTORY"),
]
contact = Image.new("RGB", (1600, 1240), BG[:3])
contact_draw = ImageDraw.Draw(contact)
contact_draw.text((42, 24), "Sky Striker 实机关键帧", font=font(46, "Medium"), fill=TEXT[:3])
thumb_size = (300, 533)
positions = [(100, 100), (650, 100), (1200, 100), (375, 680), (925, 680)]
for (filename, label), (x, y) in zip(stills, positions):
    image = Image.open(output_dir / filename).convert("RGB")
    thumb = ImageOps.fit(image, thumb_size, method=Image.Resampling.LANCZOS)
    contact.paste(thumb, (x, y))
    contact_draw.rectangle((x, y, x + thumb.width, y + 42), fill=(0, 0, 0))
    contact_draw.text((x + 10, y + 7), label, font=font(20), fill=TEXT[:3])
contact.save(output_dir / "contact-sheet.jpg", quality=91, optimize=True, progressive=True)


def cover_from_gameplay(size: tuple[int, int], destination: Path, title_size: int) -> None:
    width, height = size
    source = Image.open(output_dir / "still-ultimate.jpg").convert("RGB")
    background = ImageOps.fit(source, size, method=Image.Resampling.LANCZOS)
    background = background.filter(ImageFilter.GaussianBlur(radius=max(10, width // 80)))
    shade = Image.new("RGBA", size, (4, 8, 18, 95))
    cover = Image.alpha_composite(background.convert("RGBA"), shade)

    gameplay = ImageOps.contain(source, (int(width * 0.47), height), method=Image.Resampling.LANCZOS)
    gameplay_x = width - gameplay.width
    cover.alpha_composite(gameplay.convert("RGBA"), (gameplay_x, (height - gameplay.height) // 2))

    gradient = Image.new("RGBA", size, (0, 0, 0, 0))
    gradient_pixels = gradient.load()
    fade_end = max(1, gameplay_x + gameplay.width // 2)
    for x in range(width):
        alpha = int(205 * max(0.0, 1.0 - x / fade_end))
        for y in range(height):
            gradient_pixels[x, y] = (5, 10, 22, alpha)
    cover = Image.alpha_composite(cover, gradient)

    draw = ImageDraw.Draw(cover)
    title_font = font(title_size, "Bold")
    lines = ["花了 78 元，说了 14 句话，", "我用 Kimi 做了一款", "魂系飞行射击游戏"]
    line_gap = int(title_size * 0.35)
    line_boxes = [draw.textbbox((0, 0), line, font=title_font) for line in lines]
    line_heights = [box[3] - box[1] for box in line_boxes]
    total_height = sum(line_heights) + line_gap * (len(lines) - 1)
    y = (height - total_height) // 2
    left = int(width * 0.055)
    stroke = max(2, title_size // 24)
    for line, line_height in zip(lines, line_heights):
        draw.text(
            (left, y),
            line,
            font=title_font,
            fill=TEXT,
            stroke_width=stroke,
            stroke_fill=(4, 8, 18, 255),
        )
        y += line_height + line_gap

    rendered_title = "".join(lines)
    if rendered_title != TITLE:
        raise SystemExit("Cover title text does not match the required exact title")
    cover.convert("RGB").save(destination, optimize=True)


cover_from_gameplay((1600, 900), output_dir / "cover.png", 70)
cover_from_gameplay((900, 383), output_dir / "cover-mp.png", 35)
PY

printf 'Generated media in %s\n' "$OUTPUT_DIR"
