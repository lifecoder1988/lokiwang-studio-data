#!/usr/bin/env bash
# 弹珠小达文章媒体资产：从 recording/output/mp4 三段录屏提取静帧、GIF，合成双封面。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC="/Users/joe/deepseek-workspace/marble-master/recording/output/mp4"
CLIP1="$SRC/clip1_gameplay.mp4"
CLIP2="$SRC/clip2_jackpot.mp4"
CLIP3="$SRC/clip3_short.mp4"
OUTPUT_DIR="$REPO_ROOT/blog/assets/marble-master-pachinko"
FONT_FILE="${MARBLE_FONT:-/System/Library/Fonts/Hiragino Sans GB.ttc}"
TEMP_DIR="$(mktemp -d /tmp/marble-media.XXXXXX)"

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

for c in ffmpeg python3; do command -v "$c" >/dev/null 2>&1 || { echo "missing: $c" >&2; exit 1; }; done
python3 - <<'PY'
try:
    import PIL  # noqa: F401
except ImportError as exc:
    raise SystemExit("Pillow is required") from exc
PY
for f in "$CLIP1" "$CLIP2" "$CLIP3" "$FONT_FILE"; do
  [[ -r "$f" ]] || { echo "not readable: $f" >&2; exit 1; }
done

mkdir -p "$OUTPUT_DIR"

# 博客内嵌视频（拷贝 + faststart）
ffmpeg -hide_banner -loglevel error -y -i "$CLIP1" -map 0 -c copy -movflags +faststart "$OUTPUT_DIR/clip1-gameplay.mp4"
ffmpeg -hide_banner -loglevel error -y -i "$CLIP2" -map 0 -c copy -movflags +faststart "$OUTPUT_DIR/clip2-jackpot.mp4"

extract_still() { # extract_still <clip> <timestamp> <filename>
  ffmpeg -hide_banner -loglevel error -y -ss "$2" -i "$1" -frames:v 1 -q:v 2 "$OUTPUT_DIR/$3"
}

extract_still "$CLIP1" "00:00:01.5" "still-machine.jpg"     # 整机台，×3×3×3 锁定
extract_still "$CLIP2" "00:00:01.0" "still-x10.jpg"         # ×10×10×10，中奖弹道 1 条
extract_still "$CLIP2" "00:00:05.7" "still-jackpot.jpg"     # 中奖 +100
extract_still "$CLIP1" "00:00:08.8" "still-miss.jpg"        # 未中奖

make_gif() { # make_gif <clip> <start> <duration> <filename>
  local palette="$TEMP_DIR/${4%.gif}-palette.png"
  ffmpeg -hide_banner -loglevel error -y -ss "$2" -t "$3" -i "$1" \
    -vf "fps=12,scale=360:-1:flags=lanczos,palettegen=stats_mode=diff" \
    -frames:v 1 -update 1 "$palette"
  ffmpeg -hide_banner -loglevel error -y -ss "$2" -t "$3" -i "$1" -i "$palette" \
    -lavfi "fps=12,scale=360:-1:flags=lanczos[scaled];[scaled][1:v]paletteuse=dither=sierra2_4a:diff_mode=rectangle" \
    -loop 0 "$OUTPUT_DIR/$4"
}

make_gif "$CLIP3" "00:00:00.0" "1.6" "gif-reels.gif"        # 液晶三转轮摇到 ×10×10×10
make_gif "$CLIP3" "00:00:01.6" "5.4" "gif-around-panel.gif" # 弹珠绕中央液晶面板
make_gif "$CLIP1" "00:00:12.6" "5.8" "gif-gameplay.gif"     # 一杆进洞：×10 中奖 +150
make_gif "$CLIP2" "00:00:03.6" "4.4" "gif-jackpot.gif"      # 落袋，中奖 +100

python3 - "$OUTPUT_DIR" "$FONT_FILE" <<'PY'
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

output_dir = Path(sys.argv[1])
font_path = sys.argv[2]

TITLE = "小县城万达开了 4 家弹珠店，我回家让 AI 造了一台柏青哥"
TEXT = (239, 244, 255, 255)


def font(size, weight="Bold"):
    f = ImageFont.truetype(font_path, size=size)
    try:
        f.set_variation_by_name(weight)
    except (AttributeError, OSError):
        pass
    return f


def make_cover(size, destination, title_size):
    width, height = size
    source = Image.open(output_dir / "still-jackpot.jpg").convert("RGB")
    background = ImageOps.fit(source, size, method=Image.Resampling.LANCZOS)
    background = background.filter(ImageFilter.GaussianBlur(radius=max(10, width // 80)))
    shade = Image.new("RGBA", size, (4, 8, 18, 95))
    cover = Image.alpha_composite(background.convert("RGBA"), shade)

    gameplay = ImageOps.contain(source, (int(width * 0.42), height), method=Image.Resampling.LANCZOS)
    gameplay_x = width - gameplay.width
    cover.alpha_composite(gameplay.convert("RGBA"), (gameplay_x, (height - gameplay.height) // 2))

    gradient = Image.new("RGBA", size, (0, 0, 0, 0))
    pixels = gradient.load()
    fade_end = max(1, gameplay_x + gameplay.width // 2)
    for x in range(width):
        alpha = int(210 * max(0.0, 1.0 - x / fade_end))
        for y in range(height):
            pixels[x, y] = (5, 10, 22, alpha)
    cover = Image.alpha_composite(cover, gradient)

    draw = ImageDraw.Draw(cover)
    title_font = font(title_size)
    lines = ["小县城万达开了 4 家弹珠店，", "我回家让 AI 造了一台柏青哥"]
    gap = int(title_size * 0.35)
    boxes = [draw.textbbox((0, 0), line, font=title_font) for line in lines]
    heights = [b[3] - b[1] for b in boxes]
    total = sum(heights) + gap * (len(lines) - 1)
    y = (height - total) // 2
    left = int(width * 0.05)
    stroke = max(2, title_size // 24)
    for line, h in zip(lines, heights):
        draw.text((left, y), line, font=title_font, fill=TEXT,
                  stroke_width=stroke, stroke_fill=(4, 8, 18, 255))
        y += h + gap

    if "".join(lines) != TITLE:
        raise SystemExit("cover title mismatch")
    cover.convert("RGB").save(destination, optimize=True)


make_cover((1600, 900), output_dir / "cover.png", 66)
make_cover((900, 383), output_dir / "cover-mp.png", 34)
PY

printf 'Generated media in %s\n' "$OUTPUT_DIR"
