# kimi-three-sites 封面 prompt

当前线上封面(post 199)是三个站的实拍拼图 `assets/kimi-three-sites/cover.png`。
如果要换成 AI 生成封面,用下面的 prompt。尺寸:博客 16:9(1600×900),公众号 2.35:1(1600×681)
——建议先出 16:9,再 `ffmpeg -vf "crop=1600:681:0:110"` 裁公众号版。
**统一不要让模型写字**(中文必糊),需要标题字后期加。

## A. 主推:一句话长出三个站

```
Dark editorial tech illustration, cinematic 3D render. At the bottom center, a single
glowing chat input bar with one short typed sentence and a blinking cursor. Rising out
of it in a fan: three floating browser windows, tilted in perspective.
Left window - a neon-gold arcade fruit slot machine UI, brushed gold frame with a ring
of glowing bulbs, fruit icons, gold confetti spilling out of the frame.
Center window - a dark market dashboard, red and green candlesticks, sparkline cards,
a thin vertical marker line.
Right window - a clean white chat app, purple message bubbles, a small red unread dot.
Deep green-to-black gradient background, warm gold rim light, faint grid floor,
volumetric haze, sharp UI geometry, high detail, no text, no logos, no watermark. 16:9
```

负面词:`readable text, garbled letters, chinese characters, watermark, logo, people, hands, blurry UI`

## B. 反转版:第三块屏白了(呼应文章结尾)

```
Same three floating browser windows over a dark green-black void, cinematic 3D render.
The left window glows gold with a slot machine and confetti, the middle window shows a
red-green stock dashboard - but the right window has gone completely blank white, a
hairline crack running across it, a cold red error glow leaking from its edges and one
tiny cursor still blinking. Deep contrast between the two live screens and the dead
white one. Volumetric haze, gold rim light, no text, no logos. 16:9
```

## C. 极简海报版(公众号封面更耐看)

```
Minimal poster, flat vector with subtle grain. Three rounded-rectangle app tiles in a
row on a deep green background: a gold slot-machine tile with a cherry and a bell, a
black dashboard tile with a red candlestick chart, a white chat tile with two purple
bubbles. Below them, one thin horizontal line with a small blinking cursor at its end,
suggesting a single typed sentence. Generous negative space, editorial layout,
no text, no logos. 2.35:1
```

## 换封面的操作

```bash
export BLOG_BASE_URL=https://lokiwang.com BLOG_ADMIN_USER=admin
export BLOG_ADMIN_PASS="$(security find-generic-password -a "$USER" -s loki-blog-admin -w)"
B=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl
$B media upload blog/assets/kimi-three-sites/cover.png   # → 拿 url
$B posts update 199 --cover /api/media/uploads/...
```
