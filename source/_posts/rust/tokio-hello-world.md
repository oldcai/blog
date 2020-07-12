---
title: Hello World - rust之tokio- rust教程01
date: 2020-07-10 06:57:53
categories:
  - 教程
  - rust
tags:
  - tokio
---

## 1. 创建项目

```
cargo new hello-tokio
```


## 2. 修改文件
> Cargo.toml

```
[dependencies]
tokio = { version = "0.2", features = ["full"] }
```

> src/main.rs

```
use tokio::net::TcpStream;
use tokio::prelude::*;

#[tokio::main]
async fn main() {
    let mut stream = TcpStream::connect("127.0.0.1:6142").await.unwrap();
    println!("created stream");

    let result = stream.write(b"hello world\n").await;
    println!("wrote to stream; success={:?}", result.is_ok());
}
```


## 3. 运行
### 准备
#### Windows
```
telnet 127.0.0.1 6142
```

#### Mac
```
nc -l 127.0.0.1 6142
```

### 运行代码
```
cargo run
```

### 如果出错，则运行
```
RUST_BACKTRACE=full cargo run
```
可以查看到出错的堆栈

## 总结

用tokio实现出一个客户端程序
实现功能：
1. 连接到本地6142端口
2. 发送字符串`hello world\n`
3. 检测是否发送成功并打印

可能错误：
本地端口监听失败或还未监听，会出现错误：
```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Os { code: 61, kind: ConnectionRefused, message: "Connection refused" }', src/main.rs:6:22
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

