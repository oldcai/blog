---
title: "PyCharm Error: getVirtualFile(...) must not be null"
date: 2024-06-08 15:11:15
tags:
	- PyCharm
---

Today, I encountered a serious error in PyCharm that prevented me from using the IDE properly. The error message was **`"PyCharm Error running getVirtualFile(...) must not be null"`**.

I spent some time troubleshooting the issue, and at first, I suspected that it was a problem with PyCharm itself.

However, after further investigation, I discovered that the culprit was actually a third-party plugin I had installed called `AWS CodeWhisperer`. This plugin is designed to provide code completion suggestions for AWS development.


## Who Caused the getVirtualFile(...) Error

Once I uninstalled the AWS CodeWhisperer plugin, the error in PyCharm disappeared, and I was able to use the IDE without any problems.

![I switched back to copilot because of the PyCharm Error](https://i.imgur.com/wfPkIq2.png)

As a result, I decided to switch back to using GitHub Copilot, another code completion plugin that I had used previously. GitHub Copilot has been working well for me, and I haven't experienced any issues with it so far.

## How to Avoid PyCharm Plugin Errors

This experience highlights the importance of carefully evaluating third-party plugins before installing them in your IDE. While plugins can be helpful in extending the functionality of your IDE, they can also introduce bugs and compatibility issues. It's always a good idea to do some research on a plugin before installing it, and to be prepared to uninstall it if it causes problems.

Here are some additional tips for avoiding plugin-related issues in PyCharm:

* **Only install plugins from trusted sources.** Make sure that the plugin you're installing is from a reputable developer and has a good track record.
* **Check the plugin's compatibility with your version of PyCharm.** Not all plugins are compatible with all versions of PyCharm. Make sure that the plugin you're installing is compatible with the version of PyCharm that you're using.
* **Read the plugin's reviews before installing it.** See what other users have to say about the plugin. This can help you to identify potential problems before you install the plugin.
* **Start with a small number of plugins.** Don't install too many plugins at once. This can make it difficult to troubleshoot problems if they occur.
* **Keep your plugins up to date.** Outdated plugins can be more likely to cause problems. Make sure that you're using the latest versions of your plugins.

By following these tips, you can help avoid plugin-related issues in PyCharm and keep your IDE running smoothly.


