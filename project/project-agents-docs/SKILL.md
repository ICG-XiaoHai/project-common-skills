---
name: project-agents-docs
description: 为项目生成或维护通用 AGENTS.md 及 docs 文档治理规范；适用于初始化项目协作约束、同步子项目规范、建立需求/技术设计/API 文档模板与归档流程。
metadata:
  short-description: 生成项目 AGENTS.md 与 docs 规范
---

# 项目规范与文档治理

用于把项目协作规则沉淀到 `AGENTS.md`，并建立可持续维护的 `docs/` 文档体系。默认只修改用户明确指定的项目范围，不执行 SVN/Git 提交。

## 工作流程

1. 确认项目根目录和范围。递归扫描全部 `AGENTS.md`、`docs/` 目录及现有 README/规范文件。
2. 逐个读取已有 `AGENTS.md`，识别项目特有规则并原文保留；合并通用章节，避免重复追加。
3. 为根项目生成或补齐 AGENTS.md；仅为承担独立构建/部署职责的子项目生成子项目 AGENTS.md。
4. AGENTS.md 至少覆盖：项目概述与范围、目录/模块、开发与代码规范、构建测试、本地开发、修改原则、提交评审注意事项，以及需求文档、技术设计、API 文档章节。
5. 按需创建 `docs/CHANGELOG.md`、`docs/active/`、`docs/archive/`、`docs/technical/`、`docs/api/`，不制造无意义的空示例。
6. 输出实际修改路径、合并规则、待补充字段，并检查结构、链接和元数据。

## 参考规范

- 需求与迭代、历史版本、验收：[requirements.md](references/requirements.md)
- 技术方案、架构与数据模型：[technical-design.md](references/technical-design.md)
- 前后端 RESTful 对接：[api-docs.md](references/api-docs.md)

## 约束

- 先读 `docs/CHANGELOG.md`；命中历史需求时继续读取对应目录的 README、PLAN、验收测试及必要 payload。
- 保留现有项目规范；不能凭空猜测技术栈、表名、接口、状态或发布结果。
- 缺少证据写“待补充”，不得写成“已完成”或“已上线”。
- 需求目录标准文件为 README.md、PLAN.md、验收测试.md；payload 仅按需创建；Archify 产物不放入需求目录。
- 默认不执行版本控制提交。
