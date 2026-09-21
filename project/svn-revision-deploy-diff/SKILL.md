---
name: svn-revision-deploy-diff
description: Compare two SVN revisions for backend server changes and report the deployable JAR and CSV files that need to be uploaded, including additions and deletions while excluding client and unrelated files.
---

# SVN 服务端 Revision 部署差异

用于用户提供“上次更新 Revision”和“当前上传服务器 Revision”后，比较两个已提交的 SVN Revision，判断服务器更新需要上传哪些 JAR、CSV，以及哪些部署文件被新增或删除。

## 输入

- `previous_revision`：上次已经上传服务器的 Revision。
- `current_revision`：本次准备上传服务器的 Revision。
- SVN 工作副本路径；未指定时使用当前工作目录。

如果两个 Revision 缺失，先向用户索要这两个数字；不要猜测，也不要把工作副本未提交改动当成 Revision 差异。

## 比较范围

只检查后端相关路径：

- `server/**`
- `proto/**`（协议源变更用于推导 `dldl-protobuf3` JAR）

排除 `client/**`、`docs/**`、`battle-report/**`、IDE/日志/本地配置和其他与服务器上传无关的文件。除非用户明确要求，不执行部署、提交、合并、删除或 Maven 构建。

优先使用已提交 Revision 的仓库 URL 进行只读比较：

```text
svn diff --summarize --xml -r PREVIOUS:CURRENT REPOSITORY_URL
```

不要使用没有 `-r` 的 `svn diff`，避免把本地未提交修改混入结果。

## 分类规则

1. 直接变更的 `*.jar`：按 SVN 状态列入 JAR 清单。
2. 直接变更的 `*.csv`：按 SVN 状态列入 CSV 清单；优先列出 `server/bin/**` 下实际运行目录的 CSV。只有 `server/config/src/**` 变更时，标明“需重新导出/同步后上传”，不要假设运行目录已经更新。
3. Java、Protobuf、资源或 `pom.xml` 变更：根据模块推导需要重新生成/替换的 JAR，不把 `.java` 或 `.proto` 当成上传文件。
4. 已删除的 JAR/CSV：单独列入“删除/下线”，不要放到上传清单。
5. 无法安全映射到 JAR 的服务端文件：列入“待确认”，说明路径和原因；不要编造 JAR 名称。

常用模块到部署 JAR 的映射：

| 变更路径 | 部署 JAR |
|---|---|
| `server/dldl-server/dldl-game-server/**` | `dldl-game-server-*.jar` |
| `server/dldl-server/dldl-cross-server/**` | `dldl-cross-server-*.jar` |
| `server/dldl-server/dldl-protobuf3/**`、`proto/**` | `dldl-protobuf3-*.jar` |
| `server/dldl-server/dldl-config/**` | `dldl-config-*.jar` |
| `server/dldl-server/dldl-battle/**` | `dldl-battle-*.jar` |
| `server/dldl-server/dldl-share/**` | `dldl-share-*.jar` |
| `server/game-starfish/**` | `game-starfish-*.jar` |
| `server/game-rpc/**` | `game-rpc-*.jar` |
| `server/ayjs-agent/**` | `ayjs-agent-*.jar`（若当前部署目录存在） |

同一 JAR 由多个变更文件命中时只列一次。JAR 文件名应优先从当前工作副本 `server/bin/**` 实际查找；找不到时输出模块对应的通配名称并标记“需先构建产物”。

## 输出格式

输出应简洁，只保留部署决策所需信息：

```text
Revision: rPREVIOUS -> rCURRENT

需要上传的 JAR：
- [A/M] server/bin/.../xxx.jar

需要上传的 CSV：
- [A/M] server/bin/.../xxx.csv
- [M] server/config/src/xxx.csv（需重新导出/同步后上传）

需要删除/下线：
- [D] server/bin/.../old.jar

待确认：
- server/...（无法仅凭 Revision 映射到安全的上传产物）
```

如果没有对应变更，明确写“无需要上传的 JAR/CSV”。不要输出客户端文件清单，也不要把普通源码列表直接交给用户作为上传项。

## 推荐执行方式

对重复任务可运行 `scripts/compare_svn_revisions.ps1`；它会读取 SVN XML 汇总、过滤后端范围、映射模块 JAR，并输出 JAR/CSV/删除/待确认清单。脚本只读，不修改工作副本。

最终结果必须提醒：JAR 需要使用 `current_revision` 对应的构建产物；CSV 需要确认已经导出到服务器实际读取的配置目录。不要自动执行 Maven 构建。
