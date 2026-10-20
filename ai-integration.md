<!-- AI-LOCATOR: ai-integration.md 跨AI适配中枢 -->
---
file: ai-integration.md
category: config
permission: READWRITE (规则本身 READONLY，写入规则供所有AI执行)
last_updated: {{YYYY-MM-DD}}
version: 1.0
---

# AI 集成配置：跨 AI / 跨设备复用中枢

> 本文件是「一次搭建、全平台复用」的入口。任何 AI 平台只要遵循此文件，即可读取你的全部档案，并在完成任务后自动沉淀新经验/偏好。
> 所有 AI 读取档案的优先级：**本文件 → identity/ → workflow/ → 按需读取 memory/skills/archive**。

---

## 0. 一句话接入

把下面这段「接入指令」粘贴给任意 AI（ChatGPT / Gemini / Claude / DeepSeek / 自建 Agent），它即获得你的档案访问能力：

```
你已接入我的个人AI档案仓库（GitHub 公开仓库）：
  仓库：https://github.com/{{YOUR_GITHUB_USERNAME}}/personal-ai-archive
  原始读取基址：https://raw.githubusercontent.com/{{YOUR_GITHUB_USERNAME}}/personal-ai-archive/main/
请先读取 ai-integration.md 了解权限与写入规则，再按需读取 identity/ 与 workflow/ 作为长期上下文。
完成任务后，按「自动写入规则」把可复用的经验/偏好追加到对应文件。
```

---

## 1. 仓库结构与权限模型

| 目录 | 用途 | AI 权限 | 写入文件 |
|------|------|---------|----------|
| `identity/` | 身份·职业·目标 | **READONLY** | 禁止AI改写，仅人工 |
| `workflow/` | 工作习惯·工具·沟通·优先级 | **READONLY**（tools.md 建议区可追加） | `workflow/tools.md` 建议区 |
| `memory/` | 经验·决策·偏好 | **READWRITE（追加）** | experiences/decisions/preferences.md |
| `skills/` | 技能·学习·待提升 | **READWRITE（追加）** | 全部文件 |
| `archive/` | 历史项目·已完成任务 | **READWRITE（追加）** | projects/completed-tasks.md |

**核心铁律**：
1. READONLY 文件 AI 仅读不改；如确需更新，须人工确认后提交。
2. READWRITE 文件 AI 仅**追加**、不覆盖历史；如需订正，新增「订正」条目并标注原文位置。
3. 每次写入即一次 git 提交，天然留痕，误写可回退。

---

## 2. 读取方式（所有平台通用）

### 2.1 直接原始链接（无需认证，公开仓库）
任意能联网的 AI/浏览器/Agent 可直接 GET：
```
https://raw.githubusercontent.com/{{YOUR_GITHUB_USERNAME}}/personal-ai-archive/main/<相对路径>
```
例：读取身份档案
```
https://raw.githubusercontent.com/{{YOUR_GITHUB_USERNAME}}/personal-ai-archive/main/identity/profile.md
```

### 2.2 GitHub Contents API（读取 + 获取 sha 以便更新）
```
GET https://api.github.com/repos/{{YOUR_GITHUB_USERNAME}}/personal-ai-archive/contents/<相对路径>?ref=main
```
返回 JSON 含 `content`（base64）与 `sha`（更新时需回传）。

### 2.3 各平台具体接入

#### ChatGPT（GPT-4/GPT-5 等）
- **读**：开启联网/浏览后，直接喂原始链接；或让 GPT 调用工具读取 raw URL。
- **写**：若使用 GPT 的「Actions / 自定义GPT」，配置一个调用 GitHub Contents API 的 Action；或让 GPT 产出待追加文本，由你/脚本提交。
- **最低成本**：对话中粘贴 `identity/profile.md`+`workflow/communication-style.md` 作为系统上下文即可获得跨平台一致体验。

#### Gemini
- **读**：通过「Extensions / 联网」或导出按钮读取 raw URL；Gemini 支持直接抓取公开网页。
- **写**：通过 Google Apps Script / 外部脚本调用 GitHub API；或让 Gemini 产出文本后由你提交。

#### Claude（含 Claude Code / Agent）
- **读**：支持网页读取与工具调用，直接读 raw URL；Claude Projects 可把核心文件上传为项目知识库。
- **写**：Claude Code/Agent 可直接调用 GitHub Contents/Commits API（需你提供 PAT）。

#### DeepSeek / DeepSeek Harness（DSH）
- **读**：本仓库即为此环境设计，可直接读取工作区内文件。
- **写**：通过 git 提交写入，提交后推送至 GitHub。

