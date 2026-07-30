---
title: 一句话一个站：Kimi 搓出了水果机、A股复盘和网页版微信，最后一个被我一个字搜白屏了
platform: weixin
source: kimi-three-sites
cover: assets/kimi-three-sites/cover-mp.png
---

# 一句话一个站：Kimi 搓出了水果机、A股复盘和网页版微信，最后一个被我一个字搜白屏了

这两周我在拿 **Kimi K3 的 Websites 功能**折腾一件事：不写一行代码，能不能把「想要个网站」直接变成一个能发给朋友的网址。

结果搓出来三个，全都上线了，全都是真后端、真数据库：

![三个站：水果机 / A股每日复盘 / 网页版微信](assets/kimi-three-sites/cover.png)

- 🎰 水果机 —— `banana.kimi.site`
- 📈 A股每日复盘 —— `duwang.kimi.site`
- 💬 网页版微信 —— `chatme.kimi.site`

写完我没急着发朋友圈，而是挨个上去挑刺……最后一个站，我一个字就把它搜白屏了。

（先看效果，坑放在最后一节，别急）

## 01 第一个站，我的需求就一句话

原话：

> 实现水果机，支持用户登录，排行榜

十几分钟后，跑马灯亮了。金色拉丝外框、一圈交替闪的灯泡、深绿丝绒底、24 个格子——**这一版界面不是我提的，是它自己审美发作**。

![幸运水果机的机台界面，游客模式送 1000 积分](assets/kimi-three-sites/banana-idle.jpg)

（右下角那个「Kimi Agent」小徽章，是这三个站唯一的共同点）

## 02 8 种水果、3 档筹码，赔率它自己定的

苹果 ×3、橘子 ×4、柠檬 ×5、铃铛 ×6、西瓜 ×8、葡萄 ×10、香蕉 ×15、BAR ×20。

我数了下格子：24 格里苹果出现 6 次，BAR 只有 1 次——概率和赔率是对得上的，不是随手编的数。

![八种水果各下 50 分，本局下注 400](assets/kimi-three-sites/banana-bets.jpg)

## 03 转盘停在哪，是服务器说了算

我在旁边看它写代码时发现一个挺专业的细节：**停格结果是服务端随机出的**，前端拿到答案后只负责「配合演出」——加速、绕圈、减速，最后精准停在那一格。

![下注 → 转动 → 停格 → 结算](assets/kimi-three-sites/gif-spin.gif)

为啥要绕这一圈？因为结果如果在浏览器里生成，按个 F12 就能改，排行榜当场作废……这个防作弊的思路我自己都没想到。

## 04 中奖那一下，是有彩带雨的

![中得苹果 ×3，+150](assets/kimi-three-sites/banana-win-150.jpg)

![中得柠檬 ×5，+250，彩带落了满屏](assets/kimi-three-sites/banana-win-250.jpg)

它还自己改过一个 bug：第一版里积分在按下「开始」的瞬间就变了——**转盘还在转，答案已经剧透**。它自己测出来，自己把结算挪到停稳之后。

## 05 排行榜的门槛，是我提的那一句

「登录不是必须的，只有上排行榜才需要登录。」

于是游客积分存在浏览器本地，想上榜就登录、把本地积分**一次性并入**云端账户。我随口一问「那我把本地积分改成 999999 呢」——它早堵上了：每个账号只能并入一次，封顶 5 万。

![前三名做成领奖台，冠军头像最大](assets/kimi-three-sites/banana-leaderboard.jpg)

（榜首那个 joewang 是我，990 分……胜之不武）

## 06 手机端是真适配，不是「凑合能看」

底部固定操作栏：积分、本局下注、超大号「开始」，大拇指一伸就够到。下注面板窄屏自动从 8 列变 4 列，连 iPhone 底部小白条的安全区都避开了。

![手机上的下注面板，8 列变 4 列](assets/kimi-three-sites/banana-mobile.jpg)

![手机上转动中](assets/kimi-three-sites/banana-mobile-spin.jpg)

## 07 第二个站：我想要的复盘工具，市面上没有

炒股软件信息太杂，自己拉 Excel 太累。我的需求还是一句话：「生成一个 A 股每日复盘的站点」。

它做的第一件事让我意外——**没急着画页面，先去调了真实行情接口**：六大指数、82 个交易日日线，实时报价 30 秒自己刷一次，实时源挂了自动降级到历史快照。

![六大指数 + 近 30 日迷你走势，红涨绿跌](assets/kimi-three-sites/duwang-cards.jpg)

## 08 「情绪观察」这四块，是算出来的

量能环比、风格分化（科创50 与沪指的剪刀差）、创业板 vs 沪指、近 20 日环境——不是预置文案，是当日数据推出来的。

![情绪观察：量能 +15.35%、风格分化 -5.78pct](assets/kimi-three-sites/duwang-sentiment.jpg)

![主走势图可以切六个指数](assets/kimi-three-sites/duwang-chart-kc50.jpg)

## 09 82 个交易日，随便回看哪天

按一下「前一交易日」，整页所有模块——指数卡片、情绪观察、区间表现——全部按那一天的真实数据重算，走势图上还有一条竖线标你在看哪天。

