---
title: "intel_gpu_frequency - Tweaking and Tuning for Optimal Performance"
date: 2024-05-01 12:52:22
categories:
  - ai
tags:
  - Intel GPU
---

`intel_gpu_frequency` is a valuable tool for fine-tuning your Intel GPU's performance. This tool empowers you to manually control your Intel GPU's frequencies, allowing for performance optimisation or debugging tasks. In this instalment of our "[intel-gpu-tools](https://www.oldcai.com/ai/intel-gpu-tools/)" series, we'll delve into manipulating Intel GPU frequencies.

![Tweaking and Tuning using intel_gpu_frequency](https://i.imgur.com/Yp2lZAs.jpg)

### How it Works

Intel GPUs automatically adjust their frequencies based on workload. When needed, the clock speed increases, and during idle periods, it lowers to conserve power.

`intel_gpu_frequency` lets you bypass this automatic control and lock the frequency to a specific value. This can be beneficial in scenarios like:

* **Debugging Performance Issues:** By fixing the GPU frequency, you can isolate the impact of frequency fluctuations on your application's performance.
* **Benchmarking:** Setting the GPU frequency to its maximum allows you to gauge your GPU's peak performance during benchmark tests.

## Using intel_gpu_frequency

The syntax for `intel_gpu_frequency` is as follows:

```
intel_gpu_frequency [OPTIONS]
```
![intel-gpu-tools for Optimal Performance](https://i.imgur.com/ceeuaGy.png)

### Available Options:

* `-e`: Locks the frequency to the most efficient value.
* `-g, --get`: Retrieves all current frequency settings.
* `-s FREQUENCY, --set=FREQUENCY`: Locks the frequency to a specific value (MHz).
* `-c, --custom`: Sets a minimum or maximum frequency ("min=X | max=Y").
* `-m, --max`: Locks the frequency to the maximum value.
* `-i, --min`: Locks the frequency to the minimum value (FOR DEBUGGING ONLY).
* `-d, --defaults`: Resets the system to default hardware settings.
* `-h, --help`: Displays help information.
* `-v, --version`: Displays the tool's version.

### Examples:

* `intel_gpu_frequency -gmin,cur`: Shows the current and minimum frequencies.
* `intel_gpu_frequency -s 400`: Locks the frequency to 400 MHz.
* `intel_gpu_frequency -c max=750`: Sets the maximum frequency to 750 MHz.
