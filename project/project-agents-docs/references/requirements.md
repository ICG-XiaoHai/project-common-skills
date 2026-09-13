# 需求文档管理规范

需求统一放在 `docs/`：

```text
docs/
├── CHANGELOG.md
├── active/{YYYY-MM-DD-需求名称-vN}/
│   ├── README.md
│   ├── PLAN.md
│   ├── 验收测试.md
│   └── payload/              # 仅接口载荷确有留存需要时
└── archive/{YYYY-MM-DD-需求名称-vN}/
```

- 新需求开始前读取 CHANGELOG；命中同类需求时读取历史目录并总结改动、风险和未完成事项。
- 版本从 v1 开始；迭代时旧版本整体归档，新版本递增。
- README YAML 头部必须有 status、author、date、version；zentao 可选。status 限定为“待评审、开发中、测试中、已上线、已回滚”。
- PLAN 记录模块/类/包、数据库、接口/协议、配置、核心流程、风险降级回滚、外部依赖、部署重启导表影响；无变更也要明确写“无接口变更”“无数据库变更”。
- 验收测试记录功能用例、必要性能测试、回归清单、测试环境、已完成验证和待补充验证。
- 执行计划后更新 active 目录和 CHANGELOG；提交前检查三文件齐全和字段完整。
- delivery-acceptance 或 java-internship-retrospective 的事实分别归档到 README、PLAN、验收测试；无证据标记“待补充”。
- 复盘归档不重复保留 PLAN/验收测试；Archify 产物放复盘或临时目录。
