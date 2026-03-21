---
title: 正则表达式进阶，零宽正回顾断言，零宽负回顾断言
date: 2018-10-21 21:19:01
categories:
  - 编程
tags:
  - 代码高亮
---


零宽断言，表示匹配字符的时候再添加一些定位条件，使匹配更精准，但又不匹配到字符串。简单来说，零宽断言只做判断，不消耗字符。

## 四种零宽断言

| 名称 | 示例 | 解释 | 匹配举例 |
|:----:|:----:|:----:|:--------:|
| 零宽正先行断言 (Positive Lookahead) | `\w+(?=ing)` | 匹配后面紧跟 `ing` 的单词前缀，不包括 `ing` 本身 | `talking` → `talk`，`singing` → `sing`，`king` → 不匹配（`k` 前无 `\w+`） |
| 零宽负先行断言 (Negative Lookahead) | `\w+(?!ing)` | 匹配后面不跟 `ing` 的多个字符 | `do talking` → `do`，`hello` → `hello`，`run` → `run` |
| 零宽正回顾断言 (Positive Lookbehind) | `(?<=re)\w+` | 匹配前面紧跟 `re` 的多个字符，不包括 `re` 本身 | `redo` → `do`，`return` → `turn`，`research` → `search` |
| 零宽负回顾断言 (Negative Lookbehind) | `(?<!re)\w+` | 匹配前面不是 `re` 的单词 | `refreshing weather` → `weather`，`hello world` → `hello`、`world` |

## 组合使用

零宽断言可以组合起来，同时约束前后条件：

`(?<=\s)\d+(?=\s)` 匹配两边是空白符的数字，不包括空白符，相当于Vim中在单词上按下`*`号的结果

更多组合举例：

| 示例 | 解释 | 匹配举例 |
|:----:|:----:|:--------:|
| `(?<=\$)\d+` | 匹配美元符号后面的数字 | `$100` → `100`，`€50` → 不匹配 |
| `\d+(?=%)` | 匹配百分号前面的数字 | `80%` → `80`，`100%off` → `100` |
| `(?<=\[)\w+(?=\])` | 匹配方括号内的内容 | `[INFO]` → `INFO`，`[ERROR]` → `ERROR` |

另外，推荐一个测试正则表达式的网站: [Regexr](https://regexr.com/)
regex，是正则regular expression的缩写，加上r就当是被正则坑的人的意思吧😂

