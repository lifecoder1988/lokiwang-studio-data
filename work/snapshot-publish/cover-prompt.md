# snapshot-rust-screenshot 封面 prompt

当前博客封面(post 223) = 官网截图 `site-screenshot-1200.png`。
若要换成 AI 生成封面,用下面的 prompt。尺寸:博客 16:9(1600×900),公众号 2.35:1
(1600×681 或 900×383)——先出 16:9,再 `ffmpeg -vf "crop=1600:681:0:110"` 裁公众号版。
**统一不要让模型写字**(中文必糊,代码也别画),标题字后期加。

画风锚点(对齐文章/官网视觉:深色技术底 + 绿 accent + 截屏工具的选区/马赛克元素):
Editorial tech product render, deep blue-black studio background, subtle green
accent glow (menthol #4ade80), floating glass screenshot window with dashed
marquee selection corners, tiny SVG-style arrow and mosaic tiles floating around
it, soft volumetric haze, crisp geometry, high detail, readable silhouette at
small size. No text, no logos, no watermark.

## A. 主推:悬浮的截图窗口,选区正在框选(呼应 04/05 的交互)

```
Cinematic editorial 3D render, deep blue-black studio background with soft
volumetric haze. Center: one large floating frosted-glass screenshot window at a
slight angle, its content as abstract dark UI blocks and photo thumbnails (no
readable text); across it a glowing menthol-green dashed rectangle selection
marquee with four corner brackets, ready to drag. Around the window float small
glossy SVG icons: a green arrow, a rounded rectangle, small 2x2 mosaic tiles, an
ellipse, gently rotating and glowing. A thin green light trail connects the
icons from the marquee down to a small toolbar chip. Warm subtle rim light, film
grain, crisp product geometry, cinematic depth, no text, no logos, no people.
16:9
```

负面词:`readable text, letters, chinese characters, garbled code, watermark, logo, people, hands, photo, realistic face`

## B. 代码感版:绿光标 + 像素马赛克(呼应 100% Rust / 命令行)

```
Minimal tech editorial 3D, deep blue-black scene. In the center floats a small
dark terminal-style window with only abstract blocks: nothing readable, just a
blinking green block-cursor and a few muted scan lines. Around humm a hovering
dashed selection marquee, a bright green arrow, and scattered small mosaic
pixel-tiles that pixelate into soft cubes of green and blue. A faint grid of
graph-paper guide lines on the background, one thin light beam from the cursor
upward. Cyan and menthol-green glow on black, volumetric haze, crisp geometry,
minimal, high detail, no readable text, no watermark. 16:9
```

负面词:`readable text, letters, numbers, chinese characters, code lines, watermark, logo, people`

## C. 极简海报版(公众号封面更耐看,呼应「把屏幕说清楚」)

```
Minimal flat editorial poster with subtle grain. Deep blue-black background,
generous negative space at top for a title. Center: one rounded dark glass
screen shape with a glowing menthol-green dashed marquee across its middle and
four small corner brackets; inside the marquee, tiny mosaic squares and a slim
green arrow; below, a small floating toolbar chip of three neutral dots. One
thin white geometric guide line, cyan/green accent glow on black, clean layout,
crisp, no text, no logos. 2.35:1
```

负面词:`readable text, letters, numbers, chinese characters, watermark, logo, photo, people`

## 换封面的操作

- 博客: `BLOGCTL posts update 223 --cover <url>` 或重传新图到 media → 更新 `blog/snapshot-rust-screenshot.md` frontmatter `cover:`。
- 公众号: 在草稿编辑页(见 work/snapshot-publish/README.md 的编辑链接)手动换头图后群发。
