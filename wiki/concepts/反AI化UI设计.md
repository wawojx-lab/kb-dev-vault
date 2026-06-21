---
title: 反 AI 化 UI 设计（Anti-AI UI Design）
type: concept
source: 'D:\xiangmu\_meta\rules\ui-design.md + subagent 调研 2026-06-21'
created: 2026-06-21
updated: 2026-06-21
confidence: inferred
tags: [UI, 设计, 反AI化, 前端, 设计系统, 字体, 配色, 动效, 图标, 圆角, 布局]
---

# 反 AI 化 UI 设计

> 触发: 任何 agent 输入 "**启动反 AI 化 UI 模式**" / "**按 Vercel 风格**" / "**按 Linear 风格**" / "**按 ui-design 规范**" 即可激活。
> 强制规范: `d:\xiangmu\_meta\rules\ui-design.md` (所有 agent 必读)
> 可触发 prompt: `d:\xiangmu\_meta\templates\prompts\12-anti-ai-ui.prompt.md`
> 用户偏好源: `d:\xiangmu\_kb\wiki\concepts\用户偏好.md` (6 条 UI 禁令)

## 关联图谱 (wikilinks)

- [[马斯克方法论]] — 同样强调"原型就是证明"和"做有用的人"
- [[用户偏好]] — 6 条 UI 禁令的源头 (现有)
- 反 AI 化设计也是"删除胜过优化"的工程应用
- 从"AI 默认"的本质问题出发,而非模仿现有方案

> 注: 部分 wikilink 暂未建对应概念条目, 等需求出现时再补。

## 摘要

反 AI 化 UI 是 2026 年设计趋势的"反 LLM 默认"运动。LLM 在 2024-2025 生成的 UI 有高度可识别的"AI 味": 紫色主色、12-16px 全圆角、ease-in-out 默认缓动、Inter 单独使用、玻璃拟态、emoji 装饰、3D 拟物插图、12 列等宽网格。本文提供 **8 大维度 × 8 条以上建议** 的完整指南, 每条都给出可直接复制的代码。

**核心思想**: 字体非默认、色彩非紫色、节奏非均匀、圆角非全用、动效非匀速、装饰非插画、细节非平庸。

---

## 三个总原则

