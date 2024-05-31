---
title: 如何优化 DSPy 签名，从零开始创建一个CoT管道？
date: 2024-05-31 15:14:25
tags:
	- DSPy
---

# 签名优化器

`COPRO`是一个旨在改进模块签名前缀和指令的工具，特别适用于零/少样本设置。这对于微调语言模型的提示非常有用，可以确保它们从模糊和不完善的提示中更有效地执行任务。

## 设置示例管道

首先，我们需要配置LM（语言模型）客户端，这里使用`gpt-3.5-turbo`。

```python
import dspy

turbo = dspy.OpenAI(model='gpt-3.5-turbo')
dspy.settings.configure(lm=turbo)
```

接着，我们导入`HotPotQA`数据集，并进行训练集和开发集的拆分：

```python
from dspy.datasets import HotPotQA

dataset = HotPotQA(train_seed=1, train_size=20, eval_seed=2023, dev_size=50, test_size=0)

trainset, devset = dataset.train, dataset.dev
```

现在，我们定义一个用于QA任务的类签名，并传递给`ChainOfThought`模块：

```python
class CoTSignature(dspy.Signature):
    """回答问题并给出理由。"""
    
    question = dspy.InputField(desc="关于某事的问题")
    answer = dspy.OutputField(desc="通常在1到5个字之间")

class CoTPipeline(dspy.Module):
    def __init__(self):
        super().__init__()
        self.signature = CoTSignature()
        self.predictor = dspy.ChainOfThought(self.signature)

    def forward(self, question):
        result = self.predictor(question=question)
        return dspy.Prediction(
            answer=result.answer,
            reasoning=result.rationale,
        )
```

我们还需要评估这个管道，为此我们使用`Evaluate`类，并定义一个验证函数`validate_context_and_answer`：

```python
from dspy.evaluate import Evaluate

def validate_context_and_answer(example, pred, trace=None):
    return dspy.evaluate.answer_exact_match(example, pred)

NUM_THREADS = 5
evaluate = Evaluate(devset=devset, metric=validate_context_and_answer, num_threads=NUM_THREADS, display_progress=True, display_table=False)
```

最后，我们创建`CoTPipeline`对象并进行评估：

```python
cot_baseline = CoTPipeline()

devset_with_input = [
    dspy.Example({"question": r["question"], "answer": r["answer"]}).with_inputs("question") 
    for r in devset
]
evaluate(cot_baseline, devset=devset_with_input)
```

## 使用`COPRO`优化

接下来，我们使用`COPRO`优化提示器。首先，导入并初始化：

```python
from dspy.teleprompt import COPRO

teleprompter = COPRO(
    metric=validate_context_and_answer,
    verbose=True,
)
```

然后，我们调用`compile`方法开始优化：

```python
kwargs = dict(num_threads=64, display_progress=True, display_table=0)

compiled_prompt_opt = teleprompter.compile(cot_baseline, trainset=devset, eval_kwargs=kwargs)
```

优化完成后，我们根据输出结果手动更新签名类：

```python
class CoTSignature(dspy.Signature):
    """请回答问题并提供你的理由。你的回答应该清晰且详细，解释你决定的理由。请确保你的回答是有理有据的，并通过相关解释和例子支持。"""

    question = dspy.InputField(desc="关于某事的问题")
    reasoning = dspy.OutputField(desc="回答的理由", prefix="[理由]")
    answer = dspy.OutputField(desc="通常在1到5个字之间")
```

重新初始化Pipeline对象并重新评估管道，现在你就拥有了一个更强大的预测器！

## `COPRO`的工作原理

`COPRO`使用签名来优化签名。其核心是两个签名类：`BasicGenerateInstruction`和`GenerateInstructionGivenAttempts`。

1. **起点**：使用`BasicGenerateInstruction`生成初始指令和前缀。
2. **迭代改进**：将这些初始指令传递给`GenerateInstructionGivenAttempts`。
3. **重复优化**：在每次迭代中评估当前指令，并提出新的更优化的指令和前缀。
4. **结果**：经过多次迭代，系统会收敛到一组高度优化的指令和前缀，使语言模型在任务中表现更好。

这种迭代方法利用提示器的优势，随着时间的推移不断改进任务性能。

![Signature Optimizer](https://i.imgur.com/fBWuhaM.png)

通过`COPRO`，你可以轻松提升语言模型的任务执行效果，从而在实际应用中取得更好的成果。

