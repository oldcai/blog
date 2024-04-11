---
title: Rust日志tracing的debug和debug_span，info和info_span，error和error_span有什么区别
date: 2024-04-12 01:01:17
categories:
  - rust
tags:
  - tracing
  - log
  - span
---

在 Rust 中，`debug`和`debug_span`，`info`和`info_span`，`error`和`error_span` 都是 `tracing` 宏用于记录日志级别的信息。

## 差异：

### 信息量

- `info`, `debug`, `error`: 仅记录消息本身。
- `info_span`, `debug_span`, `error_span`: 除了消息本身之外，还记录了一个时间范围。该时间范围表示从日志记录开始到日志记录结束所花费的时间。

### 用法

- `info`: 通常用于记录简单事件或消息。
- `info_span`: 通常用于记录需要测量其执行时间的代码块。

#### 示例

```rust
use tracing::{info, info_span};

fn main() {
    // 使用 info 记录简单消息
    info!("Hello, world!");

    // 使用 info_span 记录需要测量执行时间的代码块
    let span = info_span!("long_running_operation");
    // 模拟耗时操作
    std::thread::sleep(std::time::Duration::from_secs(1));
    span.finish();
}
```

### 何时使用

- 如果您只想记录简单消息，请使用 `info`。
- 如果您需要测量代码块的执行时间，请使用 `info_span`。

### `span` 的其他用途

- 跟踪函数或方法的执行时间。
- 测量网络请求或数据库查询的延迟。
- 剖析性能关键路径。

