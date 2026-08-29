#!/usr/bin/env python3
"""Create annotated, publication-ready media for the AI phone secretary post."""

from __future__ import annotations

import math
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "0829" / "images"
OUTPUT = ROOT / "blog" / "assets" / "ai-phone-secretary"
FONT_PATH = Path("/System/Library/Fonts/STHeiti Medium.ttc")

BLUE = (24, 119, 242, 255)
CYAN = (0, 190, 210, 255)
RED = (235, 68, 90, 255)
GOLD = (244, 180, 0, 255)
WHITE = (255, 255, 255, 255)
INK = (12, 18, 28, 235)


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_PATH), size=size)


def rounded_label(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    *,
    size: int,
    color: tuple[int, int, int, int],
    padding: int = 16,
) -> tuple[int, int, int, int]:
    label_font = font(size)
    left, top = xy
    text_box = draw.multiline_textbbox((0, 0), text, font=label_font, spacing=6)
    width = text_box[2] - text_box[0]
    height = text_box[3] - text_box[1]
    box = (left, top, left + width + padding * 2, top + height + padding * 2)
    draw.rounded_rectangle(box, radius=max(10, padding), fill=INK, outline=color, width=max(3, size // 12))
    draw.multiline_text(
        (left + padding - text_box[0], top + padding - text_box[1]),
        text,
        font=label_font,
        fill=WHITE,
        spacing=6,
    )
    return box


def arrow(
    draw: ImageDraw.ImageDraw,
    start: tuple[int, int],
    end: tuple[int, int],
    *,
    color: tuple[int, int, int, int],
    width: int,
) -> None:
    draw.line((start, end), fill=color, width=width)
    angle = math.atan2(end[1] - start[1], end[0] - start[0])
    head = max(18, width * 3)
    wing = math.pi / 7
    p1 = (end[0] - head * math.cos(angle - wing), end[1] - head * math.sin(angle - wing))
    p2 = (end[0] - head * math.cos(angle + wing), end[1] - head * math.sin(angle + wing))
    draw.polygon((end, p1, p2), fill=color)


def callout(
    image: Image.Image,
    text: str,
    label_xy: tuple[int, int],
    target: tuple[int, int],
    *,
    rect: tuple[int, int, int, int] | None = None,
    size: int = 42,
    color: tuple[int, int, int, int] = BLUE,
) -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    if rect:
        draw.rounded_rectangle(rect, radius=16, outline=color, width=max(6, size // 6))
    label_box = rounded_label(draw, label_xy, text, size=size, color=color)
    start_x = label_box[2] if target[0] >= (label_box[0] + label_box[2]) // 2 else label_box[0]
    start_y = min(max(target[1], label_box[1] + 12), label_box[3] - 12)
    arrow(draw, (start_x, start_y), target, color=color, width=max(5, size // 8))


def save(image: Image.Image, name: str) -> None:
    path = OUTPUT / name
    if path.suffix.lower() in {".jpg", ".jpeg"}:
        ImageOps.exif_transpose(image).convert("RGB").save(path, quality=92, optimize=True, progressive=True)
    else:
        image.convert("RGB").save(path, optimize=True)


def open_rgba(name: str) -> Image.Image:
    return ImageOps.exif_transpose(Image.open(SOURCE / name)).convert("RGBA")


def make_photos() -> None:
    image = open_rgba("微信图片_20260829080156.jpg")
    callout(image, "第一块板\n最终退货", (55, 65), (490, 830), rect=(285, 235, 725, 1520), size=46, color=RED)
    callout(image, "SIM 卡槽", (755, 735), (515, 930), rect=(300, 845, 660, 1110), size=42)
    save(image, "air780-returned-annotated.jpg")

    image = open_rgba("微信图片_20260829080213.jpg")
    callout(image, "EC800M-CN\n4G 模块", (55, 890), (500, 1390), rect=(265, 1190, 730, 1650), size=39)
    callout(image, "锂电池", (730, 1390), (880, 1710), rect=(665, 1510, 1070, 1890), size=39, color=GOLD)
    callout(image, "USB-C\n供电 / 串口", (55, 1655), (470, 1780), size=35, color=CYAN)
    save(image, "ec800m-setup-annotated.jpg")

    image = open_rgba("微信图片_20260829080222.jpg")
    callout(image, "EC800M-CN", (55, 85), (435, 650), rect=(135, 315, 735, 1060), size=43)
    callout(image, "4G 天线接口", (560, 165), (430, 310), size=36, color=GOLD)
    callout(image, "电池接口", (660, 1150), (785, 1275), size=36, color=RED)
    callout(image, "USB-C", (55, 1540), (520, 1685), size=38, color=CYAN)
    save(image, "ec800m-front-annotated.jpg")

    image = open_rgba("微信图片_20260829080229.jpg")
    callout(image, "背面 SIM 卡槽\n方向别插反", (55, 125), (555, 1070), rect=(300, 835, 770, 1360), size=45, color=GOLD)
    save(image, "sim-slot-annotated.jpg")

    image = open_rgba("微信图片_20260829080236.jpg")
    callout(image, "红线 = 正极 +", (35, 70), (320, 1035), size=38, color=RED)
    callout(image, "黑线 = 负极 −", (35, 185), (245, 1075), size=38, color=BLUE)
    draw = ImageDraw.Draw(image, "RGBA")
    rounded_label(draw, (275, 1230), "反接可能直接烧板", size=36, color=RED)
    save(image, "battery-polarity-annotated.jpg")

    image = open_rgba("微信图片_20260829080242.jpg")
    callout(image, "4G 天线\n不接就没信号", (45, 70), (440, 540), rect=(65, 230, 880, 1130), size=43, color=GOLD)
    callout(image, "IPEX 天线线", (55, 1330), (430, 1265), size=37, color=CYAN)
    save(image, "lte-antenna-annotated.jpg")


def make_architecture_and_covers() -> None:
    image = open_rgba("微信图片_20260829080249.png")
    draw = ImageDraw.Draw(image, "RGBA")
    # The supplied schematic used a generic EC20 illustration. Replace only its
    # printed model label so the published diagram matches the actual hardware.
    draw.rounded_rectangle((675, 350, 875, 535), radius=12, fill=(232, 234, 231, 255), outline=(150, 154, 151, 255), width=3)
    draw.text((723, 363), "4G", font=font(43), fill=(30, 105, 210, 255))
    draw.text((700, 431), "LTE Cat.1", font=font(24), fill=(33, 37, 42, 255))
    draw.text((686, 478), "EC800M-CN", font=font(22), fill=(33, 37, 42, 255))
    callout(
        image,
        "实际使用\nEC800M-CN",
        (570, 80),
        (830, 470),
        rect=(585, 285, 965, 610),
        size=40,
        color=GOLD,
    )
    draw = ImageDraw.Draw(image, "RGBA")
    rounded_label(draw, (495, 760), "电话语音链路：手机网 ⇄ 4G 模块 ⇄ 电脑 AI", size=36, color=BLUE)
    save(image, "architecture-annotated.png")

    cover = ImageOps.fit(image.convert("RGB"), (1600, 900), method=Image.Resampling.LANCZOS).convert("RGBA")
    cover = ImageEnhance.Brightness(cover).enhance(0.78)
    overlay = Image.new("RGBA", cover.size, (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay, "RGBA")
    overlay_draw.rounded_rectangle((55, 505, 1545, 850), radius=28, fill=(6, 12, 22, 220), outline=BLUE, width=4)
    overlay_draw.text((100, 535), "让 AI 替我接电话", font=font(86), fill=WHITE)
    overlay_draw.text((105, 660), "刷砖一块板子，折腾整整一个月", font=font(49), fill=(208, 224, 246, 255))
    overlay_draw.text((108, 765), "AGI Hunt · 亲历踩坑", font=font(32), fill=(112, 188, 255, 255))
    cover = Image.alpha_composite(cover, overlay)
    save(cover, "cover.png")
    cover_mp = ImageOps.fit(cover.convert("RGB"), (900, 383), method=Image.Resampling.LANCZOS, centering=(0.5, 0.73))
    save(cover_mp.convert("RGBA"), "cover-mp.png")


def make_debug_screenshots() -> None:
    image = open_rgba("微信图片_20260829080254.png").crop((650, 210, 2350, 1430))
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, 105), fill=(8, 12, 20, 238))
    draw.text((36, 22), "排障证据 ①：听到蜂鸣，不等于听到 AI", font=font(46), fill=WHITE)
    draw.rounded_rectangle((25, 315, 1665, 780), radius=18, outline=GOLD, width=8)
    rounded_label(draw, (1010, 825), "stub TTS 只会生成 440Hz 蜂鸣", size=34, color=RED)
    save(image, "debug-beep-annotated.png")

    image = open_rgba("微信图片_20260829080300.png").crop((650, 125, 2450, 800))
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rectangle((0, 0, image.width, 95), fill=(8, 12, 20, 238))
    draw.text((35, 18), "排障证据 ②：3 参数“返回 OK”，上行却被静音", font=font(41), fill=WHITE)
    draw.rounded_rectangle((25, 150, 1765, 560), radius=18, outline=RED, width=8)
    rounded_label(draw, (1110, 575), "改用 5 参数版本", size=34, color=CYAN)
    save(image, "debug-qpsnd-annotated.png")


def make_video() -> None:
    source_video = SOURCE / "8a12e9fd58cf1ee594a805f3a24d258f.mp4"
    output_video = OUTPUT / "call-connected-proof.mp4"
    subprocess.run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-ss",
            "0.2",
            "-t",
            "8",
            "-i",
            str(source_video),
            "-map",
            "0:v:0",
            "-an",
            "-c:v",
            "libx264",
            "-preset",
            "medium",
            "-crf",
            "22",
            "-pix_fmt",
            "yuv420p",
            "-movflags",
            "+faststart",
            str(output_video),
        ],
        check=True,
    )
    subprocess.run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-ss",
            "2",
            "-i",
            str(output_video),
            "-frames:v",
            "1",
            str(OUTPUT / "call-connected-poster.jpg"),
        ],
        check=True,
    )


def main() -> None:
    if not FONT_PATH.is_file():
        raise SystemExit(f"missing font: {FONT_PATH}")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    make_photos()
    make_architecture_and_covers()
    make_debug_screenshots()
    make_video()


if __name__ == "__main__":
    main()
