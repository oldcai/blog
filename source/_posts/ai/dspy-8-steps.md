---
title: 怎样使用DSPy？任何DSPy项目都能套用的8个步骤
date: 2024-05-28 00:18:38
tags:
    - DSPy
---

使用 DSPy 解决新任务的关键在于利用语言模型（LM）进行有效的机器学习。

## 1) 定义任务

首先，你需要明确要解决的问题。

**预期输入/输出行为：** 你是想创建一个聊天机器人、代码助手、信息提取系统、翻译系统、搜索结果高亮系统，还是带有引用的主题信息摘要系统？

提出3-4个输入和输出的示例（如问题及其答案，或主题及其摘要）会非常有帮助。

**质量和成本规范：** 考虑你的预算和响应时间。选择适合的语言模型，如 GPT-3.5、Mistral-7B、Llama2-13B-chat、Mixtral、GPT-4-turbo 或 T5-base。

## 2) 定义管道

明确你的 DSPy 程序要完成的任务。

### 模块选择

决定是否需要思维链步骤、检索功能或其他工具（如计算器或日历 API）。
几乎每个任务都可以从一个简单的 [dspy.ChainofThought](/ai/dspy-chain-of-thought/) 模块开始，然后逐步增加复杂性。

## 3) 探索示例

收集并测试一些任务示例。
使用强大的语言模型或多个不同的模型来理解可能的结果。记录有趣的示例，无论是简单还是复杂的。

## 4) 定义数据

正式声明训练和验证数据，用于 DSPy 评估和优化。

### 数据来源

你可以手动准备约10个示例，或从 HuggingFace 数据集或其他数据源中找到类似的数据。
如果数据许可足够宽松，建议使用这些数据，否则可以通过部署系统收集初始数据。

## 5) 定义指标

明确系统输出的优劣标准，并逐步改进。

### 指标类型

对于简单任务，可以使用“准确性”或“完全匹配”等简单指标。
对于大多数应用，输出较长格式内容，指标应检查输出的多个属性，可能需要使用 AI 反馈。

## 6) 收集初步评估

在任何优化之前，使用数据和指标对管道进行评估。

查看输出和指标分数，确定基准，发现主要问题。

## 7) 使用 DSPy 优化器进行编译

根据数据和指标，优化你的程序。

**优化器选择：**
* 10个示例：使用 [`BootstrapFewShot`](/ai/bootstrap-fewshot/)。
* 50个示例：使用 [`BootstrapFewShotWithRandomSearch`](https://dspy-docs.vercel.app/docs/deep-dive/teleprompter/bootstrap-fewshot)。
* 300个或更多示例：使用 [`MIPRO`](https://dspy-docs.vercel.app/docs/deep-dive/teleprompter/signature-optimizer)。
* 高效程序：使用 `BootstrapFinetune` 将大 LM 编译为小 LM。

## 8) 迭代

不断改进程序和指标。

重新审视任务定义，收集更多数据，更新指标，使用更复杂的优化器，或者增加程序复杂性。

通过迭代开发，逐步优化你的数据、程序结构、断言、指标和优化步骤。

优化复杂的 LM 程序是一种新兴范例，DSPy 提供了实现这一目标的工具。


## 相关资料

[英文版](https://dspy-docs.vercel.app/docs/building-blocks/solving_your_task)