1. **可被一眼识出"不是模板"**: Linear、Vercel、Stripe、Rauno.me 都有自己专属的字体、专属的灰度、专属的 hover。模仿对象的"小动作"而不是模仿对象的"大色调"。
2. **拒绝"AI 默认"调色板**: Linear 2026 重设计用了**纯白底 + 接近黑 (#171717) 的主文字 + 一个真正亮蓝 (#006bff)** 而不是紫色。
3. **给设计加"手艺感"**: 用 OpenType 替代字形 (`ss01`、`ss02`)、用弹簧物理、用不对称布局、用真实纹理/照片 —— 这些"AI 不擅长"的细节,就是反 AI 化的最高优先。

---

## 一、字体选择 (Typography)

### 1.1 不该用什么 (反"AI 默认")

| 反面 | 为什么 |
| --- | --- |
| `Inter` 单独使用 | 2023-2025 几乎所有 AI 生成 UI 的默认选择, 已变成"无个性"代名词 |
| `Roboto`、`system-ui` 单独使用 | 跟"未做设计"一样, 显得功能化无品牌 |
| `Open Sans`、`Lato`、`Noto Sans` | 大量企业模板默认字体, 辨识度 ≈ 0 |
| 不开启任何 OpenType 特性 | 失去"手画字"的人味儿 |

### 1.2 推荐的"显示字体 + 正文字体"配对

**配对 A — 经典优雅系** (适合 SaaS、Dashboard、文档)
- 显示字体: **Fraunces** (Undercase Type 出的现代 serif, 有"opsz"光学尺寸轴, 小字号也不糊)
- 正文字体: **Geist Sans** (Vercel 自研, 2024 开源, SIL OFL)
- 等宽数字: **Geist Mono** (`font-variant-numeric: tabular-nums;`)

**配对 B — 编辑感/杂志感** (适合博客、内容站、创意团队)
- 显示字体: **IBM Plex Serif**
- 正文字体: **IBM Plex Sans**
- 数字/代码: **IBM Plex Mono**
- 优势: 三套统一, 跨平台一致, 比"Inter + JetBrains"更有工匠味

**配对 C — 极简科技系** (适合 DevTools、CLI、API 产品)
- 显示字体: **Space Grotesk** (2.0 版本, Florian Karsten 2024 更新, 有 `ss01` `ss02` 替代字形)
- 正文字体: **Space Grotesk** 或 **Inter Tight**
- 等宽: **JetBrains Mono** 或 **Geist Mono**

**配对 D — 中文环境友好** (国内团队推荐)
- 西文显示: **Fraunces** 或 **GT America**
- 西文正文: **Geist Sans**
- 中文显示: **思源宋体 (Source Han Serif)** 或 **得意黑 (Smiley Sans)**
- 中文正文: **思源黑体 (Source Han Sans)** 或 **阿里妈妈数黑体**
- 等宽: **JetBrains Mono** + **Sarasa Mono SC** 或 **Maple Mono**

### 1.3 Modular Scale (模块化字号比例, 基于 1.25 minor third)

```css
:root {
  --fs-12: 0.75rem;   /* 12px - 标签、小注 */
  --fs-14: 0.875rem;  /* 14px - 次要正文 */
  --fs-16: 1rem;      /* 16px - 正文, 移动端最小 */
  --fs-18: 1.125rem;  /* 18px - 强调正文 */
  --fs-20: 1.25rem;   /* 20px - H4、小标题 */
  --fs-24: 1.5rem;    /* 24px - H3 */
  --fs-32: 2rem;      /* 32px - H2 */
  --fs-48: 3rem;      /* 48px - H1 */
  --fs-64: 4rem;      /* 64px - Hero */
  --fs-96: 6rem;      /* 96px - Display, 谨慎使用 */
}
```

注意: **移动端最低 16px** (用户偏好硬性要求)

### 1.4 字重、行高、字距细节 (可直接复制)

```css
body {
  font-family: 'Geist Sans', 'PingFang SC', system-ui, sans-serif;
  font-size: 16px;
  line-height: 1.5;          /* 150% 是中性默认值 */
  font-weight: 400;
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
  font-feature-settings: 'kern' 1, 'liga' 1, 'calt' 1, 'ss01' 1, 'ss02' 1, 'cv11' 1;
}

/* 标题: 收紧字距 -2% 到 -5%, 行高 1.0-1.1 */
h1 {
  font-size: clamp(2.5rem, 4vw + 1rem, 4rem); /* 40-64px 流体 */
  font-weight: 600;
  line-height: 1.05;
  letter-spacing: -0.035em;
}

/* 数字等宽 */
.stat {
  font-family: 'Geist Mono', 'JetBrains Mono', monospace;
  font-variant-numeric: tabular-nums slashed-zero;
}
```

### 1.5 10 条具体建议

1. **至少引入一个显示字体与正文字体形成对比** (serif + sans 是最稳的搭配)。
2. **永远开启 `font-feature-settings`**: 至少 `'kern' 1, 'liga' 1`, 进阶加 `'ss01', 'ss02', 'cv11', 'tnum'`。
3. **数字必须等宽** (`font-variant-numeric: tabular-nums`), 否则 ¥1,234.50 和 ¥67.80 对不齐直接露怯。
4. **Hero 标题用 `clamp()` 流体字号**, 不要写死 `font-size: 64px`。
5. **标题字距收紧** (`-0.02em` 到 `-0.04em`), 正文字距自然 (`0`)。
6. **字重不要用 300**, 用 400 / 500 / 600 三档足够。
7. **中英文混排**用 stack 兜底: `'Geist Sans', 'PingFang SC', 'Microsoft YaHei', sans-serif`。
8. **行高不要统一**: 中文 1.6-1.75、西文 1.4-1.5、代码 1.5-1.6、标题 1.05-1.15。
9. **不要 fallback 到 emoji 字体**: 在 `font-family` 列表里**移除** `'Apple Color Emoji'`。
10. **可变字体优先**: Geist Sans、Inter Display、Fraunces、Space Grotesk 都有 `wght` + `opsz` 双轴。

---

## 二、配色系统 (Color)

### 2.1 不该用什么 (反"AI 默认")

| 反面 | 为什么 |
| --- | --- |
| 紫色主色 (`#8b5cf6`、`#a855f7`、`#7c3aed`) | Tailwind 默认 purple-500/600 是 2024-2025 LLM 生成 UI 排名第一的"AI 味"信号 |
| 多色渐变 (`from-purple-500 via-pink-500 to-orange-400`) | 几乎 = "AI 写的" |
| 极暗背景 + 紫色光晕 | 玻璃拟态 + 紫光 = 双重 AI 标志 |
| 饱和度过高的纯色 | 像"广告页"而不是"产品页" |

### 2.2 推荐的 3 套具体调色板 (可直接落地)

#### 调色板 A — "Vercel 极简" (浅色为主、科技感)

```css
:root {
  --gray-100: #f2f2f2;
  --gray-300: #e6e6e6;
  --gray-500: #c9c9c9;
  --gray-700: #8f8f8f;
  --gray-900: #4d4d4d;
  --gray-1000: #171717;  /* 主文字 */
  --bg-100: #ffffff;
  --bg-200: #fafafa;
  --blue-500: #94ccff;
  --blue-700: #006bff;  /* 主操作色 */
  --blue-900: #005ff2;
  --red-700:  #fc0035;  /* 错误/危险 */
  --green-700: #28a948; /* 成功 */
  --amber-700: #ffae00; /* 警告 */
}
```

#### 调色板 B — "Stripe 编辑感" (米白底、深紫蓝、橙黄强调)

```css
:root {
  --bg: #f6f9fc;
  --surface: #ffffff;
  --ink: #0a2540;
  --ink-soft: #425466;
  --border: #e6ebf1;
  --brand: #635bff;       /* Stripe 紫蓝(专利色) */
  --brand-soft: #ebe9ff;
  --accent: #ff5996;
  --positive: #00875a;
  --warning: #ffb800;
  --negative: #e25950;
}
```

#### 调色板 C — "Swiss 大地" (暖色系, 反 AI 冷淡感)

```css
:root {
  --bg: #f4f1ed;        /* 沙米色背景 */
  --ink: #1a1a1a;        /* 接近黑, 不用纯黑 */
  --paper: #ffffff;
  --terracotta: #c2410c; /* 主色: 陶土橙 */
  --olive: #4d5a3a;      /* 强调色: 橄榄绿 */
  --mustard: #d4a017;    /* 第三色: 芥末黄 */
  --border: #d6d0c4;
}
```

### 2.3 OKLCH 调色法 (2025-2026 新趋势)

```css
:root {
  --blue-700: oklch(57.61% 0.2508 258.23);  /* P3 真彩 */
  --blue-700-fallback: #006bff;
}
```

### 2.4 10 条具体建议

1. **主色用真蓝、暖橙、墨绿、酒红, 避开紫色** —— 尤其避开 `#8b5cf6`。
2. **背景用 `#fafafa` 而非纯白** —— Vercel 2024 后全站用 `background-200: #fafafa`。
3. **主文字用 `#171717` 而非 `#000000`** —— 纯黑在白底上对比度过强反而刺眼。
4. **灰阶建 9-10 档**, 中间均匀分布, 不要"50、100、200、400、800"乱跳。
5. **强调色限 1-2 个**, 辅助色限 3-4 个。
6. **灰阶用中性灰** (red=green=blue), 不要冷灰/暖灰。
7. **别在主色上做透明叠加** (`rgba(0,107,255,0.5)`) —— P3 屏上会算错。
8. **用 CSS `color-mix` 而不是 `rgba`**:
   ```css
   .btn-hover { background: color-mix(in oklch, var(--blue-700) 90%, black); }
   ```
9. **不要给 disabled 状态用纯灰** —— 改用 `color-mix(in oklch, var(--ink) 30%, transparent)`。
10. **品牌色确定后做 10 阶**: `brand-50` 到 `brand-950`, 用 `oklch` 调亮度而非混黑/混白。

---

## 三、布局与节奏 (Layout & Rhythm)

### 3.1 不该用什么

- 死板的 12 列 grid、全部内容等宽居中
- 所有卡片 `display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;`
- 所有 section 都是 `padding: 80px 0`、所有 h1 居中、所有图片 `aspect-ratio: 16/9`
- 元素全部"装进圆角容器内"、相互之间没有张力

### 3.2 8px 基础单位 + Modular Scale

```css
:root {
  --space-0: 0;
  --space-1: 4px;
  --space-2: 8px;   /* 基础 */
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;
  --space-12: 48px;
  --space-16: 64px;
  --space-24: 96px; /* section 之间 */
  --space-32: 128px;/* 大 section */
}
```

### 3.3 不对称布局 + Grid Breaking

```css
.page {
  display: grid;
  grid-template-columns: repeat(16, 1fr);
  gap: 24px;
  max-width: 1440px;
  margin: 0 auto;
  padding: 0 32px;
}

.hero-title  { grid-column: 1 / 9; }   /* 文字占左半 50% */
.hero-visual { grid-column: 10 / 17; margin-right: -64px; } /* 视觉故意"出血" */
```

### 3.4 10 条具体建议

1. **基础单位用 4px 或 8px**, 所有间距 = `n × base`。
2. **不要用 12 列 grid** —— 12 是 Bootstrap/Tailwind 默认, 2025 后已显"模板"。改用 16 列或不对称的 `repeat(4, 1fr) + 2× 200px sidebar`。
3. **关键 hero 故意"出血"**: 把图片 margin 设负值 (例如 `margin-right: -80px`)。
4. **不要全部居中** —— 标题左对齐 + 段落窄栏 (60-72ch 宽) + 视觉右对齐, 形成节奏。
5. **至少有一处"违反节奏"**: 某个 h1 故意比相邻标题大 2 倍、某个段落 margin 故意打破 step 整数倍。
6. **行宽 60-75 字符** (`max-width: 65ch;`)。
7. **Section padding 用 96-160px** 范围 (不是 80/120 这种"模板数")。
8. **首屏只有一个真正突出的视觉**, 其他全部降级。
9. **用 CSS Grid 显式列宽** 比 auto-fit 网格更有控制感。
10. **卡片不用 `repeat(3, 1fr)` 全部等宽** —— 让首卡 2 倍宽, 或者宽度按 1:1.618 比例递增。

---

## 四、圆角与形状 (Radius & Shape)

### 4.1 不该用什么

| 反面 | AI 味 |
| --- | --- |
| 所有元素 `rounded-xl` (12px) 或 `rounded-2xl` (16px) | **中-高** (Figma/Framer 模板师戏称"Shadcn 病") |
| 头像/avatar 全用 `rounded-full` | 头像圆是 OK 的, 但所有小元素都圆就显得"糖果" |
| 按钮 `border-radius: 9999px` (药丸形) | 几乎所有"AI 工具"按钮都是药丸 |
| 卡片四圆角完全相同 | 缺乏个性 |

### 4.2 推荐的"反 AI"圆角策略

**策略 A — 锐利 2-4px (瑞士 / 工业 / 编辑)**
```css
--radius-default: 4px;
--radius-button: 6px;
--radius-card: 8px;
--radius-modal: 12px;
```

**策略 B — 全部 0 (纯硬朗)** (CLI、Terminal 风)

**策略 C — 大圆角 24-32px (反差萌)** —— 适合消费、社交、儿童类产品
注意: 必须**只对一种元素**用大圆角 (例如只用按钮 24px, 卡片 0px)

**策略 D — 混合 (成熟设计师手法)**
```css
--radius-sm: 4px;
--radius-md: 8px;
--radius-lg: 0;       /* 主容器 0 */
--radius-pill: 9999px; /* 仅标签和小 chip */
```

### 4.3 用形状破单调

```css
/* 斜切: clip-path 实现"切角" */
.clip-corner {
  clip-path: polygon(0 16px, 16px 0, 100% 0, 100% calc(100% - 16px), calc(100% - 16px) 100%, 0 100%);
}

/* 异形 border-radius (每角不同) */
.asymmetric-card {
  border-radius: 4px 24px 4px 24px;
}
```

### 4.4 10 条具体建议

1. **主按钮 radius 不要 12-16px** —— AI 最高频坑; 改 4px (锐利) 或 24-32px (反差)。
2. **主卡片用 0-8px**, 不要 12-16px。
3. **如果用大圆角 (24-32px), 只用在一种元素**, 其他地方都小, 形成对比。
4. **头像用 full 圆 OK**, 但**不要**所有小图标按钮都 full 圆。
5. **至少一个元素用斜切 clip-path** —— 给品牌增加"手艺感"。
6. **input border-radius 比按钮小 2-4px** —— 视觉上更"内嵌"。
7. **不要"全圆角家族"** —— 同一页出现 3 种不同 radius 比统一 radius 更高级。
8. **按钮 hover 时 radius 不变** (transform 或 shadow 变化), 避免在交互时"抖"。
9. **modal 用 12-16px OK**, 因为它本身需要"软"。
10. **Figma 2025 Trends** 报告已明确指出"过度使用 rounded-xl"是 GenAI 输出的标志。

---

## 五、动效 (Motion)

### 5.1 不该用什么

| 反面 | 改法 |
| --- | --- |
| `transition: all 0.3s ease` 或 `transition-timing-function: ease-in-out` | 自定义 cubic-bezier |
| 200-300ms 居中过渡 | 根据元素类型定 (150-1200ms) |
| 直线匀速动画 | 用弹簧或自定义曲线 |
| 弹出/淡入用 `opacity: 0 → 1` 不加 transform | 加 translateY/scale |

### 5.2 6 种非默认 cubic-bezier 曲线

```css
:root {
  --ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);     /* 物体进入 */
  --ease-in-quart: cubic-bezier(0.5, 0, 0.75, 0);       /* 物体离开 */
  --ease-out-back: cubic-bezier(0.34, 1.56, 0.64, 1);   /* 弹性 */
  --ease-standard: cubic-bezier(0.2, 0, 0, 1);          /* Material 3 emphasized */
  --ease-in-out-cubic: cubic-bezier(0.65, 0, 0.35, 1);
  --ease-bounce: cubic-bezier(0.68, -0.55, 0.27, 1.55); /* 强过冲 */
}
```

### 5.3 弹簧物理 (Framer Motion / React Spring)

```jsx
import { motion } from "framer-motion";

<motion.button
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  transition={{
    type: "spring",
    stiffness: 400,  // 越高越"硬"
    damping: 25,     // 越低越"弹"
    mass: 0.8,       // 越轻越"灵"
  }}
>
  Click me
</motion.button>
```

### 5.4 时长表 (不是 300ms 模板)

| 元素 | 建议时长 |
| --- | --- |
| 颜色/背景色变化 | 150ms |
| 按钮 hover (颜色 + transform) | 180-220ms |
| 卡片 hover (shadow + transform) | 250-320ms |
| 模态框进入 | 280-380ms |
| 页面切换 | 400-600ms |
| 滚动驱动的进入 | 600-1000ms |
| 文字 reveal (split) | 800-1200ms |

### 5.5 12 条具体建议

1. **永远不要用 `ease` 或 `ease-in-out` 作为唯一缓动**。
2. **首选 `--ease-out` 风格** (`cubic-bezier(0.22, 1, 0.36, 1)`) —— 物体进入屏幕要"快速到位, 缓慢停下"。
3. **关键交互用弹簧** (按钮、模态框、拖拽、菜单展开), 不要用 tween。
4. **弹簧 stiffness 经验值**: UI 微交互 300-500, 卡片翻转 200-300, 弹窗 150-200。
5. **弹簧 damping 经验值**: 无回弹 30+, 轻微回弹 20-25, 果冻感 15-20。
6. **微动效用 stagger**: 列表项进入用 `delay: i * 0.05` 形成"波纹"。
7. **parallax 用 transform: translateY** (百分比) 而非 background-position。
8. **文字 reveal 不要用整段 opacity 淡入** —— 用 split-by-character + translateY。
9. **尊重 `prefers-reduced-motion`**: 用户开启降低动效时, 所有动画时长 ≤ 50ms。
10. **滚动驱动用 View Transitions API 或 Framer Motion `useScroll`**, 不要用 jQuery 时代的位置监听。
11. **不要循环播放装饰动画** —— AI 站最爱"无限循环的渐变光晕", 这是最明显的"AI 味"。
12. **hover 用 transform 而非 color/background** —— transform 由 GPU 处理。

---

## 六、微交互 (Microinteractions)

### 6.1 反"AI 默认"

| 反面 | 改进 |
| --- | --- |
| hover 只改 `background-color` | hover 改 `transform: translateY(-2px)` + `box-shadow` 加深 |
| 加载动画用经典转圈 Spinner | 骨架屏 / 文字进度 / 确定性进度条 |
| 按钮点击无反馈 | 点击瞬间 `transform: scale(0.96)` 然后弹回 |
| 表单错误只显示文字 | 字段边框变红 + 字段下方滑入错误 + 整字段轻微 shake |

### 6.2 10 条具体建议

1. **hover 必须是 transform + shadow 而非 background**:
   ```css
   .btn {
     transition: transform 200ms var(--ease-out-quart), box-shadow 200ms var(--ease-out-quart);
   }
   .btn:hover { transform: translateY(-1px); box-shadow: 0 6px 12px -2px rgba(0,0,0,0.1); }
   .btn:active { transform: translateY(0); box-shadow: 0 1px 2px rgba(0,0,0,0.08); }
   ```
2. **加载不用 Spinner** —— 改用骨架屏、进度条 + 文字、Lottie 动画。
3. **按钮点击反馈 = 形变**, 不是颜色:
   ```css
   .btn:active { transform: scale(0.97); transition-duration: 60ms; }
   ```
4. **状态变化用 200-300ms + 自定义缓动**。
5. **成功反馈用 "checkmark 划线动画"** (SVG `stroke-dashoffset` 动画)。
6. **错误反馈用 field shake** + 红边框 + 错误文字滑入。
7. **菜单/弹窗进入用 transform + opacity 组合**。
8. **拖拽用 transform: translate3d()** (开启 GPU 加速)。
9. **滚动驱动用 `IntersectionObserver` + `view-timeline`**。
10. **微动效克制度** —— 一个页面最多 2-3 个"会动"的元素。

---

## 七、图标与图像 (Iconography & Imagery)

### 7.1 反"AI 默认"

| 反面 | 为什么 |
| --- | --- |
| 用 emoji 作为 UI 元素 | 用户已明确禁止; emoji 跨平台差异巨大 |
| 用 AI 生成的"完美对称"插图 | MidJourney / DALL-E 默认输出有"塑料感" |
| 用 Lucide 但配 16px stroke width, 默认颜色 | 没个性 |
| hero 区域用 3D 渲染的拟物图标 | 2024 AI 站最泛滥 |

### 7.2 推荐的图标库 (2025-2026)

| 库 | 特点 | 推荐场景 |
| --- | --- | --- |
| **Lucide** | 1.6k+ 图标, 1.5px 描边, 可定制 | 默认推荐 |
| **Phosphor** | 9k+ 图标, **6 种 weight** (thin/light/regular/bold/fill/duotone) | 精致 UI |
| **Iconoir** | 1.6k+ 图标, 1.5px 描边, 更"法式" | 内容站、博客、创意类 |
| **Solar** | 1.4k+ 图标, **3 种风格** (linear/bold/broken) | 现代感 |
| **Tabler** | 4.5k+ 图标, 1.5px 描边 | 大体量产品 |

### 7.3 10 条具体建议

1. **永不在 UI 中用 emoji**; 用 SVG 图标替代。
2. **默认图标库用 Lucide 或 Phosphor**, size = 16 或 20, **stroke-width = 1.5**。
3. **icon 颜色用 `currentColor`**, 跟随文字色。
4. **空状态用插画而不是 emoji** —— 画一个简单的 SVG illustration。
5. **用户头像占位用 initials** (名字首字母) + 背景色 hash 取色。
6. **3D 插图最多 hero 1 个**, 其他用 2D / 几何。
7. **照片用 `filter: contrast(1.05) saturate(0.95)` 统一调色**。
8. **favicon 设计用心** —— emoji favicon 是"AI 站"标志之一。
9. **装饰图形用 SVG 自己画** (线条、圆点、网格), 不要用 stock 抽象图。
10. **大背景用真实纹理或渐变 mesh + noise**。

### 7.4 SVG noise 制造"纸质感"

```css
.paper-bg {
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'><filter id='n'><feTurbulence baseFrequency='0.9' /></filter><rect width='100%' height='100%' filter='url(%23n)' opacity='0.08'/></svg>");
}
```

---

## 八、反 AI 化清单 (Anti-AI Checklist)

### 8.1 15 条硬性检查项

```bash
# 1. 紫色主色
grep -i "#8b5cf6\|#a855f7\|#7c3aed" src/   # 应返回 0 行

# 2. transition: all
grep "transition: all" src/                 # 应返回 0 行

# 3. 12-16px 圆角作为按钮主 radius
grep "rounded-xl\|rounded-2xl" src/         # 审计

# 4. 玻璃拟态
grep "backdrop-filter: blur" src/           # 应返回 0 行

# 5. emoji 字符
grep -P "[\x{1F300}-\x{1F9FF}]" src/        # 应返回 0 行
```

### 8.2 决策树

```
看到 "border-radius: 12-16px 的按钮"
  └─ 改 4-6px (科技感) 或 24-32px (反差感, 只此一处)

看到 "紫色主色"
  └─ 改真蓝 #006bff / 墨绿 / 陶土橙 / 酒红

看到 "transition: ease-in-out"
  └─ 改 cubic-bezier(0.22, 1, 0.36, 1) (200ms)

看到 "12 列 grid + repeat(3, 1fr)"
  └─ 改 16 列 + 1.618 黄金比 + 不对称

看到 "Inter 单独使用"
  └─ 换 Geist Sans + Fraunces / IBM Plex 全家桶

看到 "转圈 Spinner"
  └─ 改骨架屏 / 进度条 + 文字

看到 "Emoji 装饰"
  └─ 改 SVG 图标 (Lucide / Phosphor)

看到 "渐变光晕 / mesh gradient"
  └─ 改纯色 + 1px 边框 + SVG noise 纹理
```

### 8.3 5 个"高级"反 AI 化加分项

1. **OpenType 替代字形**: `font-feature-settings: 'ss01' 1, 'ss02' 1, 'cv11' 1;`
2. **自定义滚动条**: `::-webkit-scrollbar { width: 8px; border-radius: 4px; }`
3. **自定义 text selection 颜色**: `::selection { background: var(--blue-200); }`
4. **Favicon 16×16 + 32×32 + apple-touch-icon 都做齐**。
5. **404 页精心设计** —— AI 站永远用默认 404, 手工设计的 404 是品味证明。

---

## 九、10 个具体参考网站/项目

| # | 网址 | 学什么 |
| --- | --- | --- |
| 1 | **linear.app** | 极简排版、灰阶 + 真蓝、噪点纹理、白色 404 |
| 2 | **vercel.com/design** | 完整开源 Geist 设计系统 |
| 3 | **stripe.com** | 紫蓝色调但有"编辑感" |
| 4 | **rauno.me** | 极简个人页, 微动画克制 |
| 5 | **geist.co** | 设计师工作室站, 字号跨度大, 不对称排版 |
| 6 | **lucide.dev / iconoir.com / phosphoricons.com** | 图标库 |
| 7 | **cubic-bezier.com** | 缓动曲线可视化 |
| 8 | **tympanus.net/codrops** (2026 标签) | 滚动驱动、SVG 动画、GSAP 实战 |
| 9 | **tailwindcss.com/docs** | 工具类标准参考 |
| 10 | **framer.com/motion** | 弹簧物理、stagger、View Transitions API |
| 加分 | **gwern.net** | 极端"反设计"案例, 纯文字 + 链接密度 |
| 加分 | **sahil-codrops-2025** 等个人作品站 | 看 Codrops 2025-2026 教程的"工业质感" |

---

## 十、一页速查 CSS (贴到项目 globals.css 头部)

```css
:root {
  --font-sans: 'Geist Sans', 'PingFang SC', system-ui, sans-serif;
  --font-display: 'Fraunces', 'Source Han Serif SC', Georgia, serif;
  --font-mono: 'Geist Mono', 'JetBrains Mono', 'Sarasa Mono SC', monospace;
  
  --bg: #ffffff; --bg-soft: #fafafa;
  --ink: #171717; --ink-soft: #4d4d4d; --ink-faint: #8f8f8f;
  --border: #e6e6e6;
  --brand: #006bff; --brand-soft: #dfefff;
  
  --fs-xs: 12px; --fs-sm: 14px; --fs-base: 16px; --fs-md: 18px;
  --fs-lg: 20px; --fs-xl: 24px; --fs-2xl: 32px; --fs-3xl: 48px; --fs-4xl: 64px;
  
  --s-1: 4px; --s-2: 8px; --s-3: 12px; --s-4: 16px; --s-6: 24px;
  --s-8: 32px; --s-12: 48px; --s-16: 64px; --s-24: 96px;
  
  --r-sm: 4px; --r-md: 6px; --r-lg: 8px; --r-pill: 9999px;
  
  --ease-out: cubic-bezier(0.22, 1, 0.36, 1);
  --ease-in: cubic-bezier(0.5, 0, 0.75, 0);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
  
  --t-fast: 150ms; --t-base: 220ms; --t-slow: 360ms;
}

body {
  font-family: var(--font-sans);
  font-size: var(--fs-base);
  line-height: 1.5;
  color: var(--ink);
  background: var(--bg);
  -webkit-font-smoothing: antialiased;
  font-feature-settings: 'kern' 1, 'liga' 1, 'calt' 1, 'tnum' 1;
}

h1, h2, h3 {
  font-family: var(--font-display);
  letter-spacing: -0.03em;
  line-height: 1.1;
  font-weight: 600;
}

button, a, .interactive {
  transition: transform var(--t-base) var(--ease-out),
              box-shadow var(--t-base) var(--ease-out),
              background-color var(--t-fast) var(--ease-out);
}
button:hover, a:hover { transform: translateY(-1px); }
button:active, a:active { transform: translateY(0); transition-duration: 60ms; }

::selection { background: var(--brand-soft); color: var(--ink); }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    transition-duration: 0.01ms !important;
    animation-duration: 0.01ms !important;
  }
}
```

---

## 关键资料来源

- **Vercel Geist Design System** (vercel.com/design, 2024-2025): 完整的 sRGB + P3 颜色 tokens、字体几何
- **Codrops 2026 趋势教程** (tympanus.net/codrops/tag/2026): GSAP MotionPath、easeReverse 实战
- **Linear.app** (2026 重设计): 产品页布局、白色 + 黑 + 真蓝
- **Stripe.com** (2025 持续): 紫蓝色调的"非 AI 紫"用法
- **Framer Motion 文档**: spring physics、stagger
- **Tailwind CSS v4 文档**: border-radius、font-family、transition-timing-function
- **Lucide / Phosphor / Iconoir / Solar**: 图标库
- **cubic-bezier.com**: 缓动曲线可视化

---

## 元信息

- **条目创建**: 2026-06-21
- **来源**: subagent 通读 Vercel/Stripe/Linear/Framer/Codrops 等 2025-2026 公开资料 + 10500 字调研报告
- **配套规范**: `d:\xiangmu\_meta\rules\ui-design.md` (强制规范)
- **可触发 prompt**: `d:\xiangmu\_meta\templates\prompts\12-anti-ai-ui.prompt.md`
- **下次复核**: 半年 (UI 趋势变化快, 季度太短)
