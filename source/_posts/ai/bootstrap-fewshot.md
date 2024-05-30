---
title: DSPy引导式少样本学习 - BootstrapFewShot讲解
date: 2024-05-28 00:56:26
tags:
    - DSPy
---

在编译 DSPy 程序时，我们通常会调用一个称为 `teleprompter` 的优化器。它接受程序、训练集和度量标准，并返回一个优化后的新程序。
不同的 teleprompters 使用不同的优化策略。本系列 teleprompters 专注于优化 few-shot 示例。让我们通过一个示例管道来了解 teleprompter 如何优化它。

## 设置管道

我们将基于 `GSM8K` 数据集创建一个基础答案生成管道，这与 [最小示例](https://dspy-docs.vercel.app/docs/quick-start/minimal-example) 中的例子类似，不做任何修改！首先，配置语言模型（LM），使用 `gpt-3.5-turbo` 作为 LLM。

```python
import dspy

turbo = dspy.OpenAI(model='gpt-3.5-turbo', max_tokens=250)
dspy.settings.configure(lm=turbo)
```

现在我们已经设置了 LM 客户端，接下来导入 `GSM8k` 类中的训练集和验证集：

```python
from dspy.datasets.gsm8k import GSM8K, gsm8k_metric

gms8k = GSM8K()

trainset, devset = gms8k.train, gms8k.dev
```

我们将定义一个基础的问答（QA）内联签名，即 `question -> answer`，并将其传递给 `ChainOfThought` 模块，以应用必要的 [CoT（Chain of Thought）](/ai/dspy-chain-of-thought/)样式提示到签名中。

```python
class CoT(dspy.Module):
    def __init__(self):
        super().__init__()
        self.prog = dspy.ChainOfThought("question -> answer")
    
    def forward(self, question):
        return self.prog(question=question)
```

现在我们需要评估这个管道！我们将使用 DSPy 提供的 `Evaluate` 类，度量标准使用上面导入的 `gsm8k_metric`。

```python
from dspy.evaluate import Evaluate

evaluate = Evaluate(devset=devset[:], metric=gsm8k_metric, num_threads=NUM_THREADS, display_progress=True, display_table=False)
```

要评估 `CoT` 管道，我们需要创建一个它的对象，并将其作为参数传递给 `evaluator` 调用。

```python
cot_baseline = CoT()

evaluate(cot_baseline, devset=devset[:])
```

现在我们已经准备好了基线管道，接下来尝试使用 `BootstrapFewShot` teleprompter 来优化我们的管道，使其更好！

## 使用 `BootstrapFewShot`

首先导入并初始化我们的 teleprompter，度量标准使用上面导入和使用的 `gsm8k_metric`：

```python
from dspy.teleprompt import BootstrapFewShotWithRandomSearch

teleprompter = BootstrapFewShotWithRandomSearch(
    metric=gsm8k_metric, 
    max_bootstrapped_demos=8, 
    max_labeled_demos=8,
)
```

`metric` 是一个显而易见的参数，但 `max_bootstrapped_demos` 和 `max_labeled_demos` 参数是什么呢？

让我们通过一个表格来看看它们的区别：

| 特性 | `max_labeled_demos` | `max_bootstrapped_demos` |
| --- | --- | --- |
| **目的** | 指定用于训练学生模块的最大标记演示（示例）数量。标记演示通常是预先存在的手动标记示例，模块可以从中学习。 | 指定将被引导生成的最大演示数量。引导在此上下文中可能意味着基于教师模块的预测生成新的训练示例。这些引导的演示随后与手动标记的示例一起或代替它们使用。 |
| **训练使用** | 直接用于训练；由于手动标记，通常更可靠。 | 增加训练数据；由于它们是生成的示例，可能不太准确。 |
| **数据来源** | 预先存在的手动标记示例数据集。 | 在训练过程中生成，通常使用教师模块的输出。 |
| **对训练的影响** | 更高的质量和可靠性，假设标签是准确的。 | 提供更多数据，但可能引入噪音或不准确性。 |

这个 teleprompter 会增强任何必要的字段，即使你的数据没有这些字段。例如，我们没有标记推理，但你会在该 teleprompter 精选的每个 few-shot 示例的提示中看到推理。这是怎么做到的？通过生成它们，使用一个 `teacher` 模块，这是一个可选参数。如果我们没有传递这个参数，teleprompter 会使用我们正在训练的模块或 `student` 模块来创建一个教师模块。

在下一部分，我们将逐步看到这个过程，但现在让我们通过调用 teleprompter 的 `compile` 方法来优化我们的 `CoT` 模块：

```python
cot_compiled = teleprompter.compile(CoT(), trainset=trainset, valset=devset)
```

一旦训练完成，你将拥有一个更优化的模块，你可以随时保存或加载使用：

```python
cot_compiled.save('turbo_gsm8k.json')

# 加载：
# cot = CoT()
# cot.load('turbo_gsm8k.json')
```

## `BootstrapFewShot` 如何工作？

`LabeledFewShot` 是最基础的 teleprompter，它接受一个训练集作为输入，并将训练集的子集分配给每个学生预测器的 demos 属性。你可以将其理解为向提示中添加 few-shot 示例。

`BootstrapFewShot` 开始时也是这样做的，具体步骤如下：

1. 初始化一个学生程序（即我们正在优化的程序）和一个教师程序（如果没有特别指定，通常是学生程序的克隆）。
    
2. 然后使用 `LabeledFewShot` teleprompter 向教师添加示例。
    
3. 创建预测器名称与学生和教师模型中对应实例之间的映射。
    
4. 确定最大引导演示数量（`max_bootstraps`）。这限制了生成的初始训练数据量。
    
5. 遍历训练集中的每个示例。对于每个示例，检查是否已达到最大引导数量。如果是，则停止。
    
6. 对于每个训练示例，教师模型尝试生成预测。
    
7. 如果教师模型成功生成预测，则捕获此预测过程的轨迹。该轨迹包括关于哪些预测器被调用、它们收到的输入以及生成的输出的详细信息。

8. 如果预测成功，为轨迹中的每个步骤创建一个演示（demo）。该演示包括预测器的输入和生成的输出。


这就是其工作原理。此外，还有 `BootstrapFewShotWithOptuna`、`BootstrapFewShotWithRandomSearch` 等，它们的工作原理相同，只是在示例发现过程中有细微变化。

## 相关资料

[英文版](https://dspy-docs.vercel.app/docs/deep-dive/teleprompter/bootstrap-fewshot)


