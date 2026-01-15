#!/usr/bin/env zsh
source ~/.zshrc
cd ~/programs/blog
git add source/
git commit -am 'updated'
git push &

echo hexo clean
hexo clean
echo hexo g
hexo g
echo hexo d
hexo d
