# deepseek-token-freedom 发布记录 (2026-08-26)

## 已发布

- 博客: post_id=220, https://lokiwang.com/journal/deepseek-token-freedom (中文终稿)
- 公众号: 草稿已同步, appmsgid=100000607, 4 张图上传成功 (待后台确认群发)
  见 https://mp.weixin.qq.com/cgi-bin/appmsg?t=media/appmsg_edit&action=edit&type=77&appmsgid=100000607

媒体 URL 见 `media-map.txt`;`blog/deepseek-token-freedom.md`(中文源稿)frontmatter 已回填
post_id / published_url / cover,正文图片已换成 `/api/media/uploads/...`。

## 内容调整说明 (相对 /Users/joe/Downloads/0826-文章 原稿)

按用户要求调整 2 点:

1. **新增「降频优化温度」一节** (06 降温之): `nvidia-smi -lgc 2200` 锁频 2200MHz,
   以 Grafana 监控截图 (grafana-temps.png) 佐证温度压在 SOC ~48-50°C / PCIe ~52-53°C,
   decode 卡带宽不卡频率,锁频几乎不掉速。
2. **重写「token 自由」的理由** (01): 由「限流」改为「DeepSeek 涨价 (8/17 峰谷计费,
   V4-Flash 输出高峰 9 元/百万, V4-Pro 27 元, 最高涨幅 1100%) + 本地隐私优先 +
   本地大模型能力上来 (两台 TP=2 可部署 284B 的 DS V4-Flash)」。

全篇按 blog-writing-style (说人话) 重排: 01-08 数字小标题、短句、省略号、括号私货、金句收尾。

## 重新发布

```bash
bash work/deepseek-token-freedom-publish/publish.sh  # 幂等:已上传媒体按 media-map.txt 跳过
# 公众号 (产出草稿):
set -a; source .env; set +a
PATH=/Users/joe/.nvm/versions/node/v22.12.0/bin:$PATH
yes n | wechatsync sync blog/deepseek-token-freedom.weixin.md -p weixin \
  --cover blog/assets/deepseek-token-freedom/rack.png
```
