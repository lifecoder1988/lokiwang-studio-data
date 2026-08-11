# ai-life-9-sentences 发布包(已执行完毕)

《9 句话，5500 万 token：Kimi 给我搓了个会老会死的 AI》——endless-game 项目开发记
(Kimi Code k3,5h43m,9 句用户输入,7 subagent,633 次调用 / 5530 万 token,192 文件 25474 行,84 测试)。
博客线上为**英文版**(post_id=214),公众号为**中文版**。

## 结果

- 博客:https://lokiwang.com/journal/ai-life-9-sentences (post_id=214,已发布)
- 公众号草稿:appmsgid=100000554(2026-08-11 通过 wechatsync 推送,群发需手动)
- 中文源:`blog/ai-life-9-sentences.md`(已回填 post_id / published_url / 媒体 URL)
- 英文线上版:`blog/_en/214.md` + `214.title.txt`(按惯例已重命名)

## 文件

- `draft.md` — 英文发布模板(图片为 assets 本地路径)
- `final-post.md` — 实际发布的英文终稿(媒体已换 /api/media URL,去 H1)
- `media-map.txt` — 10 张图的上传 URL 映射
- `post-id.txt` — 214
- `publish.sh` — 一键脚本(凭据从仓库根 .env 读,勿打印)

## 素材(blog/assets/ai-life-9-sentences/)

- 封面:`cover.png`(16:9,聊天页)、`cover-mp.png`(2.35:1,公众号)
- 截图 9 张:home / chat-lina / person / chat-chenyuan / chat-suwanqing / world / admin / family / timeline(timeline 未进正文)
- `lina-selfie.png` / `lina-photo2.png`:Lina 的 AI 自拍原图(取自 endless-game data/media,person 3)

## 数据来源

开发过程取自 ~/.kimi-code/sessions/wd_endless-game_84d58ca05d8a(wire.jsonl 的 usage.record 汇总)。
无单价数据,文章只报 token 量与调用次数,未估算金额。
