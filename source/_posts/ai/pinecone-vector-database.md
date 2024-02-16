---
title: 从0开始写出一个基于语义的Pdf搜索、对话的大模型RAG应用
date: 2024-02-05 20:16:04
tags:
    - Pinecone
    - 向量数据库
    - GPT
    - Embedding
    - LangChain
    - 大模型
    - RAG
---

今天老蔡带你一步步动手用GPT做Embedding，用Pinecone做向量数据库Vector Database，做一个用语义搜索PDF并借助ChatGPT用PDF内容和你对话的小应用。

前情提要：

- 向量数据库及其作用
- Pinecone的基本概念
- Embedding技术
- 在Python中使用Pinecone
- 用LangChain构建问答回答链，实现与数据的互动对话

之前老蔡探讨了如何[怎样在Mac上用GPU训练深度学习模型](https://www.oldcai.com/ai/pytorch-train-MNIST-with-gpu-on-mac/)。今天来上手自然语言处理。

这篇讲讲如何使用Python将PDF文件存储到Pinecone向量数据库，并构建基于GPT-4的聊天机器人，它能够针对文件内容进行问答回复。

**什么是向量数据库：**

首先，我们来了解一下什么是向量数据库，以及它们为何能高效处理复杂数据类型。

向量（或嵌入）本质上是数字数组。这些数组不仅能够表达基本数据，还能表示文本、图像、音频甚至视频等复杂数据类型。特别是在处理文本数据时，这些向量旨在捕捉词汇之间的语义和句法关系，从而让算法更加有效地理解和处理语言。

而向量数据库就是用来存储这些向量的，查询方式也和SQL数据库不同。

当然，除了Pinecone，还有其他向量数据库供应商，如Chroma、Milvus和Weaviate，也提供了嵌入式数据库的解决方案。

词嵌入(Embedding)技术特指一种能够根据词在大量文本中的上下文关系，将词义编码成高维空间内的密集向量表示形式，使得语义相近的词在这个空间中彼此靠近。这一过程是在向量数据库中完成的。

嵌入的创建依赖于嵌入模型，存在多种可用的嵌入模型。在本文中，我将采用OpenAI的嵌入模型`text-embedding-3-small`来实现。

嵌入的制作过程可以通过以下方式来形象化展现。

![embedding](https://cdn.openai.com/new-and-improved-embedding-model/draft-20221214a/vectors-3.svg)


接下来，我们将介绍如何将生成的嵌入存储于向量数据库，并以此为基础，创建GPT-4聊天机器人。
这个机器人能够利用数据库中的信息来回答问题。提问时，问题本身也会被转化为嵌入，并通过相似性搜索，由检索系统找到并返回最匹配的数据以构造回答。随后，大型语言模型（LLM）将提供连贯且结构严谨的回答。

**Pinecone简介：**

Pinecone是全托管的向量数据库服务，旨在简化生产级应用中向量搜索的集成。作为商业产品，Pinecone并非开源，但它专为可扩展性和高性能而设计，适用于包括搜索引擎、自然语言处理、机器学习和推荐系统等多种应用场景。

对于需要在其生产应用中部署可扩展、高效能向量数据库的企业来说，Pinecone是理想的选择。它不仅使用和管理简便，而且提供了丰富的功能特性：

- **完全托管服务：**Pinecone提供完全托管的数据库服务，免除了用户对底层基础设施的担忧，包括维护和配置等，让用户可以专注于应用开发。
- **可扩展性：**随着数据量和用户数的增长，Pinecone支持灵活扩展，满足不断增长的业务需求。
- **高性能：**Pinecone致力于提供高效的数据处理能力，确保用户能够充分利用其数据资源。
- **易于使用：**Pinecone的用户界面友好，管理简便，帮助用户快速上手和部署。

### 安装LangChain等库

```
pip install -U pinecone-client
pip install -U langchain
pip install -U langchain-community
pip install -U langchain-openai
pip install -U pypdf
```

首先，安装并引入我们将要使用的库，通过运行`!pip install langchain --upgrade`来更新langchain库，以及`!pip install pypdfp`来安装处理PDF的库。如果你在处理非结构化PDF时遇到问题，可以尝试使用`PyPDFLoader`。


### 加载PDF文档

`load_pdf.py`

```
from langchain_community.document_loaders import PyPDFLoader
# from langchain_community.document_loaders import UnstructuredPDFLoader, OnlinePDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter

loader = PyPDFLoader("data/NIPS-2017-attention-is-all-you-need-Paper.pdf")
data = loader.load()

# loader = UnstructuredPDFLoader("./data/textbook.pdf")
# loader = OnlinePDFLoader("...")

print(f'{len(data)} pdfs')
print(f'{len(data[0].page_content)} characters')

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(data)

print(f'{len(texts)} documents')
```

Output:
```
11 pdfs
2903 characters
39 documents
```


通过创建一个`PyPDFLoader`加载器来加载这份PDF文件，并通过`loader.load()`方法读取数据。如果你的PDF文件是非结

构化的或者你想从网络上加载PDF，也可以使用`UnstructuredPDFLoader`或`OnlinePDFLoader`。

接着，我们可以检查上传文件包含的文档和字符数量。如果你使用的是`PyPDFLoader`，文本将已经被按页分割。

为了更好地处理和嵌入数据，我们需要将数据分割成更小的块。块的大小应根据文档的长度来确定，并且可以调整块之间的重叠字符数量，以确保分割后的块不会太小。如果你也使用`PyPDFLoader`，这将是第二次分割操作。

通过设置分割参数并运行分割操作，我们将原始文档分割成了41个更小的文档块，为后续的嵌入和处理工作做好准备。

### 处理PDF文档

`config.py`

```
OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY', 'sk-...')
PINECONE_API_KEY = os.environ.get('PINECONE_API_KEY', '...')
PINECONE_INDEX_NAME = os.environ.get('PINECONE_INDEX_NAME', 'pdf-guru-index')
```

`init_pinecone.py`

```
import time

from pinecone import Pinecone, ServerlessSpec

from config import PINECONE_API_KEY, PINECONE_INDEX_NAME

pc = Pinecone(api_key=PINECONE_API_KEY)
pc.create_index(
    name=PINECONE_INDEX_NAME, dimension=1536, metric="cosine",
    spec=ServerlessSpec(
        cloud="aws",
        region="us-west-2"
    )
)
while not pc.describe_index(PINECONE_INDEX_NAME).status['ready']:
    print(".", end="")
    time.sleep(1)
print("success")
```

`index_pdf.py`

```
import os

from langchain_community.vectorstores import Pinecone
from langchain_openai.embeddings import OpenAIEmbeddings
from config import OPENAI_API_KEY, PINECONE_API_KEY, PINECONE_INDEX_NAME
from langchain_community.document_loaders import PyPDFLoader
# from langchain_community.document_loaders import UnstructuredPDFLoader, OnlinePDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter

loader = PyPDFLoader("data/NIPS-2017-attention-is-all-you-need-Paper.pdf")
data = loader.load()

# loader = UnstructuredPDFLoader("./data/textbook.pdf")
# loader = OnlinePDFLoader("...")

print(f'{len(data)} pdfs')
print(f'{len(data[0].page_content)} characters')

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(data)

print(f'{len(texts)} documents')
embeddings = OpenAIEmbeddings(openai_api_key=OPENAI_API_KEY, model="text-embedding-3-small")

os.environ['PINECONE_API_KEY'] = PINECONE_API_KEY
docsearch = Pinecone.from_texts([t.page_content for t in texts], embeddings.embed_query, index_name=PINECONE_INDEX_NAME)
print("success")
```

运行后，索引成功创建。

![Pinecone index](https://i.imgur.com/5JMzKQ9.png)

在这一部分，我们将引入LangChain和Pinecone库来处理我们的文档数据。首先，利用OpenAIEmbeddings类，我们将生成文档的嵌入表示；接着，使用Pinecone库创建索引，并将文档嵌入添加至该索引中。最终，通过查询Pinecone索引，我们能够检索出与查询最相近的文档。

首先，导入必要的库，并从credentials.py文件或环境变量中加载OpenAI和Pinecone的API密钥。接下来，使用OpenAI的嵌入模型创建文档嵌入。你可以选择OpenAIEmbeddings类中的任何模型，或者使用LangChain库中提供的其他嵌入模型。

为了在Pinecone中创建索引并添加文档，我选择了1536维的输出空间和余弦相似度度量。通过调整这些参数，可以找到最适合你数据的配置。

更多关于嵌入和Pinecone索引创建时可选择的度量标准，可以参考OpenAI平台和Pinecone官方文档。通过这一过程，我们可以有效地将文档转化为嵌入向量，并在Pinecone索引中进行管理和查询，以支持高效的相似度搜索和信息检索。

#### Pinecone 的向量距离算法

在选择Pinecone索引的度量标准时，你可以根据数据类型选择余弦距离、欧几里得距离或L2距离：

- **余弦距离**用于测量两个向量夹角的余弦值，适用于处理归一化或凸集的场景，常见于文档分类、语义搜索、推荐系统等涉及高维和归一化数据的任务。
- **欧几里得距离**（L2距离）计算多维空间中两点间的直线距离，广泛应用于图像识别、语音识别和手写分析等领域。
- **内积**（点积）通过计算向量对应分量乘积的和来实现，主要用于推荐系统、协同过滤和矩阵分解等应用。

在Pinecone的免费试用版中，用户只能创建一个索引。如果你需要创建更多索引，可以考虑升级到付费计划以获得更多功能和资源。


### 搜索PDF，向pdf文件提问

`ask_pdf.py`

```
import os

from langchain_community.vectorstores import Pinecone
from langchain_core.messages import HumanMessage, SystemMessage, FunctionMessage
from langchain_openai import ChatOpenAI
from langchain_openai.embeddings import OpenAIEmbeddings

from config import OPENAI_API_KEY, PINECONE_API_KEY, PINECONE_INDEX_NAME

os.environ['PINECONE_API_KEY'] = PINECONE_API_KEY
os.environ['OPENAI_API_KEY'] = OPENAI_API_KEY

chat = ChatOpenAI(temperature=0, model_name="gpt-4", openai_api_key=OPENAI_API_KEY)


def ask_pdf(query):
    messages = [
        SystemMessage(
            content="You answer question based on input documents."
        ),
    ]

    embeddings = OpenAIEmbeddings(openai_api_key=OPENAI_API_KEY, model="text-embedding-3-small")
    docsearch = Pinecone.from_existing_index(PINECONE_INDEX_NAME, embeddings)
    docs = docsearch.similarity_search(query)
    messages += [FunctionMessage(name="document", content=doc.page_content) for doc in docs]
    messages.append(HumanMessage(content=query))
    answer = chat(messages)
    return answer.content


def print_qa(query):
    print("Q:", query)
    print("A:", ask_pdf(query))


if __name__ == "__main__":
    print_qa("这篇文章作者是谁")
    print_qa("什么是Multi-Head Attention?")
    print_qa("Attention机制是怎样计算的?")
```

Output:

```
Q: 这篇文章作者是谁
A: 这篇文章的作者是Macherey, Maxim Krikun, Yuan Cao, Qin Gao, Klaus Macherey等人。
Q: 什么是Multi-Head Attention?
A: Multi-Head Attention是Transformer模型中的一种注意力机制。它通过将查询、键和值进行多次线性投影，然后并行地对这些投影进行注意力计算，最后将计算得到的结果进行拼接和投影，得到最终的输出。这种机制允许模型同时关注不同表示子空间的信息，并在不同位置进行联合注意。通过使用多个注意力头，Multi-Head Attention可以更好地捕捉输入序列中的相关信息，提高模型的表达能力。
Q: Attention机制是怎样计算的?
A: Attention机制是一种用于计算序列中不同位置之间关联性的机制。在Transformer模型中，有两种常用的Attention计算方法：Scaled Dot-Product Attention和Multi-Head Attention。
Scaled Dot-Product Attention是一种简单而高效的Attention计算方法。它通过计算查询向量（query）与键向量（key）的点积，然后将结果除以一个缩放因子√dk，最后应用softmax函数得到权重。具体计算公式如下：
Attention(Q, K, V) = softmax(QK^T / √dk) V
其中，Q是查询向量矩阵，K是键向量矩阵，V是值向量矩阵，dk是向量维度。
Multi-Head Attention是一种将多个Attention层并行运行的方法。它通过将查询、键和值分别进行线性变换，然后将变换后的向量输入到多个Attention层中进行计算。最后，将多个Attention层的输出进行拼接，再经过一次线性变换得到最终的Attention输出。
总的来说，Attention机制通过计算查询向量与键向量之间的关联性，然后根据关联性对值向量进行加权求和，从而得到最终的Attention输出。这种机制可以帮助模型在处理序列数据时更好地捕捉不同位置之间的依赖关系。
```

创建文档搜索器后，我们可以轻松地检索到可能包含问题答案的文本片段。如果你已经创建了Pinecone索引，可以直接加载它，或者根据文本和嵌入来新建一个索引。

举例来说，在我们的PDF文件中提到了Multi-Head Attention。通过创建查询，我们可以检索出与查询相关的文档。

`similarity_search`函数允许我们根据查询文本搜索最相关的文档，其中`k`参数决定了返回的文档数量，`filter`和`namespace`参数提供了更细致的筛选功能。默认情况下，此函数返回与查询最相关的前4个文档，但你可以通过调整`k`值来改变返回的文档数量。

