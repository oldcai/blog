---
title: 创建只有 10MB 左右大小的docker镜像 - rust之actix-web - rust教程04
date: 2020-07-16 01:30:58
categories:
  - 教程
  - rust
tags:
  - actix
  - docker
  - rancher
  - server
---

该文章为[构建 actix web](https://www.oldcai.com/rust/web-server-response-ip/)服务的后续，旨在利用 Dockerfile 给 rust 构建的 web 程序制作一个最小镜像。

利用 Dockerfile 制作 rust 程序的镜像，难点在于在一个 docker 容器中交叉编译、构建，生成的docker镜像又要打包到另一个容器。

好在 docker 已经提供了相关的支持，完成后的 Dockerfile 如下：

```
FROM oldcai/rust-musl-builder:latest as build
ADD . /home/rust/src
WORKDIR /home/rust/src

#RUN apk add --no-cache ca-certificates gcc mingw-w64-gcc libc-dev musl-dev
#RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release

FROM alpine:latest

WORKDIR /web/
COPY --from=build /home/rust/src/target/x86_64-unknown-linux-musl/release/httpapi /web/

CMD ["./httpapi", "0.0.0.0:80"]
```

注解的部分是如果不用老蔡提供的这个镜像，可能需要装的一些库。

运行程序的基础镜像选择的最新版本的 alpine，镜像本身只有 5.57MB 大小，很适合golang、rust编译的、没什么依赖项的程序运行。

打包完毕后，总大小才13.5MB