![一路往回按，整页数据跟着变](assets/kimi-three-sites/gif-days.gif)

![回看 2026-04-07：标题变「历史回看」，多出一个「回到最新」](assets/kimi-three-sites/duwang-history.jpg)

我故意翻到窗口最边上那几天，想看它会不会编数据——它没编：

> 近20日环境 —— 「回看日较早，区间数据不足」
> 焦点个股 —— 「个股明细仅提供最新交易日数据」

**该缺的地方老老实实空着**，比硬凑一个数字让人放心多了。

## 10 复盘笔记存本地，留言存云端

笔记（今日总结 / 明日关注 / 操作记录）只存浏览器本地，自动保存；每个交易日独立的留言区要登录才能发，数据在云端数据库。

![复盘笔记 + 股友留言，边界写得很清楚](assets/kimi-three-sites/duwang-notes.jpg)

![手机上的复盘站](assets/kimi-three-sites/duwang-mobile.jpg)

## 11 第三个站：单聊、群聊、发图，真后端

第三个站最贪心：网页版微信。动手前我先定了三件事——单聊+群聊、文字+表情+图片、账号密码注册（后来又加了 Kimi 一键登录）。

技术栈是它自己选的：React + tRPC + Hono + Drizzle + MySQL，前后端类型全打通。

![登录页：Kimi 一键登录 / 账号密码二选一](assets/kimi-three-sites/chatme-login.jpg)

我注册了俩号（小明、大宝）实测——头像不用上传，用户名哈希出一个固定底色，首字母当头像。

![搜人、发起单聊](assets/kimi-three-sites/chatme-userlist.jpg)

## 12 消息 2 秒一刷，图片自动压到 900px

没上 WebSocket，就是老实轮询，2 秒一次，体感接近实时。

![你一句我一句，接近实时](assets/kimi-three-sites/gif-chat.gif)

我顺手把上面那张水果机中奖图发了过去——图片压到 900px 直接 base64 存字段，省掉一整套对象存储。

![单聊里发图、发表情，Enter 发送](assets/kimi-three-sites/chatme-chat.jpg)

## 13 未读红点，没有「未读表」

它的做法是：每个成员记一个 `lastReadAt`，**未读数 = 比我最后已读时间晚的消息数**。红点是算出来的，不是存出来的。

![红点、群成员数、时间戳](assets/kimi-three-sites/chatme-unread.jpg)

![建群：起名、勾人，群里能看成员列表](assets/kimi-three-sites/chatme-group.jpg)

![手机上的群聊](assets/kimi-three-sites/chatme-mobile.jpg)

## 14 然后，我一个字把它搜白屏了

在「发起单聊」里我手贱打了一个 `d`……

![页面白了，只剩右下角那个 Kimi Agent 徽章还在](assets/kimi-three-sites/chatme-whitescreen.jpg)

控制台一句话：

```
TypeError: Cannot read properties of null (reading 'toLowerCase')
```

我把线上打包好的 JS 扒出来搜了一下，凶手在 `NewChatDialogs.tsx`：

```js
m.filter(v => v.username.toLowerCase().includes(g)
           || v.nickname.toLowerCase().includes(g))
```

问题在于：**用 Kimi 一键登录的人，`username` 是 `null`**。

这恰恰是它最得意的那个设计的代价——「一张用户表，Kimi 用户填 unionId，本地用户填 username + 密码哈希，各填各的互不冲突」。库里躺得挺和谐，前端一 `.toLowerCase()` 就炸。而且同一句还抄了一份到建群弹窗里，两处都会白屏……

（我用 Kimi 登录过，所以这个 null 是我自己埋的雷，绕了一圈把自己送进去了……）

## 15 三个站跑完，我的三点体会

**1. 提需求的能力，比写代码的能力更值钱了。**「只有上排行榜才需要登录」「能看过去某一天吗」——这种产品级的判断是我给的；防作弊、事务、并入封顶、降级方案，是它自己加的。分工挺清楚：我负责要什么，它负责怎么做。

**2. 它知道自己的边界，这点反而让人放心。**我问能不能接微信登录，它直说不行（OAuth 要企业资质和备案域名），没有硬做个假功能糊弄我；区间数据不够就老实空着。

**3. 全栈的门槛真的塌了，但「测」的活还得你自己干。**登录、数据库、排行榜、群聊，一轮对话就有了；而那个白屏，AI 写的时候不会想到、自己也测不出来——因为它测的时候还没有一个 `username` 为 null 的用户。

一句话能起一个站，但让它站得住的那一脚，还得你自己去踹。

◇ ◆ ◇

- 🎰 幸运水果机：https://banana.kimi.site
- 📈 A股每日复盘：https://duwang.kimi.site
- 💬 网页版微信（IM）：https://chatme.kimi.site
- 🛠 生成工具：Kimi K3 · Websites

*A股复盘站的实时行情与日K来自公开行情接口（腾讯财经），历史快照来自 iFinD（同花顺），仅供学习研究，不构成投资建议。水果机是纯积分娱乐，不涉及任何真实货币。*
