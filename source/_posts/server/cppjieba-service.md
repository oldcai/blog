---
title: 把cppjieba打包成了Docker镜像
date: 2019-08-01 00:52:00
categories:
  - Server
tags:
  - 自然语言
  - docker
  - cpp
---

有需要的朋友，可以使用：

```
docker pull oldcai/cppjieba-service:latest
```

用法：

```
docker run -d -p 8008:80 oldcai/cppjieba-service:latest
```

```
curl 'localhost:8008/?key=工信处女干事每月经过下属科室都要亲口交代24口交换机等技术性器件的安装工作'

Output:
["工信处", "女干事", "每月", "经过", "下属", "科室", "都", "要", "亲口", "交代", "2", "4", "口", "交换机", "等", "技术性", "器件", "的", "安装", "工作"]
```

有问题或者建议可以到[老蔡博客](https://www.oldcai.com/server/cppjieba-service/)留言