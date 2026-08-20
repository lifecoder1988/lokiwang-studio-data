# ai-playgames 创作记录发布包

## 发布状态（2026-08-04）

- Blog 已发布：post_id `208`，https://lokiwang.com/journal/kimi-llm-price-calculator
- 10 张正文图片/GIF 与封面已上传，映射见 `media-map.txt`
- 微信公众号草稿已生成：appmsgid `100000514`，10 张正文图片/GIF 全部上传成功，待后台检查并群发
- 草稿编辑：https://mp.weixin.qq.com/cgi-bin/appmsg?t=media/appmsg_edit&action=edit&type=77&appmsgid=100000514&token=504879063&lang=zh_CN

- 中文 blog 源稿：`blog/kimi-llm-price-calculator.md`
- 微信公众号源稿：`blog/kimi-llm-price-calculator.weixin.md`
- 实机素材：`blog/assets/ai-playgames-price-calculator/`（10 张正文图/GIF + 2 张封面）
- `capture.mjs`：连接本地 `http://localhost:3000`，用 Chrome DevTools 重拍桌面、手机、暗色模式和 GIF 帧
- `publish.sh`：上传媒体并发布到 `lokiwang.com`

微信公众号同步依赖 WechatSync Chrome 扩展保持连接：

```bash
set -a; source .env; set +a
yes n | wechatsync sync blog/kimi-llm-price-calculator.weixin.md -p weixin \
  --cover blog/assets/ai-playgames-price-calculator/cover-mp.png
```
