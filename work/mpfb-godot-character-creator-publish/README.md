# mpfb-godot-character-creator 发布包(已执行)

《16 句话 4 小时，Codex 手搓了个 3D 捏人器，最难的是让衣服跟上身材》
——mpfb2/godot_character_creator 项目开发记(MPFB/MakeHuman → Blender 导出 GLB →
Godot 4.6 实时 Blend Shape 捏人换装)。
重点:开发过程本身——一个词「godot」定方向、资产下载连撞两堵墙(镜像几 KB/s + Git LFS 配额耗尽)、
MHCLO 辅助顶点导致资产尺寸爆炸、全屏 Control 吃掉鼠标事件、Magic Mouse 走 PanGesture、
胸部形变服装差 1.3 cm 的补偿方案、以及它自己写了个 `--promo-demo` 模式录宣传片。
博客线上为**英文版**(post 196),公众号为**中文版**(草稿 appmsgid=100000376)。

## 已发布结果

- 博客:https://lokiwang.com/journal/mpfb-godot-character-creator (post_id=196)
- 公众号草稿:appmsgid=100000376(22 张图全部上传成功,群发需后台手动确认)

## 文件

- `draft.md` — 博客发布模板(**英文**,源自 `blog/_en/196.md`;
  视频用 `{{V:promo-full}}` / `{{V:face-morph}}` 占位,脚本替换为上传后 URL 并配 poster 帧)
- `publish.sh` — 一键:上传 20 图 + 3 poster/封面 + 2 视频 → 生成终稿 → 建草稿 → 发布
- `media-map.txt` — 逻辑名 → /api/media URL(断点续传依据)
- 中文源:`blog/mpfb-godot-character-creator.md`;公众号:`blog/mpfb-godot-character-creator.weixin.md`

## 素材来源(blog/assets/mpfb-godot-character-creator/)

全部来自项目自带的 45.97 秒宣传片 `promo/mpfb_character_creator_promo.mp4`(Godot Movie Maker
固定 30 FPS 逐帧渲染)与 Blender 预览图:

- 封面 2 张:`cover.png`(博客 16:9,4 格拼图 + 标题)、`cover-mp.png`(公众号 2.35:1,3 格)
  ——由片中 4 个时间点抠帧后用 PIL 拼合
- 正文图 17 张:`still-*`(滑块/面部/肤色/发型/胡须/服装/鞋子/纹身/环绕/片头片尾)
  + `still-blender-preview.png`(Blender 里 MPFB 生成的基础人体,来自 `mpfb2/mpfb_human_preview.png`)
- GIF 4 张:`gif-gender`(性别形变) `gif-breast-cloth`(服装跟随) `gif-outfit`(换装连切) `gif-orbit`(360°)
- 视频 2 条:`promo-full.mp4`(项目原片 45.97s/2.9MB)、
  `face-morph.mp4`(从原片 16.0–24.5s 裁切出的面部形变特写 720×?, 0.11MB)

## 数据口径

开发数据来自 Codex 会话日志
`~/.codex/sessions/2026/07/27/rollout-2026-07-27T15-21-52-019fa273-*.jsonl`:
用户消息 16 条、07:22–11:58 UTC(4h36m)、`patch_apply_end` 43 次、
最终 `token_count.total_token_usage` 输入 48,919,870(缓存命中 47,563,776)/ 输出 118,293。
模型 `gpt-5.6-sol`(Codex Desktop 0.145.0-alpha.27,effort high)。
**本文不报 $ 成本**:该会话走 cliproxyapi 代理,没有可靠的官方计价口径。

代码/模型数据来自项目本体:`main.gd` 808 行、`tools/export_mpfb_character.py` 439 行、
GLB 50.0 MB、24 个 Blend Shape、14 个可变形网格(`godot --headless --path . -- --self-test` 实测通过)。
