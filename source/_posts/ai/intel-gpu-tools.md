---
title: "Get Started with Intel Arc GPU Monitoring: How to Show GPU Usage and Graphics Memory Usage"
date: 2023-02-22 00:46:23
categories:
  - ai
tags:
  - Intel GPU
  - Monitoring
---

## How to Show Gpu Usage After Installing Intel-Gpu-Tools

After installing intel-gpu-tools, you can show GPU usage using the intel_gpu_top command.
Here are the steps to show GPU usage:

1. Open a terminal window.
2. Type the following command and press Enter to launch intel_gpu_top: `intel_gpu_top`
3. The intel_gpu_top tool will display real-time GPU usage statistics for the Intel GPU. You will see a screen with a list of metrics that shows the utilization of various GPU components, such as the GPU engine, memory, and the GPU core frequency.
4. Press 'q' to exit intel_gpu_top.

![GPU](https://i.imgur.com/nIZPjwO.png)
The result of this command would be like the image above.

Note: Make sure you have the appropriate drivers installed and your GPU is supported by intel-gpu-tools.


## What Else Are Included in the Intel-Gpu-Tools

`intel-gpu-tools` is a collection of tools for debugging and monitoring Intel GPUs on Linux. In addition to intel_gpu_top, which shows real-time GPU usage statistics, intel-gpu-tools includes several other useful tools, including:

1. intel_gpu_dump: This tool can be used to extract debug information from the Intel GPU, including error state and performance counters.
2. intel_reg_read/intel_reg_write: These tools can be used to read or write registers in the Intel GPU, which can be useful for debugging and testing.
3. intel_audio_dump: This tool can be used to capture audio playback data from Intel GPUs with integrated audio controllers.
4. intel_gpu_frequency: This tool can be used to monitor or set the frequency of the Intel GPU.
5. intel_display_power: This tool can be used to control the display power of the Intel GPU, which can be useful for power management and reducing energy consumption.

Overall, intel-gpu-tools is a useful collection of tools for developers and system administrators who need to monitor or debug Intel GPUs on Linux systems.


## How to Show Graphics Memory Usage

Sysmon can be utilized to monitor GPU memory, but the tool is not currently available in a system package. Therefore, it must be compiled from the source code.

```
git clone https://github.com/intel/pti-gpu/
cd pti-gpu/tools/sysmon
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release .. && make
```

Once the tool has been compiled, it can be executed via the command `./sysmon`.


![graphics memory](https://i.imgur.com/MjRt37b.png)

The graphics memory usage of the Arc card is displayed in the `Device Memory Used(MB)` column, which is partitioned by process IDs.

The compiled file can be copied into the `/bin/` directory or any other directory within the $PATH environment variable. Once the file is in the correct directory, you can run the tool using the `sysmon` command.

## Additional Resources:

[intel_gpu_frequency](https://www.oldcai.com/ai/intel-gpu-frequency/)
