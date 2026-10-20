# personal-ai-archive

> 一次搭建、全平台复用的个人 AI 记忆系统。
> 一份档案，让 ChatGPT / Gemini / Claude / DeepSeek / Meta Muse / OpenAI Dots 等所有 AI 都认识你、记住你、为你沉淀经验。

---

## 这是什么

一个用 GitHub 托管、Markdown 编写、版本控制的**个人档案仓库**。
任何 AI 只需读取本仓库，就能获得你的身份、工作习惯、沟通风格、历史经验、技能进度；
AI 完成任务后，可把新经验/偏好自动追加到对应文件，并留下 git 版本记录，可随时回退。

核心特点：
- ✅ **跨 AI**：基于公开标准（GitHub raw + Contents API），不绑定任何单一平台。
- ✅ **跨设备**：桌面/手机/车机都指向同一仓库，离线 clone、联网 push。
- ✅ **AI 可读可写**：YAML 头 + `AI-READONLY/READWRITE` 标签 + 占位符，无需格式转换。
- ✅ **版本保护**：每次写入即一次提交，分支保护防误删篡改，一键回退历史版本。

---

## 仓库结构

```
personal-ai-archive/
├── ai-integration.md        # 跨AI适配中枢（先读这个）
├── README.md                # 本文件
├── BRANCH-PROTECTION.md     # 分支保护 / 回退说明
├── push-to-github.sh        # 一键创建远程仓库并推送
├── .gitignore
├── identity/                # 身份·职业·目标        [AI-READONLY]
├── workflow/                # 工作习惯·工具·沟通·优先级 [AI-READONLY]
├── memory/                  # 经验·决策·偏好        [AI-READWRITE]
├── skills/                  # 技能·学习·待提升       [AI-READWRITE]
└── archive/                 # 历史项目·已完成任务     [AI-READWRITE]
```

---

## 快速上手

### 1. 填写你的档案
打开 `identity/`、`workflow/` 下的模板，把 `{{占位符}}` 替换为你自己的信息。
> 提示：只读区域（READONLY）是你的稳定身份，填好后少改；读写区域（READWRITE）留给 AI 持续沉淀。

### 2. 推送到 GitHub
```bash
cd personal-ai-archive
export GITHUB_USERNAME=你的GitHub用户名
export GH_TOKEN=你的PersonalAccessToken      # 需 repo 权限
bash push-to-github.sh
```
脚本会自动：创建公开仓库 `personal-ai-archive` → 推送全部文件 → 尝试开启 main 分支保护。
完成后终端会打印仓库地址。

### 3. 接入任意 AI
把 `ai-integration.md` 第 0 节的「接入指令」粘给 ChatGPT/Gemini/Claude/DeepSeek 即可。
Agent（Muse/Dots 等）直接调用 GitHub Contents API 读写。

---

## AI 接入快速操作指南

| 平台 | 读取 | 写入 |
|------|------|------|
| ChatGPT | 联网读取 raw URL 或粘贴核心文件 | 自定义GPT Action 调 Contents API / 产出文本后脚本提交 |
| Gemini | Extensions 联网读 raw URL | Apps Script 调 API / 文本产出后提交 |
| Claude | 工具读 raw URL / Projects 上传 | Agent 直接调 Contents+Commits API（需 PAT） |
| DeepSeek/DSH | 直接读本地仓库 | git commit + push |
| Muse/Dots 等 Agent | HTTP 读 raw URL 或 Contents API | 按自动写入规则追加 + Contents API 提交 |

读取基址（公开、无需认证）：
```
https://raw.githubusercontent.com/{{YOUR_GITHUB_USERNAME}}/personal-ai-archive/main/<相对路径>
```

---

## 安全须知
- 本仓库设计为**公开**，便于所有 AI 读取；**切勿**写入密码、密钥、隐私凭证。
- 写入受 PAT 控制（读开放、写受控）。
- 建议开启 main 分支保护（见 `BRANCH-PROTECTION.md`），防 AI 误删篡改。
- 每次写入即一次版本快照，误写可一键回退。

---

## 相关文档
- [ai-integration.md](ai-integration.md) — 跨AI适配中枢（权限模型、读写API、自动写入规则）
- [BRANCH-PROTECTION.md](BRANCH-PROTECTION.md) — 分支保护与历史回退
- [push-to-github.sh](push-to-github.sh) — 一键推送脚本
