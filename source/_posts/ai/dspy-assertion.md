---
title: 利用 Assert 和 Suggest 断言优化 DSPy 应用
date: 2024-06-06 01:35:13
tags:
	- DSPy
---

### DSPy Assertion 是什么

当单独靠 metrics 不足以训练出复杂的要求，或需要更大的成本才能训练出符合要求的训练结果，Assert 和 `Suggest` 断言就会十分好用。DSPy Assertions是引导你的LLM朝着期望结果前进的关键工具。它们旨在提高可重复性，提升结果质量，并确保项目的可预测性。

- **dspy.Assert**：像严厉负责的教练，如果没有达到要求，它不仅要求重做，还会动态调整计划。如果问题持续存在，它会停止执行并抛出`dspy.AssertionError`。
- **dspy.Suggest**：像温和耐心的老师，重新尝试时更为灵活，不会严格惩罚，适合评估阶段。

`dspy.Suggest` 和 `dspy.Assert` 都是在 `forward` 中就能使用。它们都巧妙地利用了回溯机制优化模型。

下面，用两个例子讲讲怎样使用它们。

### 1. 确保输出格式

目标：确保输出的项目包含超过两个，并用逗号分隔。

```python
import re
from dspy.primitives.assertions import assert_transform_module, backtrack_handler


def check_format(action_items):
  """Check that the action items are a list of comma-separated action items"""
  if len(action_items.split(",")) == 1:
    return False
  match = re.search(r'(\d)\.\s.+?(\\n|$)', action_items, re.MULTILINE)
  if match:
    return False
  return True

class GenerateExampleWithAssert(dspy.Module):
  def __init__(self):
    super().__init__()
    self.generate_example = dspy.ChainOfThought(TranscriptExample)
  
  def forward(self):
    ex = self.generate_example(**varying_temp())
    dspy.Assert(check_format(ex.action_items), "Action Items should be a comma-separated list")
    return ex

dspy.configure(trace=[])

generate_with_assert = assert_transform_module(GenerateExampleWithAssert(), backtrack_handler)

example = generate_with_assert()

print(example)
```

### 2. 多断言

目标：设计了一个专门用于验证的DSPy程序，为了验证项目列表是不是正确地包含了记录的内容。

```python
class ActionItemCompliance(dspy.Signature):
  """Check that all action items are included in the text"""
  text = dspy.InputField()
  action_items = dspy.InputField(desc="A comma-separated list of action items")
  comply : bool = dspy.OutputField(desc="True or False")

check_inclusion = dspy.TypedChainOfThought(ActionItemCompliance)

def are_action_items_included(transcript, action_items):
  comp = check_inclusion(text=transcript, action_items=action_items)
  return comp.comply

print(are_action_items_included(example.transcript, example.action_items))
# output: True
```

然后我们将之前的Assert整合到`GenerateExampleWithAssert`函数中。

```python
class GenerateExampleWith2Assert(dspy.Module):
  def __init__(self):
    super().__init__()
    self.generate_example = dspy.ChainOfThought(TranscriptExample)
  
  def forward(self):
    ex = self.generate_example(**varying_temp())
    dspy.Assert(check_format(ex.action_items), "Action Items should be a comma-separated list")
    dspy.Assert(are_action_items_included(ex.transcript, ex.action_items), "Action Items should be included in the transcript")
    return ex
  
generate_with_assert = assert_transform_module(GenerateExampleWith2Assert(), backtrack_handler)

example = generate_with_assert()
print(example)
# output: True
```

### 生成大量示例

目标：生成一批不重复的demo数据，以便后续使用。

这次，我们将使用`Suggest`而不是`Assert`，以保证生成过程不会因为异常而中断（多次不满足Assert会raise exception: `dspy.AssertionError`）。

```python
import json

class GenerateExampleWith2Suggest(dspy.Module):
  def __init__(self):
    super().__init__()
    self.generate_example = dspy.ChainOfThought(TranscriptExample)
  
  def forward(self):
    ex = self.generate_example(**varying_temp())
    dspy.Suggest(check_format(ex.action_items), "Action Items should be a comma-separated list")
    dspy.Suggest(are_action_items_included(ex.transcript, ex.action_items), "Action Items should be included in the transcript")
    return ex

generate_with_suggest = assert_transform_module(GenerateExampleWith2Suggest(), backtrack_handler)

examples = []
for i in range(1, 20):
  with dspy.context(cache_turn_on=False):
    ex = generate_with_suggest()
    print(ex)
  examples.append({"transcription": ex.transcript, "action_items": ex.action_items})

with open('examples.json', 'w') as f:
  json.dump(examples, f)
```

最终，我们成功生成了一系列示例，展示了各种风格和行动项目。

可能以后再多添加一些`Suggest`干预还能进一步提升多样性。


### 进一步学习

接下来，我们学习一下提示修改的原则，讨论如何创建可重用的提示，简化过程，生成一个可以多次使用的精心调整的提示词。

- [DSPy 优化器 optimizer，提升你的 AI 模型性能](https://www.oldcai.com/ai/dspy-optimizers/)
- [用 COPRO 优化 DSPy Signature](https://www.oldcai.com/ai/dspy-signature-optimizer/)
- [DSPy指标定义和优化技巧大公开](https://www.oldcai.com/ai/dspy-evaluation/)

如果你想深入了解如何优化 DSPy 项目，可以参考以下链接：

- [如何为 DSPy 项目收集和准备训练数据](https://www.oldcai.com/ai/dspy-data/)
- [DSPy教程：用 DSPy 自动优化大型语言模型 LLM 应用](https://www.oldcai.com/ai/dspy-tutorial/)
- [DSPy思考链ChainOfThought讲解](https://www.oldcai.com/ai/dspy-chain-of-thought/)
- [DSPy引导式少样本学习 - BootstrapFewShot讲解](https://www.oldcai.com/ai/bootstrap-fewshot/)
- [怎样使用DSPy？任何DSPy项目都能套用的8个步骤](https://www.oldcai.com/ai/dspy-8-steps/)


