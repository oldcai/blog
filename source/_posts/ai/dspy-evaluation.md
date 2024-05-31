---
title: 让你的AI系统表现更出色！DSPy指标优化技巧大公开
date: 2024-05-31 21:31:37
tags:
	- DSPy
---

## 什么是指标

指标是一个函数，用于获取数据中的示例和系统的输出，然后返回一个量化输出质量的分数。简单来说，指标就是评价系统输出好坏的标准。

## 如何定义 DSPy 指标？长文本如何评分？

对于简单任务，这个标准可能是“准确率”、“完全匹配”或“F1分数”。但对于大多数应用场景，系统会输出**长文本**，这时指标应该检查输出的多个属性，甚至可能需要使用AI反馈。

初次定义指标时，由简单开始，逐步迭代是关键。

## 简单指标示例

在DSPy中，指标就是一个Python函数，它接收`example`（如训练集或开发集中的样本）和程序的输出`pred`，并返回一个`float`（或`int`或`bool`）分数。

你的指标函数也应该接受一个可选的第三个参数`trace`，虽然暂时可以忽略，但在优化时会派上用场。

以下是一个简单的指标示例，比较`example.answer`和`pred.answer`，返回一个`bool`值。

```python
def validate_answer(example, pred, trace=None):
    return example.answer.lower() == pred.answer.lower()
```

你也可以使用内置的实用工具，比如：
- `dspy.evaluate.metrics.answer_exact_match`
- `dspy.evaluate.metrics.answer_passage_match`

复杂一些的指标示例：

```python
def validate_context_and_answer(example, pred, trace=None):
    answer_match = example.answer.lower() == pred.answer.lower()
    context_match = any((pred.answer.lower() in c) for c in pred.context)
    
    if trace is None:
        return (answer_match + context_match) / 2.0
    else:
        return answer_match and context_match
```

## 如何进行评估？

定义好指标后，可以通过一个简单的Python循环进行评估。

```python
scores = []
for x in devset:
    pred = program(**x.inputs())
    score = metric(x, pred)
    scores.append(score)
```

你也可以使用内置的`Evaluate`实用工具，帮助并行评估和展示结果。

```python
from dspy.evaluate import Evaluate

evaluator = Evaluate(devset=YOUR_DEVSET, num_threads=1, display_progress=True, display_table=5)
evaluator(YOUR_PROGRAM, metric=YOUR_METRIC)
```

对于大多数应用场景，系统会输出长文本，指标应检查输出的多个维度，甚至可以利用AI反馈。

## 高级：使用DSPy程序作为指标

如果你的指标本身是一个DSPy程序，可以通过优化它来迭代改进。这通常很容易，因为指标的输出是一个简单的值（如分数），可以通过收集示例来定义和优化。

### 高级：访问`trace`

在评估运行时，DSPy不会跟踪程序的步骤。但在优化期间，DSPy会跟踪你的语言模型调用。你可以利用这些跟踪信息来验证中间步骤。

```python
def validate_hops(example, pred, trace=None):
    hops = [example.question] + [outputs.query for *_ , outputs in trace if 'query' in outputs]

    if max([len(h) for h in hops]) > 100:
        return False
    if any(dspy.evaluate.answer_exact_match_str(hops[idx], hops[:idx], frac=0.8) for idx in range(2, len(hops))):
        return False

    return True
```

定义和优化指标是一个迭代过程，简单开始，逐步改进，借助AI反馈不断优化你的系统输出。希望这篇指南对你有所帮助，祝你在使用DSPy的过程中取得好成绩！

