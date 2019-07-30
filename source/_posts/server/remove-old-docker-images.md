---
title: Remove Docker Images Older Than One week/month/year Automatically
date: 2019-07-30 16:26
categories:
  - Server
tags:
  - CI
  - Docker
  - Rancher
  - Kubernetes
---

## Reason
I'm using rancher pipeline to deploy my service continually, it always creates a new image but never cleans it.

I believe other continuous integration solutions would do the same, so I'm going to share some lines of code to deal with it.

## Steps

Let's say, the project I'm going to build is named 'GetShitDone'.

The way to clear old images is as simple as copy and paste the codes below.

> The images that are still in use would be protected and wouldn't be removed. 
> It's safe to use these commands.


### Remove images older than 1 week

```
project_name=GetShitDone
docker images | grep ${project_name} | grep 'weeks ago\|months ago\|years ago' | awk '{print $3}'| xargs docker rmi
```

If you would like to keep the images for months or longer, you can remove the `weeks ago` and `months ago` part.


### Only remove images older than 1 month

```
project_name=GetShitDone
docker images | grep ${project_name} | grep 'months ago\|years ago' | awk '{print $3}'| xargs docker rmi
```

### And clean images created 1 year ago

```
project_name=GetShitDone
docker images | grep ${project_name} | grep 'years ago' | awk '{print $3}'| xargs docker rmi
```


## Tips


That's it, cheers.