#### Meta Muse / OpenAI Dots 等 AI Agent
- **读**：Agent 具备 HTTP 工具，调用 raw URL 或 Contents API。
- **写（偏好同步）**：Agent 完成任务后，调用本文件第 4 节的「自动写入规则」，将识别到的个人偏好追加到 `memory/preferences.md`，把经验追加到 `memory/experiences.md`。

---

## 3. 写入方式（GitHub Contents API）

更新某文件（需 PAT，scope: `repo`，或 fine-grained token 对本仓库 `Contents: Read and write`）：

```bash
# 1. 取当前内容与 sha
RESP=$(curl -s "https://api.github.com/repos/$OWNER/personal-ai-archive/contents/$PATH?ref=main" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json")
SHA=$(echo "$RESP" | grep '"sha"' | head -1 | cut -d'"' -f4)
OLD=$(echo "$RESP" | grep '"content"' | cut -d'"' -f4 | tr -d '\n ')

# 2. 解码、追加、重新编码（base64）
echo "$OLD" | base64 -d >> tmp_old.md
cat tmp_old.md your_new_entry.md > tmp_new.md
NEW_B64=$(base64 -w0 tmp_new.md)

# 3. PUT 回仓库
curl -s -X PUT "https://api.github.com/repos/$OWNER/personal-ai-archive/contents/$PATH" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  -d "{\"message\":\"memory: 追加 $PATH - $TITLE\",\"sha\":\"$SHA\",\"branch\":\"main\",\"content\":\"$NEW_B64\"}"
```

> 仓库根目录提供 `push-to-github.sh`，封装了上述逻辑；Agent 也可直接执行该脚本完成追加。

---

## 4. 自动写入规则（AI 完成任务后执行）

每当 AI 完成一次有价值的任务，**必须**判断并追加：

| 任务产出类型 | 写入目标文件 | commit message 前缀 |
|--------------|------------|---------------------|
| 可复用经验/踩坑/有效做法 | `memory/experiences.md` | `memory: experiences - <标题>` |
| 做出关键决策 | `memory/decisions.md` | `memory: decisions - <标题>` |
| 发现新的个人偏好 | `memory/preferences.md` | `memory: preferences - <标题>` |
| 掌握新技能/技能进展 | `skills/mastered-skills.md` 或 `learning-plan.md` | `skills: <文件> - <标题>` |
| 项目完结 | `archive/projects.md` | `archive: projects - <标题>` |
| 任务完结 | `archive/completed-tasks.md` | `archive: tasks - <标题>` |

### 标准条目格式（所有 AI 必须统一，便于跨平台解析）
```markdown
### {{YYYY-MM-DD HH:MM}} | {{简短标题}}
- 来源：{{ChatGPT/Gemini/Claude/DSH/Muse/Dots/人工}}
- 情境：{{一句话背景}}
- 结论/偏好/产出：{{可复用的结论}}
- 关联：{{相关 identity/goals.md 原则或其它文件}}
```

### 写入流程（Agent 自动）
1. 判断本任务是否产生可沉淀价值；若无（纯一次性查询），跳过。
2. 选择目标文件，在「自动写入区」**顶部**追加一条标准条目。
3. 提交：`git add <file> && git commit -m "<前缀> - <标题>" && git push`，
   或调用第 3 节 Contents API。
4. 如涉及 READONLY 文件的更新，**停下并请求人工确认**，不得自行提交。

---

## 5. 安全与版本控制

- 公开仓库 = 可被任意 AI 读取，但**写入需 PAT**，故「读开放、写受控」。
- `main` 分支建议开启分支保护（见 `BRANCH-PROTECTION.md`）：禁止强推、要求 PR/提交签名，防 AI 误删篡改。
- 每次写入即一个 commit，构成完整时间线；任意历史版本可通过 `git checkout` / GitHub 网页 / `push-to-github.sh` 回退。
- **敏感信息铁律**：本仓库为公开仓库，严禁写入密码/密钥/隐私凭证；此类信息放本地或私有仓库。

---

## 6. 跨设备复用

- 桌面/手机/车机：任一设备上的 AI 都指向同一 GitHub 仓库，读取同一份档案。
- 离线场景：`git clone` 到本地后用本地 AI 读取；联网后 `git push` 同步沉淀。
- 多 AI 并发写入：因每次写入基于 sha 做 PUT（乐观锁），若冲突则取最新 sha 重试追加，避免覆盖。
