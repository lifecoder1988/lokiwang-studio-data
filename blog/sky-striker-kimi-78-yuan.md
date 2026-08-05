---
title: 花了 78 元，说了 14 句话，我用 Kimi 做了一款魂系飞行射击游戏
slug: sky-striker-kimi-78-yuan
date: 2026-08-05
tags: [kimi, kimi-code, godot, game-dev, codex]
status: published
published_url: https://lokiwang.com/journal/sky-striker-kimi-78-yuan
post_id: 211
cover: /api/media/uploads/2026/08/1785925605389-cover.png
---

# 花了 78 元，说了 14 句话，我用 Kimi 做了一款魂系飞行射击游戏

这 **14 条创作消息**不是全在 Kimi Code 里：第一条是外部 Kimi Agent 创建提示，后面 13 条才是 Kimi Code 主会话人类消息，截止「commit && push」。子代理指令和后来的网络重试都不算。

按 Kimi K3 API 标价折算约 **78 元**；但我是会员，这是 **API 等价成本**，不是额外扣款。

先看 44.4 秒成片：升级、Boss、大招、二阶段，直到胜利……

<video src="/api/media/uploads/2026/08/1785925663870-gameplay-full.mp4" controls playsinline></video>

## 01 第一版，打开就是黑屏

第一句话：「使用godot4 开发一款飞行射击游戏」。然后「启动这个游戏」。

然后……黑屏。

我只发了截图和一句：「打开黑屏」。修完，屏幕终于有东西能动……

![黑屏修复后的升级段落](/api/media/uploads/2026/08/1785925623811-still-levelup.jpg)

## 02 我把 Wing 和 Codex 都塞了进来

接着我要求用 Wing CLI 治理、迁移 skill、用 Codex 生成素材；敌人有多种行动，玩家能蓄力和放大招。

最终有五种敌机：`drone`、`weaver`、`gunner`、`dasher`、`tank`；玩家有 X 蓄力弹、C 大招和三级武器。

![初版与最终拟人版](/api/media/uploads/2026/08/1785925618727-sprites-before-after.png)

## 03 「飞行单位形象拟人化，更大一些」

初版都是几何飞行器。我要求：「飞行单位形象拟人化  更大一些」。最终玩家和六类敌人都有了人形。

我紧接着问：「敌方单位不会发射子弹吗」。敌人这才从移动靶变成会还手的单位。

![升级与弹幕](/api/media/uploads/2026/08/1785925640827-gif-gameplay-levelup.gif)

## 04 HUD 不能只负责好看

下一轮：HUD 换素材、加经验条、C 大招更华丽。

但状态条一直满着。我又补了一句：「hud 状态不对 一直是满的 。 然后也缺少一些说明  不直观」。

最终能量、经验和 Boss 血条都能反馈真实状态。

![C 大招](/api/media/uploads/2026/08/1785925650779-gif-ultimate.gif)

## 05 一句话，把它拽进魂系

中午 12 点 44 分，我突然说：「把这个游戏搞的更 魂系一些」。

Boss 随即有了登场、二阶段和弹幕；代码里也出现了 `YOU DIED` 与 `GREAT FOE VANQUISHED`……

![Boss 登场](/api/media/uploads/2026/08/1785925636169-gif-boss-entrance.gif)

![二阶段](/api/media/uploads/2026/08/1785925646668-gif-phase-two.gif)

![GREAT FOE VANQUISHED](/api/media/uploads/2026/08/1785925656067-gif-victory.gif)

## 06 音乐、音效，以及那句「还没好吗」

下午我问：「音效 背景音乐都有了吗」。我说明 BGM 用 MiniMax、音效用 ElevenLabs 生成。最终有三首 BGM 和多组音效。

服务来源是我的会话说明；本地文件只能证明音频存在。

随后一条 prompt：

> 「还没好吗」

……催进度也是产品能力。

![二阶段画面，对应项目中的二阶段音效](/api/media/uploads/2026/08/1785925626386-still-phase-two.jpg)

## 07 录视频，算账，提交

15 点 07 分，我让它录视频。成片是 540×960、30fps、H.264 + AAC；15 点 18 分，最后一句：「commit && push」。

提交 `ec93820`：127 个文件，6,028 行新增。

![录制成片中的最终 Boss 阶段](/api/media/uploads/2026/08/1785925630922-still-victory.jpg)

账按证据截止点计算：

| 项目 | Tokens | 单价（USD / 1M tokens） | 金额（USD） |
| --- | ---: | ---: | ---: |
| 未命中缓存输入 | 519,200 | 3.00 | 1.5576 |
| 命中缓存输入 | 26,259,007 | 0.30 | 7.8777021 |
| 输出 | 134,285 | 15.00 | 2.014275 |
| **小计** | — | — | **11.4495771** |

按汇率 **USD/CNY = 6.77**，`11.4495771 × 6.77 = 77.513637967`，约 **78 元**。

这是 API 等价成本，不是会员会话额外支付的账单。

最初那句只给了方向。真正把它推到能看的，是后面的抱怨：**黑屏、敌人怎么不打人、HUD 一直满、还没好吗……**

规格负责开局，抱怨负责把游戏做完。

◇ ◆ ◇

<https://platform.kimi.com/docs/pricing/chat-k3>

<https://www.xe.com/currencycharts/?from=USD&to=CNY>
