<!-- AI-LOCATOR: memory 目录说明 -->
# 目录说明：memory / 个人经验与偏好沉淀

本目录是 AI 写入的主战场——**AI-READWRITE（追加写入）** 区域。
AI 完成任务后，应将新经验、决策、偏好按标准格式追加到对应文件，并提交版本记录。
所有写入仅追加、不覆盖历史；如需修正旧条目，新增一条「订正」条目并标注原文位置。

## 包含文件
| 文件 | 内容 | AI 权限 | 写入时机 |
|------|------|---------|----------|
| `experiences.md` | 历史经验、踩坑教训、有效做法 | READWRITE | 任务完成后 |
| `decisions.md` | 重要决策记录、决策原则的实战应用 | READWRITE | 做出关键决策后 |
| `preferences.md` | AI 对话沉淀的个人偏好 | READWRITE | 发现新偏好时 |

## 标准条目格式（所有AI统一）
```
### YYYY-MM-DD HH:MM | 简短标题
- 来源：{{ChatGPT/Gemini/Claude/DSH/人工}}
- 情境：{{一句话背景}}
- 结论/偏好：{{可复用的结论}}
- 关联：{{如 identity/goals.md 的某条目标}}
```

## 安全约定
- 追加写入须提交 git commit，commit message 形如 `memory: 追加 <文件> - <标题>`。
- 每条写入即一次版本快照，误写可通过 `git revert` / GitHub 回退恢复。
