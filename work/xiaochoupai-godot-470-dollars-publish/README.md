# xiaochoupai-godot-470-dollars 发布包(待执行,凭据不在本机)

《470 刀，Claude 手搓了个五行八仙牌局 Roguelike，最后揪出了自己藏得最深的 bug》
——xiaochoupai 项目开发记(Godot 4.7 + GDScript 的牌型构筑 Roguelike《八仙过海:天道牌局》,
两天从 1870 行 PRD 到能通关的可玩版本,$469.86 by cccost)。
重点:它给自己立了 H1–H8 机器校验的硬约束 + 417 测试,再用自写的 balance_check.py 揪出了
**自己藏了两遍、还互相掩护的血量 bug**(护甲减两次 + margin_ratio 镜像错位相互抵消);
以及「内容不可达」自查(太极图只影响 2.5% 手牌 → 加四行轮转到 50.8%;龙王 phase_3 见不到)。

**本次与拍电影那期相反:全程一个主循环,没有用任何 subagent。**

## 文件

- `draft.md` — 博客发布模板(**中文**,取自 `blog/xiaochoupai-godot-470-dollars.md`;
  视频用 `{{V:gameplay}}` 占位,脚本替换为上传后 URL 并配 poster 帧)
- `publish.sh` — 一键:上传 6 图 + 2 GIF + 1 视频 → 生成终稿 → 建草稿 → 发布(标题内联)
- 中文源:`blog/xiaochoupai-godot-470-dollars.md`(source of truth)
  公众号:`blog/xiaochoupai-godot-470-dollars.weixin.md`

> 注:本包博客正文按用户要求走**中文**(作者本人口吻)。之前 post 178/184/193 线上博客为英文版;
> 若要沿用英文惯例,补一份 `blog/_en/xiaochoupai-godot-470-dollars.md` + `.title.txt`,
> 并把 publish.sh 的 `TITLE`/`--content-file`/`draft` 指向英文即可。

## 博客发布(lokiwang.com)

```bash
cd work/xiaochoupai-godot-470-dollars-publish
# 1) 写入后台凭据(不要提交 git)
cat > .blogenv <<'EOF'
BLOG_ADMIN_USER=xxx
BLOG_ADMIN_PASS=yyy
EOF
# 2) 一键执行
bash publish.sh
```

- 依赖 blogctl 二进制:`/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl`
- 成片是可玩游戏(视频/GIF 成品),不建作品条目
- 发布成功后按 publish.sh 尾部提示收尾:回填中文 `.md` frontmatter、正文媒体换 `/api/media` URL

## 公众号发布(中文,草稿)

```bash
cd /Users/joe/code/lokiwang-studio-data/blog
export WECHATSYNC_TOKEN=$WECHATSYNC_CLI_TOKEN   # CLI 认这个变量名
wechatsync sync xiaochoupai-godot-470-dollars.weixin.md -p weixin \
  --cover assets/xiaochoupai-godot-470-dollars/cover-mp.png
```

- 需要 Chrome 开着 + wechatsync 扩展常驻已登录「有点东西的老王」;产出**草稿**,群发在 mp.weixin.qq.com 手动操作
- 视频在公众号版里已换成「完整视频在博客原文」提示;两张 GIF 保留

## 素材清单(blog/assets/xiaochoupai-godot-470-dollars/)

- 封面 2 张:`cover.png`(博客 16:9,启动页)、`cover-mp.png`(公众号 2.35:1 裁切)
- 正文图 6 张:`shot-hero`(择本命仙) `shot-ledger`(结算账本人话化) `shot-map`(东海节点图)
  `shot-shop`(蓬莱货栈) `shot-battle`(战斗界面) `shot-title`(启动页/备用) + poster 1 张
- GIF 2 张:`gif-play.gif`(两仪阵结成一道金光 6.1MB)、`gif-chain.gif`(五行相生相克实时结算 5.2MB)
- 视频 1 条:`gameplay.mp4`(72s,由 38MB 重编码到 8.9MB / 720p)
- 全部素材从项目 `.shots/`(引擎真实截图)与 `.probe/gameplay.mp4`(引擎实录)抠取转码

## 成本口径(cccost)

扫 `~/.claude/projects/-Users-joe-code-xiaochoupai/**/*.jsonl`,按 (message.id, requestId) 去重,
本次 100% 为 1 小时缓存写(2x)。官方 2026-07 定价:fable-5 $10/$50(缓存写 5m $12.5 / 1h $20、读 $1),
opus-5 $5/$25(写 5m $6.25 / 1h $10、读 $0.5)。
Fable 5 $264.59 + Opus 5 $205.27 = **$469.86**(无 subagent)。
(注:ccusage 对 fable-5 给出同样的 $264.59,验证口径;opus-5 因太新 ccusage 无价,按上表手算。)
