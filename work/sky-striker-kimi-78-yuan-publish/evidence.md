# 《Kimi 做出 Sky Striker，成本约 78 元》证据台账

本台账为文章撰写保留可复核的创作证据；它区分用户要求、Kimi Code 会话记录、Git 提交和成片元数据。除已列明的推论外，不把提示词或代码记录当作独立证明。

## 范围与来源

- **作品目录：** `/Users/joe/code/sky_striker/`
- **会话记录：** Kimi Code `main/wire.jsonl`、`agent-0/wire.jsonl` 与用户历史 `40e681dc77bcc4e4ab754a41d87255c1.jsonl`。
- **证据截止：** 2026-08-05 15:18:40 CST，即用户发出 `commit && push` 的主会话事件。随后 16:50:03 CST 的“再试试 网切换了”只是在重试网络推送，发生在本作品与文章证据截止之后，故不计入 14 条创作消息，也不用于成本口径。
- **时间换算：** 下列带时间的消息均由 wire 事件毫秒值按 `Asia/Shanghai` 转为本地 CST；Kimi Agent 下载导出标题没有对应 wire 毫秒事件，因此明确标为“导出标题，无 wire 时间”。
- **敏感信息：** 本文件不记录任何 API key、同步 token 或其他凭据值。

## 创作消息时间线（14 条）

为保留原文的换行、空格和标点，消息正文使用 `text` 代码块，不作改写。

**1. 导出标题，无 wire 时间；Kimi Agent 下载导出**

```text
使用godot4 开发一款飞行射击游戏
```

**2. 2026-08-05 10:49:36 CST；Kimi Code 主会话**

```text
启动这个游戏
```

**3. 2026-08-05 10:51:24 CST；Kimi Code 主会话**

```text
打开黑屏 [image #1 (540×1016)]
```

**4. 2026-08-05 10:54:39 CST；Kimi Code 主会话**

```text
1. 使用wing cli治理本项目，写到agent.md
2. skill 参考 ../xinglugu-demo/ ， 搬到本项目中来  3. 使用codex生成游戏素材 4. 敌方单位有各种功能方式 5. 我方单位支持 充能和放大招
```

**5. 2026-08-05 12:02:12 CST；Kimi Code 主会话**

```text
飞行单位形象拟人化  更大一些
```

**6. 2026-08-05 12:15:52 CST；Kimi Code 主会话**

```text
敌方单位不会发射子弹吗
```

**7. 2026-08-05 12:19:35 CST；Kimi Code 主会话**

```text
1. hud 升级成 游戏素材 包括经验条  2. c大招 效果要更华丽一些
```

**8. 2026-08-05 12:37:42 CST；Kimi Code 主会话**

```text
hud 状态不对 一直是满的 。 然后也缺少一些说明  不直观
```

**9. 2026-08-05 12:44:52 CST；Kimi Code 主会话**

```text
把这个游戏搞的更 魂系一些
```

**10. 2026-08-05 14:24:48 CST；Kimi Code 主会话**

```text
音效 背景音乐都有了吗
```

**11. 2026-08-05 14:30:11 CST；Kimi Code 主会话**

```text
bgm 是 minimax 生成的 ， 音效是 elevenlab生成的  key 在 code 目录下 找找 .env 里
```

**12. 2026-08-05 14:47:58 CST；Kimi Code 主会话**

```text
还没好吗
```

**13. 2026-08-05 15:07:18 CST；Kimi Code 主会话**

```text
帮我录制一下游戏视频，我后面放到公众号去
```

**14. 2026-08-05 15:18:40 CST；Kimi Code 主会话**

```text
commit && push
```

说明：#2–#14 对应用户历史的第 1–13 行；`agent-0` 中的内容是 Kimi 生成的子代理工作指令，不属于人类创作消息，未计入。

## Token 与成本计算

以下是本次文章采用的**已核验、截止口径**。计价单位均为 1,000,000 tokens；不要用全量 wire 日志直接重算，因为其中还含截止点以外的运行/重试记录。

