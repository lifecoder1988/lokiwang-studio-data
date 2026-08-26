# deepseek-token-freedom 封面 prompt

当前线上封面(post 220)是实拍图 `blog/assets/deepseek-token-freedom/rack.png`。
如果要换成 AI 生成封面,用下面的 prompt。尺寸:博客 16:9(1600×900),公众号 2.35:1
(1600×681 或 900×383)——先出 16:9,再 `ffmpeg -vf "crop=1600:681:0:110"` 裁公众号版。
**统一不要让模型写字**(中文必糊,连 token 符号也别画),标题字后期加。

画风锚点(对齐文章里的实拍 + Grafana 监控的视觉):
Editorial tech product render, brushed-gold desktop AI supercomputer boxes, matte
black vents, subtle green NVIDIA-style accents, deep blue-black background, cyan/
teal monitoring glow, soft volumetric haze, warm rim light, slight film grain,
sharp product geometry, readable at small size. No text, no logos.

## A. 主推:两台黄金盒子在书架上值班(呼应文章开头实拍)

```
Cinematic editorial tech render, night scene. A warm wooden shelf holds two
brushed-gold compact desktop AI supercomputers side by side, each with a dark
vented top and a single soft glowing status light; a small black router sits
beside them with a row of blinking cyan LAN LEDs. Above the machines, faint
glowing cyan particles stream upward like silent data exhaust into the dark,
subtly suggesting unending 24/7 work. Deep blue-black background, soft volumetric
haze, cyan and amber glow accents, gentle warm rim light, film grain, sharp
product geometry, high detail, no text, no logos, no watermark, no people. 16:9
```

负面词:`readable text, garbled letters, chinese characters, numbers, token symbols, watermark, logo, people, hands`

## B. 监控视角版:NEURAL OBSERVATORY 前面站着两台机(呼应 06 降温/监控)

```
Dark editorial tech render. On a deep blue-black wall floats one large curved
monitor showing a clean dark monitoring dashboard: small rounded temperature
gauges in green, tiny sparkline graphs, a column of green online status dots —
all abstract, no readable text. In front of the screen, viewed from slightly
above-behind, stand two small brushed-gold desktop AI supercomputers glowing
softly, connected by a thin line of cool light. A small glowing closed-padlock
icon hovers beside them, hinting at privacy and data staying home. Cyan and teal
palette on black, soft volumetric haze, cinematic rim light, minimal, high
detail, no readable text, no logos, no watermark. 16:9
```

负面词:`readable text, letters, chinese characters, watermark, logo, people, photo, realistic face`

## C. 极简海报版(公众号封面更耐看,呼应结尾金句「账本上的数字→电表上的数字」)

```
Minimal flat poster with subtle grain. Centered on a deep blue-black background:
one small brushed-gold desktop AI box; from it one thin horizontal cable runs to
a small glowing power-socket icon at the right edge; near the socket, two short
glowing vertical bars form a pulse waveform (abstract "running tokens"), and a
tiny closed-padlock outline sits top-left as a privacy mark. Thin white
geometric guide lines, generous negative space at the top for a title, editorial
layout, cyan and gold accents on black, no text, no logos. 2.35:1
```

负面词:`readable text, letters, numbers, chinese characters, watermark, logo, photo, people`

## 换封面的操作

博客:
```bash
export BLOG_BASE_URL=https://lokiwang.com BLOG_ADMIN_USER=admin
export BLOG_ADMIN_PASS="$(security find-generic-password -a "$USER" -s loki-blog-admin -w)"
B=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl
$B media upload blog/assets/deepseek-token-freedom/cover.png   # → 拿 url
$B posts update 220 --cover /api/media/uploads/...
```

公众号草稿(appmsgid=100000607):用 C 方案出图裁 900×383,在公众号后台打开草稿手动
换封面即可(wechatsync 不支持改已建草稿的封面)。
