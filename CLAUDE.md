# 老菜博客 (www.oldcai.com)

Hexo 6 博客。**本仓库是唯一内容源**；线上站点是 GitHub Pages 仓库 `oldcai/www.oldcai.com`，由 `hexo deploy` 生成并**强制覆盖推送**，绝不要直接改它。

- 主题：`themes/cactus`，`colorscheme: dark`（深色背景 #1d1f21）
- URL 规则：`permalink: :title/`，`_posts` 下的子目录会进入 URL
  - `source/_posts/docs/foo.md` → `https://www.oldcai.com/docs/foo/`
- `.env` 提供 `SEMANTIC_SEARCH_WRITER_KEY`（semantic search 同步用，见 memory）

## 发布页面流程（所有 agent 必须遵守）

1. **写 Markdown**，放进 `source/_posts/`（产品文档/隐私政策放 `source/_posts/docs/`），front matter 参照现有文件：

   ```yaml
   ---
   title: Foo Privacy Policy
   date: 2026-07-12 11:35:00
   tags:
       - Foo
   ---
   ```

2. **本地预览**：`npm run server` → http://localhost:4000 检查渲染和配色（主题是深色的，页面无需也不应自带样式）。

3. **发布**：运行 `./up.sh`。它会 commit + push 本仓库的 `source/`，然后 `hexo clean && hexo g && hexo d` 生成并推送到 Pages 仓库。等价手动命令：`npm run clean && npm run build && npm run deploy`（都会自动读 `.env`）。

4. **验证**：`curl -s https://www.oldcai.com/<path>/ | head` 确认页面存在且使用主题布局（含 cactus 的完整 `<head>`，而不是手写的极简 HTML）。

## 禁止事项

- **禁止手写 HTML 直接 push 到 `oldcai/www.oldcai.com`**。教训（2026-07 FastMD 隐私页）：手写页面引用了主题的 `/css/style.css`（深色底）却按白底写内联样式，浅色模式下文字和背景都是深色、无法阅读；且下次 `hexo d` 会把它整个覆盖掉。
- 不要手动编辑 `public/`（生成产物）和 `.deploy_git/`（部署缓存）。
- 不要为单个页面写独立布局/内联配色；统一用 cactus 主题渲染。
