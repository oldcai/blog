---
title: WordPress 转 Hexo 后，回车变成空格的问题解决
date: 2018-10-22 23:45:13
categories:
  - 解决
tags:
  - 博客
  - Hexo
  - WordPress
---

刚从 WordPress 转到 Hexo 的时候，很多文章文字都挤在一团，很不方便阅读。

## 替换代码：

```bash 空格替换回回车
ls -d source/_posts/archives/* | xargs perl -pi -e 's|(?<!^)(?<![~`!@#$%^&*()\-_=+\\\|.,<>/?;: #\w\d]) |\n\n|g'
```

运行上面代码，再稍微整理一下，就好看多了。

因为替换时的正则表达式用到了[零宽正回顾断言](/hexoprograming/regex/)，所以，并不会影响英文和代码的正常显示。

### 替换前：
![从WordPress导入过来的没回车的文章](/images/2018/10/content-no-return.jpg)


### 替换后：
![替换好回车的文章](/images/2018/10/content-with-return.jpg)

