---
title: 同一GitHub账号GitHub Pages绑定多个域名操作步骤
tags:
  - GitHub
categories:
  - 教程
date: 2020-08-26 18:48
---

国内的互联网偏向保守，像GitHub这么慷慨的举动确实不多，以至于老蔡刚开始也以为GitHub只能绑定一个域名，建一个网站。

但是，实际上GitHub Pages是支持绑定多个域名的，不过在他们的服务条款中禁止滥用，也就是说只要不是容易引发争议、违反美国法律的内容，应该都是没有问题的。

## 总结
长话短说，建立多个网站其实就是建立多个repository，并打开网站功能

短话长说，分为2步

注：图片使用imgur存放，看不到请搬梯子

下面是小白操作步骤，详细到哭

### 前提条件

1. 本地装好git命令
2. 有一个可以登陆的GitHub账号

### 第一步，建立repo

#### 1.1 新建
![2020-08-26 at 3.49 pm](https://i.imgur.com/EGRwXZB.jpg)
右上角，点New repository

#### 1.2 给项目取名

![2020-08-26 at 5.13 pm](https://i.imgur.com/pwt8cXC.jpg)

因为每个项目名需要保证唯一性，而担心创建的网站太多，名字弄混，老蔡就干脆把repository name写成想绑定的网站域名了。

这一步不影响最终的域名绑定，只是GitHub代码仓库的地址。

填好后点最下面的Create repository，创建代码仓库。
此时会自动跳转到下一个GitHub页面，先不要任何操作（不要刷新、关闭网页）
打开控制台，继续下面的操作

### 第二步，创建本地网页目录

在控制台中，cd到准备用作本地网页目录的路径。
#### 2.1 创建域名解析配置文件
 ```
 echo "githubpages.maintainless.com" >> CNAME
 ```
 如果你用的是其他域名，要记得改成自己的。
 
#### 2.2 创建git项目


复制下面的命令，在命令行中运行

```
echo "Hello world" >> index.html
git init
git add index.html
git add index.html
git commit -m "first commit"
```

#### 2.3 关联刚才创建的GitHub repo

从刚才的GitHub页面中，复制下面的命令
![2020-08-26 at 5.22 pm](https://i.imgur.com/JedJClJ.jpg)

在刚才的命令行中运行

### 第三步，打开GitHub网页功能

没有打开GitHub网页功能之前，GitHub是不会自动关联网页到域名的，这需要注意。

刷新刚才复制命令的网页，如果内容已经变了，就说明以上步骤是成功的。

#### 3.1 进入设置

![2020-08-26 at 6.23 pm](https://i.imgur.com/jHAEviD.jpg)

然后点击Settings，进行设置

#### 3.2 选择分支

![2020-08-26 at 6.21 pm](https://i.imgur.com/1VFWDBl.jpg)

选择分支后点Save
![2020-08-26 at 6.28 pm](https://i.imgur.com/ARW5pQR.jpg)

就打开了GitHub网页功能

![2020-08-26 at 6.37 pm](https://i.imgur.com/CdS892U.jpg)

记住这个地址，下面解析需要用到。如果GitHub改版，可以尝试 {**GitHub用户名**}.github.io

### 第四步，解析域名

通常来说，解析域名只用在dns服务器中解析即可。

但是如果需要加速/防墙，建议使用CloudFlare。

![2020-08-26 at 6.40 pm](https://i.imgur.com/LlksDfq.jpg)

![2020-08-26 at 6.40 pm](https://i.imgur.com/ZFdsCL1.jpg)

在域名解析中，用CNAME解析方式，解析到刚才的记住的地址中的域名部分即可

### 第五步，打开网页查看

打开[测试地址](https://githubpages.maintainless.com/)查看

![2020-08-26 at 6.42 pm](https://i.imgur.com/fJSwZKM.jpg)

如果没有马上生效，等5分钟再看看。

以上就是小白版本GitHub Pages创建教程，同一个账号支持多个域名。