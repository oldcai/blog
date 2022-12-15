#!/usr/bin/env zsh
source ~/.zshrc
cd ~/programs/blog
git add source/
git commit -am 'updated'
git push &

hexo clean
hexo g
hexo d
