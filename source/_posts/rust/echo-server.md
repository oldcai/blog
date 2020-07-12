---
title: 传回TCP传入字符的Echo Server - rust之tokio - rust教程02
date: 2020-07-10 07:24:02
categories:
  - 教程
  - rust
tags:
  - tokio
---

## 1. 创建项目

```
cargo new --bin echo-server
```


## 2. 修改文件
> Cargo.toml

```
[dependencies]
tokio = { version = "0.2", features = ["full"] }
futures = "0.3"
```

> src/main.rs

```
use tokio::net::TcpListener;
use tokio::prelude::*;
use futures::stream::StreamExt;

#[tokio::main]
async fn main() {
    let addr = "127.0.0.1:6142";
    let mut listener = TcpListener::bind(addr).await.unwrap();

    // Here we convert the `TcpListener` to a stream of incoming connections
    // with the `incoming` method.
    let server = {
        async move {
            let mut incoming = listener.incoming();
            while let Some(conn) = incoming.next().await {
                match conn {
                    Err(e) => eprintln!("accept failed = {:?}", e),
                    Ok(mut sock) => {
                        // Spawn the future that echos the data and returns how
                        // many bytes were copied as a concurrent task.
                        tokio::spawn(async move {
                            // Split up the reading and writing parts of the
                            // socket.
                            let (mut reader, mut writer) = sock.split();

                            match tokio::io::copy(&mut reader, &mut writer).await {
                                Ok(amt) => {
                                    println!("wrote {} bytes", amt);
                                }
                                Err(err) => {
                                    eprintln!("IO error {:?}", err);
                                }
                            }
                        });
                    }
                }
            }
        }
    };
    println!("Server running on localhost:6142");

    // Start the server and block this async fn until `server` spins down.
    server.await;
}
```


## 3. 运行
### 运行代码
```
cargo run
```

### 如果出错，则运行
```
RUST_BACKTRACE=full cargo run
```
可以查看到出错的堆栈

### 测试
#### Windows
```
telnet 127.0.0.1 6142
```

#### Mac
```
nc 127.0.0.1 6142
```

#### 然后
随便输入数据后，回车，会看到传回数据

> Input: oldcai.com

> Output: oldcai.com

## 总结

用tokio实现出一个服务端程序

实现功能：
1. 监听本地6142端口
2. 收到数据流后，传回同样数据

`let (mut reader, mut writer) = sock.split();`这句有些意思

把socket分成写和读两个对象，让处理更加简单了。

`tokio::spawn`这句是能够并发的关键，没有这句就只能一次处理一个连接

而加上这句，其实代码逻辑还是和同步编程一样
