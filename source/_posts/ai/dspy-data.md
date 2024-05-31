---
title: 如何为 DSPy 项目收集和准备训练数据
date: 2024-06-01 00:14:14
tags:
	- DSPy
---

DSPy 是一个机器学习框架，使用它时需要训练集、开发集和测试集。

## 需要多少数据？

* 只需 10 个示例输入就可以开始使用 DSPy 进行优化
* 但拥有 50-100 个示例会更理想
* 如果有 300-500 个就再好不过了

### 获取示例数据

1. **手动准备**：如果任务非常特殊，手动准备大约 10 个示例。
2. **利用现有数据**：在 HuggingFace 数据集或其他开放数据源上查找相似任务的数据。
3. **收集初始数据**：部署或演示系统，收集一些初始数据。

## DSPy `Example` 对象

DSPy 的核心数据类型是 `Example`，用于表示训练集和测试集中的项目。

### 创建 `Example`

`Example` 类似于 Python 的 `dict`，但有一些额外功能。您的 DSPy 模块会返回 `Prediction`，它是 `Example` 的子类。

```python
qa_pair = dspy.Example(question="这是问题？", answer="这是答案。")
print(qa_pair)
print(qa_pair.question)
print(qa_pair.answer)
```

**输出:**

```
Example({'question': '这是问题？', 'answer': '这是答案。'}) (input_keys=None)
这是问题？
这是答案。
```

示例可以有任何字段键和值类型，通常值是字符串。

```python
object = Example(field1=value1, field2=value2, field3=value3, ...)
```

### 表示训练集

```python
trainset = [
    dspy.Example(report="长报告 1", summary="短总结 1"),
    dspy.Example(report="长报告 2", summary="短总结 2"),
    ...
]
```

### 指定输入键

在传统机器学习中，分开“输入”和“标签”。在 DSPy 中，可以使用 `with_inputs()` 方法将特定字段标记为输入。

```python
# 单个输入
print(qa_pair.with_inputs("question"))

# 多个输入
print(qa_pair.with_inputs("question", "answer"))
```

### 访问数据的属性

使用 `.` 操作符访问值，例如 `object.name`。

使用 `inputs()` 和 `labels()` 方法分别返回仅包含输入键或非输入键的新 Example 对象。

```python
article_summary = dspy.Example(article="这是一篇文章。", summary="这是总结。").with_inputs("article")

input_key_only = article_summary.inputs()
non_input_key_only = article_summary.labels()

print("仅包含输入字段的 Example 对象:", input_key_only)
print("仅包含非输入字段的 Example 对象:", non_input_key_only)
```

**输出**

```
仅包含输入字段的 Example 对象: Example({'article': '这是一篇文章。'}) (input_keys=None)
仅包含非输入字段的 Example 对象: Example({'summary': '这是总结。'}) (input_keys=None)
```

希望这篇 DSPy 数据准备指南对你有帮助！

