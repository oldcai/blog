---
title: DSPy思考链ChainOfThought讲解
date: 2024-05-28 01:24:13
tags:
    - DSPy
---

构造函数初始化 `ChainOfThought` 类并设置其属性。它继承自 `Predict` 类，并为链式思维处理增加了特定功能。

在内部，该类初始化了 `activated` 属性，用于指示是否选择了链式思维处理。当激活链式思维处理时，它扩展了 `signature`，以包括额外的推理步骤和更新的 `rationale_type`。

```python
class ChainOfThought(Predict):
    def __init__(self, signature, rationale_type=None, activated=True, **config):
        super().__init__(signature, **config)
        self.activated = activated
        signature = ensure_signature(self.signature)
        *_keys, last_key = signature.output_fields.keys()
        rationale_type = rationale_type or dspy.OutputField(
            prefix="Reasoning: Let's think step by step in order to",
            desc="${produce the " + last_key + "}. We ...",
        )
        self.extended_signature = signature.prepend("rationale", rationale_type, type_=str)
```

该方法在激活链式思维推理或语言模型为 GPT-3 模型时，扩展了父类 `Predict` 的前向传播方法并更新了签名。

```python
#定义一个简单的签名用于基本问答
class BasicQA(dspy.Signature):
    """用简短的事实回答问题。"""
    question = dspy.InputField()
    answer = dspy.OutputField(desc="通常在1到5个单词之间")

#将签名传递给 ChainOfThought 模块
generate_answer = dspy.ChainOfThought(BasicQA)

#对特定输入调用预测器
question='天空是什么颜色的？'
pred = generate_answer(question=question)
print(f"问题: {question}")
print(f"预测答案: {pred.answer}")
```

以下示例展示了如何指定自定义推理类型。在此示例中，`answer` 对应于要生成的最后一个键，在您的情况下可能会有所不同。

```python
#定义一个自定义推理类型
rationale_type = dspy.OutputField(
    prefix="Reasoning: Let's think step by step in order to",
    desc="${produce the answer}. We ...",
)

#将签名传递给 ChainOfThought 模块
generate_answer = dspy.ChainOfThought(BasicQA, rationale_type=rationale_type)
```



## 相关资料

[英文版](https://dspy-docs.vercel.app/api/modules/ChainOfThought)

