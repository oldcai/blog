---
title: python实现调用微软API进行文本转语音
date: 2022-12-16 09:15:01
tags:
	- Azure
	- ai
---

Azure Text-to-Speech是一项Azure服务，可以将文字转换为自然语音。它提供了多种语言和发音选项，可以让您创建合成语音应用程序和服务。

Azure文字转语音的收费方式是按照使用的语音合成时间计费的。具体的收费标准可能会根据不同的国家和地区有所不同，建议您前往Azure官网查询最新的收费标准。

您也可以在使用Azure文字转语音服务之前先了解该服务的免费额度和试用计划，这样就可以在满足您的需求的同时最大程度地控制成本。如果您还有其他疑问，可以联系Azure技术支持团队寻求帮助。


## Python 实现调用 Azure API进行文本转语音

要在 Python 中调用 Azure 语音 API，首先需要安装 Azure 机器学习 SDK，然后使用 azure-cognitiveservices-speech 库。下面是一个例子：

```
import os
from azure.cognitiveservices.speech import SpeechConfig, AudioOutputConfig, SpeakerRecognitionResult
from azure.cognitiveservices.speech.audio import AudioDataStream, AudioOutputStream, AudioOutputConfig
from azure.cognitiveservices.speech.texttospeech import TextToSpeechClient, SynthesisOutputFormat


# Set your subscription key and region
subscription_key = "<your-subscription-key>"
region = "<your-region>"

# Set the text to be synthesized
text = "通过自然语音为应用注入生命力"

# Initialize the text-to-speech client
tts_client = TextToSpeechClient(subscription_key, region)

# Set the voice and synthesis output format
voice_name = "zh-CN-XiaoxiaoNeural"
synthesis_output_format = SynthesisOutputFormat.mp3

# Set the audio output configuration
audio_config = AudioOutputConfig()
audio_config.output_format = SynthesisOutputFormat.mp3

# Synthesize the text and write the output to a file
result = tts_client.synthesize_speech(text, voice_name, synthesis_output_format, audio_config)
with open("output.mp3", "wb") as file:
    file.write(result)
```

在上面的代码中，我们使用 Azure 语音 API 将文本转换为语音，然后将结果保存到文件中。请注意，您需要提供 Azure 订阅密钥和区域信息才能使用语音 API。
请注意，上面的代码仅是一个简单的例子，实际应用中可能需要进行更多的处理，如处理错误和异常、检查语音结果等。更多信息，可以参考 Azure 语音 API 的文档。


## Python实现免费文字转微软语音

Azure大量使用需要付费，我们还可以使用 win32com.client 模块中的 Dispatch 方法来实现文字转微软语音。下面是一个例子：

```
import win32com.client

def text_to_speech(text):
    # Initialize the speech engine
    engine = win32com.client.Dispatch("SAPI.SpVoice")

    # Set the voice
    voices = engine.GetVoices()
    engine.Voice = voices[0]

    # Set the rate
    rate = engine.Rate
    engine.Rate = -1

    # Speak the text
    engine.Speak(text)

# Try it out
text_to_speech("Hello, I am a text-to-speech engine")
```

请注意，上面的代码仅在 Windows 系统中运行。如果您需要在其他系统中运行，则需要使用其他语音引擎库。

