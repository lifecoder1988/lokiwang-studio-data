---
title: Sky Striker 创作记录与双平台发布设计
status: draft
owner: lokiwang-studio-data
last_reviewed: 2026-08-05
source_of_truth: false
applies_to:
  - blog/sky-striker-kimi-78-yuan.md
  - blog/sky-striker-kimi-78-yuan.weixin.md
---

# Sky Striker 创作记录与双平台发布设计

## 目标

基于 `/Users/joe/code/sky_striker`、`sky_striker_demo.mp4`、Kimi Agent 导出包、Kimi Code 会话记录和 Codex 素材子任务记录，制作一篇第一人称、亲历式中文创作记录，并发布到博客和微信公众号。

文章标题确定为：

> 花了 78 元，说了 14 句话，我用 Kimi 做了一款魂系飞行射击游戏

## 已核实事实

- 初版由 Kimi Agent 根据“使用 Godot4 开发一款飞行射击游戏”生成，随后下载为本地项目。
- 本地 Kimi Code 会话共有 13 条真实用户指令；加上 Kimi Agent 的初始立项，共 14 句话。
- Kimi Code 使用 `kimi-code/k3`，包含主 Agent 和一个子 Agent。
- 会话用量合计：未缓存输入 519,200 tokens、缓存输入 26,259,007 tokens、输出 134,285 tokens。
- 按 Kimi K3 官方 API 单价：未缓存输入 $3/M、缓存输入 $0.30/M、输出 $15/M，合计约 $11.45；按 1 美元约 6.77 元人民币折算为约 78 元。
- 78 元是 API 等价成本。实际 Kimi Code 使用会员额度，没有产生同额的额外扣款；正文必须明确说明这一点。
- 最终项目为 Godot 4.6、540×960 竖屏游戏，包含 5 类普通敌人、两阶段 Boss、蓄力弹、能量大招、经验升级、素材化 HUD、MiniMax BGM、ElevenLabs 音效和自动游玩录像模式。
- 完整演示视频长 44.4 秒，H.264 + AAC，540×960、30fps。

## 叙事与文风

遵循仓库 `blog-writing-style`：第一人称亲历、短段落、口语化、适量吐槽，硬核事实用于证明过程，不写成项目说明书。

主线采用“我不断嫌弃，Kimi 不断加码”：从一句话得到可玩初版，到黑屏修复、素材重画、敌人补枪、HUD 返工、魂系化、音频生成和自动录像。

文章控制在约 1,800–2,400 字。每章围绕一条或一组相邻指令展开，单章正文优先控制在 150–250 字。

## 文章结构

1. 开场：先展示完整成片或 Boss 战高潮，交代 14 句话和 78 元的口径。
2. 一句话立项：Kimi Agent 生成第一版 Godot 飞行射击游戏。
3. 黑屏开局：用“启动这个游戏”“打开黑屏”还原第一次实际运行和修复。
4. 一口气加码：Wing 治理、Codex 素材、多样敌人、蓄力和大招。
5. 推翻重画：把小型战机全部改成更大的拟人角色。
6. 从打靶到弹幕：补敌人射击、升级 HUD、修正状态显示和说明不足。
7. 魂系化：Boss 登场横幅、暗角、二阶段、`YOU DIED` 与 `GREAT FOE VANQUISHED`。
8. 音频与收尾：MiniMax BGM、ElevenLabs 音效、API 生成失败与重试、“还没好吗”、自动游玩录像、提交发布。
9. 账单复盘：列出 token 用量、API 等价成本和会员实际扣费说明，以一句自然结论收束。

## 视觉素材

素材必须来自真实游戏、真实会话或原始代码，不生成无信息量的装饰插画。

- 博客封面：16:9，使用 Boss 战、玩家弹幕和标题排版合成。
- 公众号封面：2.35:1，与博客封面同一视觉语言。
- 完整视频：保留 44.4 秒有声 MP4，博客和公众号正文都直接展示，不做跨平台导流。
- GIF 1：普通战斗与升级。
- GIF 2：Boss 登场横幅。
- GIF 3：大招白屏爆发。
- GIF 4：Boss 二阶段弹幕。
- GIF 5：击败 Boss 与胜利字幕。
- 静态图：初版战机与最终拟人角色对比、黑屏证据、角色素材全家福、HUD、Boss 登场、二阶段、胜利画面、视频巡屏图。

目标为至少 5 个 GIF 和 8 张静态图；每章至少一项视觉证据。GIF 在保持可读的前提下控制尺寸，优先适配微信公众号上传。

## 文件输出

- `blog/sky-striker-kimi-78-yuan.md`：中文博客源稿。
- `blog/sky-striker-kimi-78-yuan.weixin.md`：微信公众号版本。
- `blog/assets/sky-striker-kimi-78-yuan/`：封面、GIF、静态图和完整视频。
- `work/sky-striker-kimi-78-yuan-publish/`：发布草稿、媒体映射、终稿与发布脚本/记录。

## 发布设计

### 博客

沿用现有 `blogctl` 发布包模式：上传封面、图片、GIF 和 MP4，替换本地媒体路径，创建并发布博客文章，随后回填 `post_id`、`published_url` 和线上媒体 URL。

### 微信公众号

使用仓库保存的 `wechatsync` 技能与本机 `@wechatsync/cli`，同步 `.weixin.md` 到 `weixin`，创建完整草稿而非群发。

WechatSync 负责标题、正文、封面、图片和 GIF。由于当前 CLI 文档只声明图片自动上传，若本地 MP4 未被自动转为公众号原生视频，则在同一草稿中通过公众号素材库插入完整视频；最终草稿不得包含博客导流文案。

## 校验与完成标准

- 所有关于提示词、消息数、模型、token、金额、时间和项目功能的表述均能由本地记录或项目文件验证。
- 不公开 API key、Token、Cookie、会员凭据或本机会话中的无关隐私。
- 图片、GIF、MP4 均可正常打开；GIF 无明显跳帧，MP4 保留声音。
- Markdown 中不存在未解析占位符和失效本地路径。
- 博客发布成功并可访问。
- 微信公众号草稿创建成功，封面、正文、GIF 和完整视频齐全；不执行群发。
- 发布前后不改动工作区已有的无关文件。
