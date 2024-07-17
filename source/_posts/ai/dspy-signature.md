---
title: 什么是DSPy签名（Signature）？如何定义和使用？
date: 2024-05-30 21:48:43
tags:
	- DSPy
---
# 理解签名

DSPy 签名是任务描述的最基本形式，它仅需输入和输出字段，并且可以选择性地提供关于它们和任务的小描述。

有两种定义签名的方式：**内联**和**基于类**。但在深入了解如何创建签名之前，让我们先理解什么是签名以及为什么需要它。

## 什么是签名？

在典型的 LLM 管道中，您会有两个关键组件在工作，即 LLM（大型语言模型）和提示。在 DSPy 中，我们在任何 DSPy 脚本的开头通过 LM（语言模型 - 将在下一个博客中展示）配置 LLM，并通过**签名**定义提示。

一个签名通常由两个基本组件组成：**输入字段**和**输出字段**。您可以选择性地传递一个定义任务更详细要求的指令。一个**输入字段**是签名的一个属性，定义提示的输入，而**输出字段**是签名的一个属性，定义从 LLM 调用中接收到的提示输出。让我们通过一个例子来理解这一点。

![DSPy 签名](https://i.imgur.com/m7uIquU.png)

让我们想象一个基本的问答任务，其中问题作为 LLM 的输入，从中您收到一个答案响应。我们在 DSPy 中直接映射这个，因为问题作为签名的**输入字段**，答案作为签名的**输出字段**。

现在我们了解了签名的组件，让我们看看如何声明签名以及该签名的提示是什么样子的。

## 内联方法

DSPy 提供了一种直观、简单的方法来定义任务：简单地陈述输入和输出，以最简单的形式传达任务。例如，如果您的输入是**问题**，输出是**答案**，则应明确任务是一个问答任务。如果您的输入是**上下文**和**问题**，输出是**答案**和**理由**，这应暗示某种形式的思维链提示，可能在 RAG 管道中。

受这种简洁性的启发，DSPy 签名模仿了一种类似 Einops 的抽象方式：

```
input_field_1,input_field_2,input_field_3...->output_field_1,output_field_2,output_field_3...
```

签名的**输入字段**在 `->` 左侧声明，**输出字段**在右侧声明。因此，让我们为 QA 和 RAG 任务定义 DSPy 签名：

```
QA 任务：question->answer
RAG 任务：context,question->answer,rationale
```

这种字段的简明命名对于 LLM 理解输入和输出的性质至关重要，减少敏感性并确保预期输入和生成的清晰性。

然而，这种简单的签名可能无法提供模型如何处理任务的清晰图片，为了满足这些需求，DSPy 模块提供了简洁而强大的指令模板，这些模板集成了签名。让我们深入了解 DSPy 在 `dspy.Predict` 模块中使用 `dspy.Predict(question->answer)` 时构建的提示：

```
给定字段 `question`，生成字段 `answer`。

---

遵循以下格式。

问题：${question}
答案：${answer}

---

问题：
```

如您所见，DSPy 填充了指令 ``给定字段 `question`，生成字段 `answer`。`` 以定义任务，并提供了提示格式的指令。对于您创建的任何签名，这种格式都是非常标准的，因为我们可以在 RAG 的提示设置中看到：

![内联提示创建](https://i.imgur.com/3zIYKPR.png)

这些指令模板针对其各自的提示技术（CoT、ProgramOfThought、ReAct）定义得很好，用户只需定义其任务的签名输入和输出，其余由 DSPy 模块库处理！

但是，有时候，简单内联签名不太够用。好在我们有基于类的签名。

## 基于类的方法

签名类包括三件事：

-   **任务描述/指令：**我们在签名类的文档字符串中定义。
-   **输入字段：**我们将其定义为 `dspy.InputField()`。
-   **输出字段：**我们将其定义为 `dspy.OutputField()`。

```
class BasicQA(dspy.Signature):
    """用简短的事实性答案回答问题。"""

    question = dspy.InputField()
    answer = dspy.OutputField(desc="通常在1到5个单词之间", prefix="问题的答案：")
```

I/O 字段有三个输入：`desc`、`prefix` 和 `format`。`desc` 是输入的描述，`prefix` 是提示字段的占位符文本（直到现在一直是 `${field_name}`），`format` 是定义如何处理非字符串输入的方法。如果字段的输入是列表而不是字符串，我们可以通过 `format` 指定。

`InputField` 和 `OutputField` 的实现也非常相似：

```
class InputField(Field):
    def __init__(self, *, prefix=None, desc=None, format=None):
        super().__init__(prefix=prefix, desc=desc, input=True, format=format)

class OutputField(Field):
    def __init__(self, *, prefix=None, desc=None, format=None):
        super().__init__(prefix=prefix, desc=desc, input=False, format=format)
```

让我们看看基于类的签名的提示是怎样的：

```
用简短的事实性答案回答问题。

---

遵循以下格式。

问题：${question}
问题的答案：通常在1到5个单词之间

---

问题：
```

指令通过我们的任务指令在文档字符串中定义得更明确。`answer` 字段的前缀和描述反映了我们的定义。这确保了更精细的提示结构，使用户能够根据任务要求更好地控制定义其内容。

![基于类的提示创建](https://i.imgur.com/OON1e50.png)

