---
title: 让你的AI系统表现更出色！DSPy指标优化技巧大公开
date: 2024-05-31 21:31:37
tags:
	- DSPy
---

## 什么是指标

指标是一个函数，用于获取数据中的示例和系统的输出，然后返回一个量化输出质量的分数。简单来说，指标就是评价系统输出好坏的标准。

## 如何定义 DSPy 指标？

对于简单任务，这个标准可能是“准确率”、“完全匹配”或“F1分数”。
但对于大多数应用场景，系统会输出**长文本**，这时，我们可能需要综合多个简单指标，甚至可能需要使用更聪明的方法。我们接下来会详细讲解。

初次定义指标时，由简单开始，逐步迭代是关键。

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

## 高级 DSPy 指标

### 多个简单指标叠加示例

```python
def validate_context_and_answer(example, pred, trace=None):
    answer_match = example.answer.lower() == pred.answer.lower()
    context_match = any((pred.answer.lower() in c) for c in pred.context)
    
    if trace is None:
        return (answer_match + context_match) / 2.0
    else:
        return answer_match and context_match
```

### 长文本如何评分？（更聪明的方法）

聪明的我们，可以通过使用 AI 自己的能力，通过使用另一个 DSPy 程序给长文打分。
懂得递归的朋友肯定会说，这题我熟。
如果你的指标本身是一个DSPy程序，可以优化它本身后，再来迭代改进最终的程序。

这个评分 DSPy 程序一般不会特别复杂，因为输出的指标是一个简单的值（如分数），可以通过收集示例来定义和优化。

#### DSPy 评分程序举例

例如，下面是一个简单的指标，使用 GPT-4o 检查生成的推文。

这个评分程序给出评分问题的答案，评分问题甚至可以在metric中自定义。

```python
# 定义自动评分程序的签名。
class Assess(dspy.Signature):
    """根据指定维度评估推文的质量。"""

    assessed_text = dspy.InputField()
    assessment_question = dspy.InputField()
    assessment_answer = dspy.OutputField(desc="Yes or No")
```

1. 是否正确回答了给定问题
2. 是否具有吸引力
3. 检查长度 `<= 280` 字符。

```python
gpt4o = dspy.OpenAI(model='GPT-4o', max_tokens=1000, model_type='chat')

def metric(gold, pred, trace=None):
    question, answer, tweet = gold.question, gold.answer, pred.output

    engaging = "Does the assessed text make for a self-contained, engaging tweet?"
    correct = f"The text should answer `{question}` with `{answer}`. Does the assessed text contain this answer?"

    with dspy.context(lm=gpt4o):
        correct = dspy.Predict(Assess)(assessed_text=tweet, assessment_question=correct)
        engaging = dspy.Predict(Assess)(assessed_text=tweet, assessment_question=engaging)

    correct, engaging = [m.assessment_answer.lower() == 'yes' for m in [correct, engaging]]
    score = (correct + engaging) if correct and (len(tweet) <= 280) else 0

    if trace is not None:
        return score >= 2
    return score / 2.0
```

在编译时，如果`trace is not None`，我们需要严格判断事情，所以只有在`score >= 2`时返回`True`。否则，我们返回一个1.0的分数（即`score / 2.0`）。


### 访问`trace`

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

## 推荐阅读

- [准备 DSPy 训练数据](https://www.oldcai.com/ai/dspy-data/)

- [DSPy教程：用 DSPy 自动优化大型语言模型 LLM 应用](https://www.oldcai.com/ai/dspy-tutorial/)
    
- [DSPy思考链ChainOfThought讲解](https://www.oldcai.com/ai/dspy-chain-of-thought/)
    
- [DSPy引导式少样本学习 - BootstrapFewShot讲解](https://www.oldcai.com/ai/bootstrap-fewshot/)
    
- [怎样使用DSPy？任何DSPy项目都能套用的8个步骤](https://www.oldcai.com/ai/dspy-8-steps/)

定义和优化 DSPy 指标是一个迭代过程，简单开始，逐步改进，借助AI反馈不断优化你的系统输出。希望这篇指南对你有所帮助，让 DSPy 帮你如翼添虎😂