**成本性质：** ¥78 是把本次 token 用量按 Kimi K3 API 标价换算出的 **API-equivalent cost（API 等价成本）**，用于说明同等 API 调用的价格；本次 Kimi Code 为会员使用，**没有产生与这笔 API 等价成本相同的额外扣费**。因此，¥78 不是本次会员会话的额外实际支付金额。

```text
uncached input = 519,200 × $3 / 1,000,000 = $1.5576
cached input   = 26,259,007 × $0.30 / 1,000,000 = $7.8777021
output         = 134,285 × $15 / 1,000,000 = $2.014275
total          = $11.4495771
RMB            = $11.4495771 × 6.77 = ¥77.513637967 ≈ ¥78
```

| 项目 | Tokens | 单价（USD / 1M tokens） | 金额（USD） |
| --- | ---: | ---: | ---: |
| 未命中缓存输入 | 519,200 | 3.00 | 1.5576 |
| 命中缓存输入 | 26,259,007 | 0.30 | 7.8777021 |
| 输出 | 134,285 | 15.00 | 2.014275 |
| 合计 | — | — | 11.4495771 |

- **Kimi 官方计价页：** <https://platform.kimi.com/docs/pricing/chat>；模型计价页：<https://platform.kimi.com/docs/pricing/chat-k3>（2026-08-05 访问的官方 URL）。
- **换汇来源：** <https://www.xe.com/currencycharts/?from=USD&to=CNY>。文章计算在 2026-08-05 采用 USD/CNY = 6.77 的四舍五入工作汇率；这不是实际支付账单或含手续费的结算汇率。

## 项目可复核事实

### Git 提交

- `HEAD`：`ec93820fb6dd065f4268467c1d5606deb67b8f2b`
- 提交时间：2026-08-05 15:21:09 CST
- 提交主题：`Sky Striker: 魂系纵版射击游戏完整版`
- `git show --stat --summary HEAD`：127 files changed，6,028 insertions。

### 实现中可见的玩法与素材

以下均可由该提交内的 Godot 源码/资产路径核对：

- Godot 纵向卷轴射击，窗口为 540×960；主场景为 `scenes/main.tscn`。
- 敌机有 `drone`、`weaver`、`gunner`、`dasher`、`tank` 五种类型；Boss 有二阶段处理。
- 玩家实现了 X 蓄力弹与 C 大招、能量/经验 HUD、最高三级武器；`--demo` 启用自动演示模式。
- 项目含三首 BGM（`bgm_menu.mp3`、`bgm_battle.mp3`、`bgm_boss.mp3`）和包括蓄力、大招、二阶段、死亡在内的音效文件。消息 #11 是“BGM 为 MiniMax、音效为 ElevenLabs”的用户陈述；本地文件可证实其存在，但不能单凭文件内容独立验证生成服务来源。
- `scripts/main.gd` 含 `YOU DIED` 与 `GREAT FOE VANQUISHED` 结算文本。

### 视频与媒体时间戳

| 媒体 | 本地修改时间（CST） | 大小/元数据 |
| --- | --- | --- |
| `sky_striker_demo.mp4` | 2026-08-05 15:17:21 | 8,339,387 bytes；见下方 ffprobe |
| `assets/audio/bgm/bgm_menu.mp3` | 2026-08-05 14:38:34 | 4,152,325 bytes |
| `assets/audio/bgm/bgm_battle.mp3` | 2026-08-05 14:40:53 | 3,087,136 bytes |
| `assets/audio/bgm/bgm_boss.mp3` | 2026-08-05 14:51:11 | 4,360,676 bytes |

`ffprobe` 对成片返回：44.400000 秒、H.264 视频 + AAC 音频、540×960、30/1 fps、8,339,387 bytes。

## 复核命令

```bash
git -C /Users/joe/code/sky_striker show --stat --summary HEAD
ffprobe -v error -show_entries format=duration,size:stream=codec_name,width,height,avg_frame_rate -of json /Users/joe/code/sky_striker/sky_striker_demo.mp4
```

凭据扫描使用任务简报规定的正则命令执行；命令原样不写入本台账，避免扫描工具把自身模式误报为匹配内容。
