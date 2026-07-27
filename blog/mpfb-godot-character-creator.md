---
title: 16 句话 4 小时，Codex 手搓了个 3D 捏人器，最难的是让衣服跟上身材
slug: mpfb-godot-character-creator
date: 2026-07-27
tags: [codex, godot, blender, mpfb, makehuman, blend-shape, game-dev]
status: published
published_url: https://lokiwang.com/journal/mpfb-godot-character-creator
post_id: 196
cover: /api/media/uploads/2026/07/1785153877740-cover.png
---

# 16 句话 4 小时，Codex 手搓了个 3D 捏人器，最难的是让衣服跟上身材

前几期都是 Claude 手搓游戏。这回换个工具，也换个活——**捏人**。

起点是我对着一个开源项目问的一句话：

> 这个项目怎么跑起来 我想看到 人的3d model

4 小时 36 分、16 句话之后，我得到了这个：

<video src="/api/media/uploads/2026/07/1785153945430-promo-full.mp4" controls playsinline preload="metadata" poster="/api/media/uploads/2026/07/1785153880900-promo-poster.jpg" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

先声明两件事：这次干活的不是 Claude，是 **Codex（gpt-5.6，effort high）**；人体和服装来自开源的 MPFB / MakeHuman，系统资产是 CC0，非商业纯折腾。

## 01 起点是一个我压根没跑起来的项目

我 clone 了 MPFB 想看看人体模型长啥样，结果连门都没找到。

它花了 4 分钟替我把源码构建成 Blender 扩展、装进 Blender 5.2、调 API 生了个人体，然后甩给我一张渲染图：**19,158 个顶点，18,486 个面**。

![Blender 里生成的 MPFB 基础人体](/api/media/uploads/2026/07/1785153887775-still-blender-preview.png)

我的下一句话是「怎么进入 MPFB v2.0.17」，它教我把鼠标放进视图、按 `N`……（这句我承认有点丢人）

## 02 转向只花了我一个词

我问：这插件能直接塞进游戏的捏人环节吗？

它说不能——MPFB 跑在 `bpy` 上，玩家电脑里没有 Blender。正确姿势是 Blender 出 morph targets，引擎里调权重。

我回了一个词：

> godot

37 分钟后，第一版原型跑起来了：8 个滑块，12 个 Blend Shape。

![Godot 里第一版捏人原型](/api/media/uploads/2026/07/1785153890829-still-gender.jpg)

## 03 滑块一拉，人就变

原理其实很朴素：一个参数配两个形态，负向一个正向一个（`slim` / `heavy`），Godot 里 `set_blend_shape_value` 实时插值。

![性别滑块连续变化](/api/media/uploads/2026/07/1785153894872-gif-gender.gif)

从女性拉到男性，是连续的，中间任何一帧都能停。

![肌肉与体态](/api/media/uploads/2026/07/1785153898128-still-muscle.jpg)

![身高比例](/api/media/uploads/2026/07/1785153901027-still-height.jpg)

体重、肌肉、身高、肩宽、胯宽、腹部……每一条都是这么来的。

## 04 最卡的一步不是写代码，是下资源

发型、胡须、衣服从哪来？这一段它连撞两堵墙：

- 官方镜像下载速度**只有几 KB/s**
- 改用 MakeHuman 官方 GitHub 的 CC0 仓库，**Git LFS 配额耗尽**

于是它自己动手，从人体拓扑上程序生成了一整套占位资源：3 发型 3 胡须 2 上衣 2 裤子 2 鞋 2 纹身。

最后是我打开浏览器，手动下了个 zip 丢给它。系统资产包一解压：**10 套发型、14 套服装、6 双鞋**。

![真实发型：波波头](/api/media/uploads/2026/07/1785153903716-still-hair.jpg)

![真实 MakeHuman 系统资产：短发 + 工作套装](/api/media/uploads/2026/07/1785153906322-still-worksuit.jpg)

## 05 真实资产进来的第一件事：把人埋了

衣服和头发一导入，尺寸大到糊住整个屏幕。

原因挺阴的：MHCLO 服装文件会引用 MakeHuman 完整基础网格上的**辅助顶点**，而导出脚本为了减面，先把辅助顶点删了、再让衣服贴合——映射失败的资产就保持了原始 OBJ 尺寸。

改法是把顺序整个倒过来：先贴合、先把身体形变传给穿戴物，**最后**才清理辅助几何。

顺带还揪出一个重复位移：人物先被移到地面，MPFB 又把衣服设成人体子节点，位移被算了两次。

## 06 拖不动，和 Magic Mouse 不认滚轮

我说「鼠标点击 拖动 没反应」。

原因是全屏 UI 的 Control 节点把事件先吃了，`_unhandled_input()` 根本收不到。改成全局 `_input()`，再按鼠标 X 坐标判断是不是在人物区。

我又说「mac 鼠标的 缩放 没反应」。Magic Mouse 没有机械滚轮，macOS 把触控表面的滑动发成了 `InputEventPanGesture`：

```gdscript
elif event is InputEventPanGesture and event.position.x > 400.0:
elif event is InputEventMagnifyGesture and event.position.x > 400.0:
```

三种事件全收，普通鼠标、Magic Mouse、触控板才都能缩放。

![360° 环绕查看](/api/media/uploads/2026/07/1785153911231-gif-orbit.gif)

