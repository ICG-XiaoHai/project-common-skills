---
name: java-dev
description: Java 开发规范，包含命名约定、异常处理、Spring Boot 最佳实践等
version: v3.0
paths:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle"
  - "**/build.gradle.kts"
---

# Java 开发规范

参考 Google Java Style Guide 与阿里巴巴 Java 开发手册，保持代码清晰、可测试、可维护。

## 工具链

```bash
mvn clean compile
mvn test
mvn verify
./gradlew build
./gradlew test
```

## 命名与结构

- 包名全小写，使用域名反转，例如 `com.example.project`。
- 类名使用大驼峰名词，例如 `UserService`、`HttpClient`。
- 方法名使用小驼峰并以动词开头，例如 `findById`、`isValid`。
- 常量使用全大写下划线，例如 `MAX_RETRY_COUNT`。
- 布尔方法优先使用 `is`、`has`、`can` 前缀。
- 类成员顺序：静态常量、静态变量、实例变量、构造函数、静态方法、实例方法（公共到私有）、getter/setter。

## 异常与资源

- 捕获具体异常并补充上下文，保留原始异常作为 cause。
- 使用 try-with-resources 自动关闭文件、流和连接。
- 避免 `catch (Exception)`、`printStackTrace()` 和吞掉异常。

```java
try {
    user = userRepository.findById(id);
} catch (DataAccessException e) {
    throw new ServiceException("Failed to find user: " + id, e);
}

try (InputStream input = new FileInputStream(file)) {
    // use input
}
```

## 空值处理

- 查询结果用 `Optional` 表达“可能不存在”。
- 对公共方法参数使用 `Objects.requireNonNull` 或 Bean Validation。
- 使用 `Optional.map(...).orElse(...)` 做安全转换，避免无意义的链式 Optional。

## 并发编程

- 优先使用受控的 `ExecutorService` 或 `CompletableFuture`，避免业务代码直接创建线程。
- 明确线程池大小、队列、拒绝策略与关闭生命周期。
- 对异步操作设置超时，并正确处理取消、异常和共享状态。

## 测试（JUnit 5）

- 测试方法名说明场景与预期，例如 `findById_whenUserExists_returnsUser`。
- 按 given / when / then 组织测试。
- 覆盖成功、空值、异常、边界和并发相关场景；避免依赖真实外部服务。

## Spring Boot

- 使用构造函数注入（可配合 Lombok `@RequiredArgsConstructor`），不要使用字段注入。
- Controller 只负责协议适配，业务逻辑放在 Service，持久化放在 Repository。
- 使用 DTO 隔离 API 模型与领域/持久化模型；统一异常响应和参数校验。

```java
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
}
```

## 性能与日志

- 识别并避免 N+1 查询，使用 JOIN FETCH 或批量查询。
- 循环拼接字符串使用 `StringBuilder`；合理设置集合初始容量。
- 日志使用参数化写法，不要字符串拼接；异常日志包含异常对象。

```java
log.debug("Finding user by id: {}", userId);
log.info("User {} logged in successfully", username);
log.error("Failed to process order {}", orderId, exception);
```

## 交付检查

修改 Java 项目后，运行与变更匹配的编译、单元测试、集成测试和静态检查，并在总结中说明失败项及其影响。
