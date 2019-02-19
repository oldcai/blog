---
title: Update Oh My Zsh Automatically Using Crontab
date: 2019-02-20 02:29:00
categories:
  - Server
tags:
  - zsh
---

## Reason
Oh My Zsh is a cool zsh configuration set, and it's very active, updates the code base quite often, which is good.

But when sometimes we are eager to change the world, it still asks us to update it first. That would be a little bit boring after doing these for several times.

## Solution

We can update Oh My Zsh by adding this line below to crontab.

`0    3    *    *    *    zsh -c 'DISABLE_AUTO_UPDATE=true && export ZSH=$HOME/.oh-my-zsh && source $ZSH/oh-my-zsh.sh && upgrade_oh_my_zsh 2>&1' >> /dev/null`

Normally, crontab can be modified by command `crontab -e`

And we can add this line to `.zshrc` to forbid Oh My Zsh asks us for permitting update.

`DISABLE_AUTO_UPDATE=true`