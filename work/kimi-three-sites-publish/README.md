# kimi-three-sites 发布记录(2026-07-30 已执行)

**已发布**:post_id=199,https://lokiwang.com/journal/kimi-three-sites(英文终稿);
公众号草稿 appmsgid=100000471(24 张图/GIF 全部上传成功,待后台确认群发)。
媒体 URL 见 `media-map.txt`;`blog/kimi-three-sites.md`(中文源稿)frontmatter 已回填
post_id / published_url / cover,正文图片已换成 `/api/media/uploads/...`;英文终稿存
`blog/_en/199.md`(保留 `{{IMG:name}}` 占位符,重发时由 publish.sh 替换)。

## 素材怎么来的

三个站都是线上可访问的真站点,素材全部是**实机截图/录屏**,不是配图:

- 本机没装 playwright,但 `~/Library/Caches/ms-playwright/chromium-1228/` 里有
  Chrome for Testing;`npm i playwright-core` + `executablePath` 指过去即可驱动。
- 脚本(临时,放在 scratchpad):`banana.js` / `banana2.js`(下注→转动→中奖结算)、
  `duwang.js`(切指数、按 82 个交易日回看、移动端)、`chatme2/5/6.js`(注册小明+大宝
  两个号 → 单聊 → 发图 → 建群 → 未读红点)、`gifs.js`(录 webm)。
- GIF:playwright `recordVideo` 出 webm,ffmpeg `palettegen/paletteuse` 转 GIF。
  `gif-spin` 压到 540px/8fps ≈ 1.5MB(公众号上传 3MB 左右的 GIF 容易单张失败)。

## 文章里那个白屏 bug(实测,可复现)

在 chatme.kimi.site 的「发起单聊」搜索框里输入任意字符 → 整页白屏:

```
TypeError: Cannot read properties of null (reading 'toLowerCase')
```

线上 bundle 里的过滤器(`src/components/chat/NewChatDialogs.tsx:57`,建群弹窗
`:157` 处也抄了一份):

```js
m.filter(v => v.username.toLowerCase().includes(g) || v.nickname.toLowerCase().includes(g))
```

`conversation.list` 返回里,Kimi OAuth 用户是 `{"username":null,"provider":"kimi"}`
——所以只要用户表里有一个 Kimi 登录用户,搜索就必炸。

## 重新发布

```bash
bash work/kimi-three-sites-publish/publish.sh   # 幂等:已上传的媒体按 media-map.txt 跳过
# 公众号(产出草稿,需在后台确认群发):
# 注意两点:1) 必须 set -a 导出,光 source 的话 node 读不到 token,会报
# Invalid or missing token;2) wechatsync 会问「是否打开扩展安装页面?(y/N)」,
# 不喂 stdin 会永久挂住,所以前面接 yes n。
set -a; source .env; set +a
yes n | wechatsync sync blog/kimi-three-sites.weixin.md -p weixin \
  --cover blog/assets/kimi-three-sites/cover-mp.png
```
