---
title: 给 Hexo 加上语义搜索：hexo-semantic-search-ai
date: 2026-01-15 10:00:00
categories:
  - Hexo
tags:
  - Hexo
  - 搜索
  - 语义搜索
  - SemanticSearch
---

静态博客虽好，但搜索功能一直是其短板。传统的关键词搜索常常无法理解用户意图，导致读者难以找到真正需要的内容。

**hexo-semantic-search-ai** 正是为了解决这一痛点而生。它将强大的语义搜索能力引入 Hexo 博客，让你的读者能用更自然的方式找到文章，并且后端可以基于 Cloudflare Workers 免费部署。

## 它能为你做什么？

简单来说，这个插件能让你的 Hexo 博客：

*   **理解语义**：读者用自然语言提问，搜索结果更精准。
*   **几乎零维护**：发布文章后自动同步，无需手动干预。
*   **智能推荐**：提供“真正相关”的文章推荐，提升阅读体验。
*   **成本极低**：可利用 Cloudflare Workers 的免费额度，部署和运行几乎不花钱。

## 如何开始使用？

核心步骤非常简单：**部署 SemanticSearch 服务** → **安装插件** → **配置 `_config.yml`**。

具体安装和配置细节，请直接查阅 [项目文档](https://github.com/SemanticSearch-ai/hexo-plugin#快速开始)。

## 页面集成

无论是搜索框还是相关文章推荐，插件都提供了便捷的 helper 函数。

关于如何在你的 Hexo 主题中集成搜索功能和相关文章，请参考 [项目文档](https://github.com/SemanticSearch-ai/hexo-plugin#主题集成)。

## 实际效果演示

无需多言，本站已经在使用这套方案。你可以直接在顶部搜索框体验语义搜索，或者查看文章底部的相关推荐。

## 了解更多

**hexo-semantic-search-ai** 是一款开源插件，所有详细文档、使用说明和最新动态都在这里：

*   **GitHub 项目主页**：[https://github.com/SemanticSearch-ai/hexo-plugin](https://github.com/SemanticSearch-ai/hexo-plugin)
*   **NPM 包**：[https://www.npmjs.com/package/hexo-semantic-search-ai](https://www.npmjs.com/package/hexo-semantic-search-ai)

希望你的 Hexo 博客也能因此焕发新的活力，让更多好内容被发现！
