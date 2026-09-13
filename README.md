# project-agents-docs

`project-agents-docs` 用于初始化和维护项目级 `AGENTS.md` 与 `docs/` 文档治理规范。它适合 Java 后端项目，也适用于包含多个子项目、前后端协作、接口变更和持续迭代需求的仓库。

## 适用的工作流

```text
初始化项目规范
    ↓
多轮讨论并确认需求
    ↓
Java 后端开发（java-dev）
    ↓
测试与验收
    ↓
交付验收（delivery-acceptance）
    ↓
任务总结与复盘（java-internship-retrospective）
    ↓
图示展示（archify）
```

在这个流程中，`AGENTS.md` 是项目级约束入口，`docs/` 是需求、设计、接口和验收事实的长期记录。调用 `delivery-acceptance` 或 `java-internship-retrospective` 时，应依据代码、测试和运行证据，按照 `AGENTS.md` 的规则同步更新对应需求目录与 `docs/CHANGELOG.md`。

## 典型使用方式

### 1. 初始化项目

在项目根目录调用：

```text
使用 $project-agents-docs 初始化当前项目的 AGENTS.md 和 docs 文档体系。
请先扫描现有 AGENTS.md、README 和 docs，保留项目特有规范，并补齐需求文档、技术设计文档和 RESTful API 文档规则。
```

初始化阶段通常生成或补齐：

- 根项目 `AGENTS.md`，必要时为独立子项目补充 `AGENTS.md`；
- `docs/CHANGELOG.md`；
- `docs/active/`、`docs/archive/`；
- `docs/technical/` 技术设计文档目录；
- `docs/api/` 前后端 API 文档目录。

### 2. 讨论并确认需求

需求尚未确定时，先进行多轮对话，不要过早编写“已完成”的需求文档。需求确认后，应创建或更新：

```text
docs/active/{YYYY-MM-DD-需求名称-vN}/
├── README.md      # What & Why，含 YAML 头部
├── PLAN.md        # How，记录实现计划和影响范围
└── 验收测试.md     # Verify，记录验收方案
```

开始新需求或迭代前，先读取 `docs/CHANGELOG.md`，并检查同类历史需求。

### 3. Java 后端开发

实现阶段可调用 `java-dev` skill。开发时遵循当前项目 `AGENTS.md` 中的 Java、构建、日志、测试和修改范围规则；如果需求涉及接口、数据库、配置或部署，及时同步 `PLAN.md` 和相关技术设计/API 文档。

### 4. 测试与交付验收

开发完成后先执行项目测试和必要的人工验证，再调用 `delivery-acceptance`。验收结果应基于真实代码、日志、数据库影响、接口行为和测试环境记录，写入 `验收测试.md`；无法确认的内容标记为“待补充”。

### 5. 任务总结与复盘

需要总结本次任务时调用 `java-internship-retrospective`。将事实拆分同步到需求目录：需求说明写入 `README.md`，执行过程和影响写入 `PLAN.md`，验证结果写入 `验收测试.md`，并更新 `docs/CHANGELOG.md`。复盘归档不重复保存 PLAN 和验收测试。

### 6. 生成图示

需要展示架构、流程、时序、数据流或状态机时调用 `archify`。生成的 HTML、JSON、visual-check 等展示产物不属于需求文档，不应放入 `docs/active/` 或 `docs/archive/`；可放在复盘归档或临时产物目录，并从文档中链接引用。

## 文档目录职责

| 目录 | 用途 |
| --- | --- |
| `docs/active/` | 当前开发中或待验收的需求版本 |
| `docs/archive/` | 已归档的历史需求版本 |
| `docs/technical/` | 技术栈、项目结构、数据模型和关键技术设计 |
| `docs/api/` | 前后端 RESTful API 与 OpenAPI 契约 |
| `docs/CHANGELOG.md` | 需求和版本变更索引 |

## 重要约束

- 保留现有项目规范，合并时避免重复追加。
- 不凭空猜测表名、字段、接口、状态、测试结果或上线状态。
- 缺少证据的字段统一标记“待补充”。
- 默认不执行 SVN/Git 提交。
- 需求目录标准文件为 `README.md`、`PLAN.md`、`验收测试.md`；`payload/` 仅在确有接口载荷留存需要时创建。

## 关联 skill

- `java-dev`：Java 后端编码与工程实践
- `delivery-acceptance`：交付验收、日志、数据库和发布前检查
- `java-internship-retrospective`：开发总结、问题复盘和简历亮点提炼
- `archify`：架构图、流程图、时序图和状态图生成

本 README 说明使用方式；具体约束以 [SKILL.md](SKILL.md) 及其 `references/` 下的规范为准。
