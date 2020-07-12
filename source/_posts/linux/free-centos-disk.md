---
title: Free CentOS Disk for 10G in 2 Commands
date: 2020-07-12 08:54:45
categories:
  - Linux
tags:
  - CentOS
---

## Introduction

I have a personal VPS had been running for almost two years, and its disk usage is getting to 90%.

Increase the budget is not necessary because there isn't any serious business running on it.

Then I started to investigate the disk-consuming directories and finally found out who was responsible for high disk usage, and .

The good thing is, there is no risk or any effort to exert for cleaning them.

Here are the commands to free those disk:

## Steps

```
journalctl --vacuum-size=1G
yum clean all
```

## A Little Explanation

For the first command, because a long run system could have tens of GBs of log archives, making journal service keep its size below a specific size is always a good idea.

The second one is cleaning the yum cache, which is also above 10GBs on my side.

After running those commands, my VPS system had freed about 12GBs and back to bouncing again.