## 07 真正难的那一关：衣服撑破了

这是整天最有意思的一段。

我说「衣服裤子撑破了」，它给所有服装形态加了约 **8 毫米**的法线方向安全间距。

我说「可以单独调整胸部大小吗」，它加了独立形变，同步到人体、三套衣服、胡须和纹身。

我说「胸部最大的时候把衣服有点撑破了」——它去量了一下：**人体最大形变约 9 厘米，衣服只跟了 7.5–8.8 厘米，差 1.3 厘米**。

![胸部形变时服装同步跟随](/api/media/uploads/2026/07/1785153914276-gif-breast-cloth.gif)

它的处理方式我给满分：不是把整套衣服再加厚一圈，而是**只放大服装那一个 `breast_large` 形变**，留出 10–11 厘米余量。

腰、袖子、裤腿一点没动——不然人就穿成米其林了。

## 08 脸和肤色

头宽、下巴、嘴宽、双眼大小，都是同一套机制：

<video src="/api/media/uploads/2026/07/1785153948009-face-morph.mp4" controls playsinline preload="metadata" poster="/api/media/uploads/2026/07/1785153883286-face-morph-poster.jpg" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

肤色是唯一的例外，它没走 Blend Shape，而是在 Godot 里复制一份人体材质，实时改 `StandardMaterial3D.albedo_color`：

![肤色深浅](/api/media/uploads/2026/07/1785153916522-still-skin-light.jpg)

![肤色冷暖](/api/media/uploads/2026/07/1785153918875-still-skin-warm.jpg)

![双眼大小](/api/media/uploads/2026/07/1785153921787-still-eyes.jpg)

![下巴宽度](/api/media/uploads/2026/07/1785153923856-still-chin.jpg)

## 09 换装：14 个网格一起变形

发型、胡须、服装、鞋子、纹身，每个槽位都能实时切换或隐藏。

![发型、胡须、服装、鞋子连续切换](/api/media/uploads/2026/07/1785153926842-gif-outfit.gif)

关键在于**同名同步**：24 个 Blend Shape 名字在人体和 13 件穿戴物上完全一致，改一个参数，14 个网格一起动。

![胡须：络腮胡](/api/media/uploads/2026/07/1785153929293-still-beard.jpg)

![鞋子：运动鞋 / 靴子](/api/media/uploads/2026/07/1785153931459-still-shoes.jpg)

![程序生成的可变形纹身](/api/media/uploads/2026/07/1785153933684-still-tattoo.jpg)

## 10 我让它录个宣传片，它写了个演示模式

我说「帮我录制一个宣传视频。就是使用一下所有滑块」。

它没去录屏。它在项目里加了个 `--promo-demo` 自动演示模式：依次拖完 15 个滑块、自动滚动左侧面板让正在动的滑块始终可见、切完所有装备、转一圈、配中文字幕——然后用 Godot 的 Movie Maker 固定 30 FPS 逐帧渲染：

```bash
godot --path . --write-movie /tmp/promo.avi \
  --fixed-fps 30 --disable-vsync -- --promo-demo
```

![宣传片开场](/api/media/uploads/2026/07/1785153935795-still-title.jpg)

成品 45.97 秒、1280×720、2.9 MB。模型改了随时能一条命令重录——这比录屏值钱多了。

## 11 一天的账面

| 项 | 数 |
| --- | --- |
| 我说的话 | 16 句 |
| 耗时 | 4 小时 36 分 |
| 代码补丁 | 43 次 |
| token | 4892 万输入（4756 万命中缓存）+ 11.8 万输出 |
| 成品代码 | `main.gd` 808 行 + 导出脚本 439 行 |
| 模型 | 24 个 Blend Shape / 14 个可变形网格 / GLB 50 MB |

项目自带 headless 自检，跑一条命令就知道有没有崩：

```text
Morphable meshes: 14
MPFB_CHARACTER_CREATOR_SELF_TEST_OK
```

![360° 背面](/api/media/uploads/2026/07/1785153938536-still-orbit-back.jpg)

## 12 别急着往生产里搬

它自己列的限制比我想说的还诚实：没有骨骼、动作和表情；极端体型组合仍可能需要更精细的修正形变；生产版最好给每套衣服配专用人体遮罩；眼球、眉毛、牙齿还没做成独立槽位；GLB 50 MB，正式项目得压缩 + LOD + 按需加载。

也就是说，今天这个东西是**能演示、能录制、能继续长**的原型，不是能上线的系统。

![创建属于你的 3D 游戏角色](/api/media/uploads/2026/07/1785153940755-still-ending.jpg)

## 13 我最大的收获

一整天下来，AI 在这条链路上唯一真正卡住的地方，是**下载一个 zip**。

网速几 KB/s、LFS 配额耗尽，它绕不过去，就自己搓了套占位资源顶着——直到我打开浏览器点了个下载。

捏人系统难的从来不是滑块，是让衣服跟得上身材；而 AI 缺的也不是写代码的能力，是有人替它把那个 zip 下下来……

◇ ◆ ◇

- MPFB2（Blender 插件）：https://github.com/makehumancommunity/mpfb2
- MakeHuman 官方资产包（CC0）：https://static.makehumancommunity.org/assets/assetpacks.html
- Godot Blend Shape 接口文档：https://docs.godotengine.org/en/stable/classes/class_meshinstance3d.html
