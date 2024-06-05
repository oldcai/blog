---
title: DSPy模块(dspy.Module)有哪些功能？如何使用它们优化AI模型？
date: 2024-06-01 12:36:11
tags:
	- DSPy
---

## 什么是DSPy模块？
**DSPy 模块**是构建语言模型（LM）程序的基础单元。

- DSPy模块是一种**封装提示技术**（如思维链或 ReAct），模块旨在处理任何 [DSPy Signature](https://www.oldcai.com/ai/dspy-signature/)。
- DSPy 模块具有**可学习参数**，可以被调用以处理输入并返回输出。
- 多个模块可以组合成更大的模块（程序），类似于 PyTorch 中的神经网络模块，但应用于语言模型程序。

## 模块（dspy.Module)的基本构成

我们先从最基本的 `dspy.Predict` 开始。所有 DSPy 模块都是基于 `dspy.Predict` 构建的。

签名（Signature）是定义我们在 DSPy 中使用的任何模块行为的规范。如果还不了解，可以先过一遍 [DSPy 签名](https://www.oldcai.com/ai/dspy-signature/)。

### 示例 1：`dspy.Predict`

1. **声明模块**：给模块一个签名。
2. **调用模块**：使用输入参数调用模块。
3. **提取输出**：获取输出字段。

例如：

```python
sentence = "it's a charming and often affecting journey."  # 来自 SST-2 数据集的示例

# 1. 使用签名声明模块
classify = dspy.Predict('sentence -> sentiment')

# 2. 使用输入参数调用模块
response = classify(sentence=sentence)

# 3. 访问输出
print(response.sentiment)  # 输出：Positive
```

### 示例 2：`dspy.ChainOfThought`

声明模块时，我们可以传递配置参数，例如请求多个结果：

```python
question = "What's something great about the ColBERT retrieval model?"

# 1. 使用签名声明模块，并传递配置参数
classify = dspy.ChainOfThought('question -> answer', n=5)

# 2. 使用输入参数调用模块
response = classify(question=question)

# 3. 访问输出
print(response.completions.answer)
```

**输出：**

```
[
  'One great thing about the ColBERT retrieval model is its superior efficiency and effectiveness compared to other models.',
  'Its ability to efficiently retrieve relevant information from large document collections.',
  ...
]
```

### 查看详细输出

`dspy.ChainOfThought` 模块通常会在输出字段之前生成 `rationale`（推理过程）。我们可以这样查看：

```python
print(f"Rationale: {response.rationale[0]}")
print(f"Answer: {response.answer[0]}")
```

**输出：**

```
Rationale: produce the answer. We can consider the fact that ColBERT has shown to outperform other state-of-the-art retrieval models in terms of efficiency and effectiveness. It uses contextualized embeddings and performs document retrieval in a way that is both accurate and scalable.
Answer: One great thing about the ColBERT retrieval model is its superior efficiency and effectiveness compared to other models.
```

### 示例 3：dspy.ProgramOfThought
```python
# 思考程序的示例问题
question = '小明有 5 个苹果。她从商店又买了 7 个苹果。小明现在有多少个苹果？'

# 声明并调用思维程序模块
pot = dspy.ProgramOfThought('question -> answer')
result = pot(question=question)

# 打印最终预测答案
print(f"Question: {question}")
print(f"最终预测答案（思维过程结束后）：{result.answer}")

# 输出：最终预测答案（思维过程结束后）：12
```

在本例中，dspy.ProgramOfThought 模块用于生成计算给定问题答案的可执行代码。该模块的声明签名为 `question -> answer`，并从结果中提取最终预测答案。

## 如何使用模块 `dspy.Module`？

### 示例 4：组合多个模块 `dspy.Module`

DSPy 就是 Python 代码，使用模块进行控制流。这类似于 PyTorch 的定义式计算图方法。你可以自由地调用和组合模块，创建强大的语言模型程序。参考入门教程了解更多细节。

DSPy 允许组合多个模块，甚至在任何控制流中自由调用模块，类似于 PyTorch 的 "按运行定义"（define-by-run）方法。

```python
class CustomProgram(dspy.Module):
    def __init__(self):
        super().__init__()
        self.cot = dspy.ChainOfThought('question -> answer')
        self.react = dspy.ReAct('question -> answer')

    def forward(self, question):
        cot_response = self.cot(question=question)
        react_response = self.react(question=question)
        return cot_response, react_response

# 使用示例
program = CustomProgram()
question = "使用 ChatGPT 有什么好处？"
cot_response, react_response = program(question=question)
print("cot_response.answer:", cot_response.answer)
print("react_response.answer:", react_response.answer)

# Output
cot_response.answer: ChatGPT 是一种基于大型语言模型的智能助手，由 OpenAI 开发。使用 ChatGPT 有以下几个好处：
...

react_response.answer: 
```

在这个示例中，通过组合 dspy.ChainOfThought 模块和 dspy.ReAct 模块，创建了一个自定义程序。程序使用这两个模块处理一个问题，并返回各自的回复。

可惜react还不成熟，所以即使跑完了所有iteration也还是没有返回结果。等后面成熟了我再写一篇说明文档。

## 其他 DSPy 模块

1. **`dspy.Predict`**：基本预测模块。
2. **`dspy.ChainOfThought`**：逐步思考模块。
3. **`dspy.ProgramOfThought`**：代码生成模块。
4. **`dspy.ReAct`**：可以使用工具的代理模块。
5. **`dspy.MultiChainComparison`**：比较多个输出以生成最终预测。

此外，还有一些函数式模块：

6. **`dspy.majority`**：投票模块，返回最受欢迎的响应。

查看[每个模块的详细指南](https://www.oldcai.com/ai/dspy-8-steps/)获取更多示例。

### 进一步学习

如果你想深入了解如何优化 DSPy 项目，可以参考以下链接：

- [如何为 DSPy 项目收集和准备训练数据](https://www.oldcai.com/ai/dspy-data/)
- [让你的AI系统表现更出色！DSPy指标优化技巧大公开](https://www.oldcai.com/ai/dspy-evaluation/)
- [如何优化 DSPy 签名，从零开始创建一个CoT管道？](https://www.oldcai.com/ai/dspy-signature-optimizer/)
- [DSPy 优化器 optimizer，提升你的 AI 模型性能](https://www.oldcai.com/ai/dspy-optimizers/)
- [DSPy教程：用 DSPy 自动优化大型语言模型 LLM 应用](https://www.oldcai.com/ai/dspy-tutorial/)
- [DSPy思考链ChainOfThought讲解](https://www.oldcai.com/ai/dspy-chain-of-thought/)
- [DSPy引导式少样本学习 - BootstrapFewShot讲解](https://www.oldcai.com/ai/bootstrap-fewshot/)
- [怎样使用DSPy？任何DSPy项目都能套用的8个步骤](https://www.oldcai.com/ai/dspy-8-steps/)

通过这些简单步骤和资源，你可以高效地利用 DSPy 构建和优化你的语言模型程序！

