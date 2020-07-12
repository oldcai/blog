---
title: 响应IP的HTTP Server - rust之actix-web - rust教程03
date: 2020-07-12 00:52:00
categories:
  - 教程
  - rust
tags:
  - actix
  - server
---

## 1. 创建项目

```
cargo new return-ip
```


## 2. 修改文件
> Cargo.toml

```
[dependencies]
actix-web = "0.7"
clap = "2.33.1"
```

> src/main.rs

```
extern crate actix_web;

use actix_web::{App, HttpRequest, Responder, server};
use clap::Arg;

fn index(_req: &HttpRequest) -> impl Responder {
    let addr = _req.peer_addr().unwrap();
    let ip = addr.ip().to_string();
    format!("{}\n", ip)
}

fn main() {
    let matches = clap::App::new("HTTP Proxy")
        .arg(
            Arg::with_name("listen_addr")
                .takes_value(true)
                .value_name("LISTEN ADDR")
                .index(1)
                .required(true),
        )
        .get_matches();
    let listen_addr = matches.value_of("listen_addr").unwrap();
    server::new(|| App::new().resource("/", |r| r.f(index)))
        .bind(listen_addr)
        .unwrap()
        .run();
}
```


## 3. 运行
### 运行代码
```
cargo run :::8000
```

### 如果只需要ipv4，则运行
```
cargo run 127.0.0.1:8000
```

### 测试
```
curl localhost:8000

# 或者指定 IPV6 地址请求
curl -g -6 'http://[::1]:8000/'
```
或者直接打开 [http://localhost:8000](http://localhost:8000)

#### 返回结果

> IPV4返回： 127.0.0.1
> IPV6返回： ::1

## 小结

用actix实现出一个http服务端程序

用到模块：

1. actix-web, 提供http
2. clap, 解析命令行参数

实现功能：

1. 获取传入的绑定ip地址
2. 绑定到地址后提供http服务
3. 返回请求端的ip地址

## benchmark测试

打开release后，actix-web benchmark测试得16.14k

```
Running 30s test @ http://127.0.0.1:8000/
  12 threads and 400 connections
    Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.11ms  201.40us  15.62ms   97.33%
    Req/Sec    16.14k     4.92k   24.15k    66.61%
  3044704 requests in 15.80s, 389.09MB read
  Socket errors: connect 155, read 122, write 0, timeout 0
Requests/sec: 192666.29
Transfer/sec:     24.62MB
```

debug模式时，actix-web QPS为6.21k

奇怪得是IPV6或者IPV4的选择也会影响QPS，

当用IPV6进行访问时，

release版本也会掉到10.86k左右，debug版本反而没啥变化。

