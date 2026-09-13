---
name: svn-changelist
description: Organize task-related changes in any SVN working copy into a safe local Changelist and provide a recommended commit message without committing. Use when the user asks what to submit, wants a submission list or Changelist, is preparing to push SVN, or invokes this skill to prepare an SVN submission in any project.
---

# SVN Changelist

Prepare an SVN submission for any project. Never execute `svn commit`.

## Workflow

1. Locate the SVN working-copy root from the current workspace or user-provided path.
2. Inspect `svn status` and focused diffs.
3. Select only files belonging to the task discussed or implemented in the current conversation.
4. Exclude unrelated user changes, build outputs, generated artifacts, local settings, caches, and unversioned files unless they are explicitly part of the task.
5. Create a concise task-based Changelist name:

   ```powershell
   svn changelist "<name>" -- <task-file-1> <task-file-2>
   ```

6. Verify with `svn status --changelist "<name>"`. Remove unchanged files from the Changelist.
7. If the task files are already committed, report the revision when discoverable and do not create an empty group.
8. Return:
   - Changelist name
   - exact grouped file list
   - concise recommended commit message in the user's language

## Commit Message

默认使用 Conventional Commits 风格：`<type>(<scope>): <说明>`。

- `feat`：新增或调整用户可感知的功能、规则或协议能力。
- `fix`：修复与原有预期不一致的缺陷。
- `refactor`：不改变外部行为的代码整理。
- `perf`：性能优化。
- `docs`：仅文档说明变更。
- `test`：仅测试代码或测试数据变更。
- `build`：构建脚本、依赖或打包链路变更。
- `chore`：以上类别之外的维护性改动。

`scope` 使用短模块名，例如 `p302`、`recharge`、`config`；没有清晰模块时可省略括号。说明使用中文动宾短语，不加句号。除非仓库已有明确约定，不使用非标准的 `add:` 前缀。

## Guardrails

- Do not run `svn commit`, upload files, add unversioned paths, revert changes, resolve conflicts, delete files, or update the working copy.
- Preserve unrelated Changelists and working-copy modifications.
- Do not assume project-specific generated-file rules; infer them from repository structure and the current task.
- If task ownership is ambiguous, show candidate files and ask before grouping them.
