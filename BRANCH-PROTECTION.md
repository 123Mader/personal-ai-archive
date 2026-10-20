# 分支保护与历史回退

> 目标：所有修改自动生成提交记录，支持一键回退到任意历史版本，避免 AI 误删或篡改档案。

## 1. 自动版本记录（已内置）
本仓库所有文件均纳入 git。任何一次写入（人工或 AI）都是一次 commit，
天然形成完整时间线，无需额外配置即可追溯。

## 2. 开启 main 分支保护（推荐）

`push-to-github.sh` 会在推送后自动尝试开启如下保护（需 PAT 含 `Administration: write` 或 `repo` 权限）：
- 禁止强制推送（force push），防止覆盖历史。
- 禁止直接删除 main 分支。
- （可选）要求提交签名 / 要求 PR 审核。

若自动开启失败（权限不足），手动在网页操作：
```
仓库 → Settings → Branches → Add branch protection rule → Branch name pattern: main
勾选：
  ☑ Require a pull request before merging（建议，AI 写入走 PR 更安全）
  ☑ Do not allow bypassing the above settings
  ☑ Restrict who can push to matching branches
```
> 若希望 AI 可直接追加提交（走 commit 而非 PR），可只勾选「禁止 force push」与「禁止删除分支」，保留直接 push 能力。

## 3. 一键回退到任意历史版本

### 方式 A：命令行（最精准）
```bash
cd personal-ai-archive
git log --oneline                       # 查看提交历史
git checkout <commit-hash> -- <文件>   # 把某文件恢复到某版本
git commit -m "revert: 恢复 <文件> 到 <commit-hash>"
git push
```
整库回退到某版本：
```bash
git reset --hard <commit-hash>          # 危险：丢弃之后的提交
git push --force-with-lease             # 需分支保护允许 force
```

### 方式 B：GitHub 网页（可视化）
```
仓库 → 文件 → 右上角 History → 选择历史版本 → Browse files / Restore
```
或在 `commits` 页面找到某次提交 → `Revert`，自动生成一个反向提交（不丢历史）。

### 方式 C：AI 误写恢复
若 AI 追加了错误条目，因「仅追加不覆盖」铁律，旧内容仍完整存在；
直接 `git revert <那次提交>` 生成反向提交即可撤销该次写入，历史无损。

## 4. 备份建议
- 关键节点手动打 tag：`git tag -a v-stable-<date> -m "稳定快照"` → `git push --tags`
- 或定期 `git bundle create archive.bundle --all` 离线备份。
