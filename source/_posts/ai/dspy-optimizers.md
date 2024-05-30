---
title: DSPy 优化器 optimizer，提升你的 AI 模型性能
date: 2024-05-30 08:38:35
tags:
	- DSPy
---

**DSPy 优化器（Optimizer）** 是一组用于优化 DSPy 程序（包括提示和/或语言模型权重）的算法，旨在最大化指标（如准确度）。它们通过调优 DSPy 程序中的参数，提高程序在特定任务上的表现。以前，这些优化器也称为 **DSPy 提示器（Teleprompters）**。

## 什么是 DSPy 优化器？

DSPy 优化器其实是一些算法，它们能自动调优 DSPy 程序，使其在特定任务上表现更好。一个 DSPy 优化器需要以下几样东西：

- **DSPy 程序**：可以是一个简单的模块（如 `dspy.Predict`）或一个复杂的多模块程序。
- **指标**：一个评估程序输出的函数，并为其分配分数（越高越好）。
- **训练输入**：仅需少量示例（如 5 或 10 个），且不必完整（比如只有程序的输入，但没有标签）。

即使只有少量数据，DSPy 也能利用这些数据获得良好结果。如果你有大量数据那就更棒了，DSPy 完全可以充分利用。

## DSPy 优化器如何调优？

传统的深度神经网络（DNN）可以通过梯度下降优化，但 DSPy 程序由多个堆叠在一起的 LM 调用组成，称为 **DSPy 模块**。

每个模块有三类内部参数：

1. **LM 权重**
2. **指令**
3. **输入/输出行为的示例**

给定一个指标，DSPy 能通过多阶段优化算法优化这三类参数。这些算法结合了梯度下降（用于 LM 权重）和离散的 LM 驱动优化（用于编写/更新指令和创建/验证示例）。DSPy 示例类似于少样本示例，但更强大。它们可以从头创建，并通过多种方式优化。

我们发现，通过编译生成的提示通常比人类编写的提示更好。这是因为 DSPy 优化器可以系统地尝试更多选项，并直接优化指标。


## 目前有哪些 DSPy 优化器？

![提示器子类](https://i.imgur.com/wjHYN3n.png)

这些优化器的所有子类可以通过 `from dspy.teleprompt import *` 访问。

### 自动少样本学习

这些优化器通过自动生成和包含优化的示例到发送给模型的提示中，实施少样本学习。

| 优化器 | 描述 |
| --- | --- |
| **`LabeledFewShot`** | 从标记的输入和输出数据点中构建少样本示例（演示）。需要 `k`（提示中的示例数量）和 `trainset` 以随机选择 `k` 个示例。 |
| **`BootstrapFewShot`** | 使用 `teacher` 模块为程序的每个阶段生成完整的演示，并结合 `trainset` 中的标记示例。参数包括 `max_labeled_demos`（从 `trainset` 中随机选择的演示数量）和 `max_bootstrapped_demos`（由 `teacher` 生成的额外示例数量）。引导过程使用指标验证演示，仅包括通过指标的演示在“编译”提示中。支持使用不同的 DSPy 程序作为 `teacher` 程序，用于更复杂的任务。 |
| **`BootstrapFewShotWithRandomSearch`** | 使用随机搜索多次应用 `BootstrapFewShot`，并在优化过程中选择最佳程序。参数与 `BootstrapFewShot` 类似，另外增加了 `num_candidate_programs`，指定在优化过程中评估的随机程序数量。 |
| **`BootstrapFewShotWithOptuna`** | 通过 Optuna 优化在演示集上应用 `BootstrapFewShot`，运行试验以最大化评估指标并选择最佳演示。 |
| **`KNNFewShot`** | 通过k最近邻算法选择演示，从不同簇中选择一组多样化的示例。对示例进行矢量化，然后对其进行聚类，使用聚类中心进行 `BootstrapFewShot` 的引导/选择过程。 |

### 自动指令优化

这些优化器生成最佳的提示指令，在 MIPRO 的情况下，还优化少样本示例的集合。

| 优化器 | 描述 |
| --- | --- |
| **`COPRO`** | 为每个步骤生成并改进新指令，并通过坐标上升法（使用指标函数和 `trainset` 进行爬山算法）优化它们。参数包括 `depth`，即优化器运行的提示改进迭代次数。 |
| **`MIPRO`** | 在每个步骤生成指令和少样本示例。指令生成是数据感知和示例感知的。使用贝叶斯优化在您的模块之间有效搜索生成指令/示例的空间。 |

### 自动微调

此优化器用于微调基础的 LLM（大语言模型）。

| 优化器 | 描述 |
| --- | --- |
| **`BootstrapFinetune`** | 将基于提示的 DSPy 程序提炼成权重更新（针对较小的语言模型）。输出是一个具有相同步骤的 DSPy 程序，但每个步骤由微调模型而非提示的语言模型进行。 |

### 程序变换

| 优化器 | 描述 |
| --- | --- |
| **`Ensemble`** | 集成一组 DSPy 程序，并使用整个集合或随机采样子集到一个单一程序中。 |

## 选择哪个优化器？

如果您不知道从哪里开始，请使用 `BootstrapFewShotWithRandomSearch`。

以下是一些入门的指导建议：

- 如果您只有很少的数据，例如 10 个任务示例，使用 `BootstrapFewShot`。
- 如果您有稍多的数据，例如 50 个任务示例，使用 `BootstrapFewShotWithRandomSearch`。
- 如果您有更多的数据，例如 300 个任务示例或更多，使用 `MIPRO`。
- 如果您能够使用较大的语言模型（例如 7B 参数或以上）并且需要一个非常高效的程序，请使用 `BootstrapFinetune` 将其编译为较小的语言模型。

## 如何使用优化器？

这些优化器共享一个通用接口，关键字参数（超参数）略有不同。以下是使用最常用的 `BootstrapFewShotWithRandomSearch` 的示例：

```python
from dspy.teleprompt import BootstrapFewShotWithRandomSearch

# 设置优化器：我们希望为程序步骤“引导”8个示例。
# 优化器将在选择开发集上的最佳尝试之前重复10次（加上一些初始尝试）。
config = dict(max_bootstrapped_demos=4, max_labeled_demos=4, num_candidate_programs=10, num_threads=4)

teleprompter = BootstrapFewShotWithRandomSearch(metric=YOUR_METRIC_HERE, **config)
optimized_program = teleprompter.compile(YOUR_PROGRAM_HERE, trainset=YOUR_TRAINSET_HERE)
```

## 保存和加载优化器输出

在通过优化器运行程序之后，保存它非常有用。稍后可以从文件加载程序并用于推理。为此，可以使用 `load` 和 `save` 方法。

### 保存程序

```python
optimized_program.save(YOUR_SAVE_PATH)
```

生成的文件是纯文本 JSON 格式，包含源程序中的所有参数和步骤。你可以随时阅读它，看看优化器生成了什么。

### 加载程序

要从文件加载程序，可以从该类实例化一个对象，然后调用其上的 `load` 方法。

```python
loaded_program = YOUR_PROGRAM_CLASS()
loaded_program.load(path=YOUR_SAVE_PATH)
```

## 结论

DSPy 优化器是提升 AI 模型性能的强大工具，无论你有多少数据，它都能帮助你优化模型，获得更高的准确度和性能。通过选择合适的优化器，并根据具体需求进行调优，你可以在各种任务中获得出色的结果。

