import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

enum VoiceMode { awaitingWakeWord, awaitingQuestion, conversing }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '天城 AI 助理',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const VoiceHomePage(),
    );
  }
}

class VoiceHomePage extends StatefulWidget {
  const VoiceHomePage({super.key});
  @override
  _VoiceHomePageState createState() => _VoiceHomePageState();
}

class _VoiceHomePageState extends State<VoiceHomePage> {
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  String _displayText = '請說出「天城」喚醒我...';
  VoiceMode _mode = VoiceMode.awaitingWakeWord;

  final String _apiKey = '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';
  final _wakeWords = ['天城', '天成'];
  final _exitWords = ['謝謝', '掰掰'];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(onStatus: _onStatus, onError: _onError);
    if (_speechAvailable) {
      _startListening();
    }
  }

  void _onStatus(String status) {
    if (status == 'notListening') {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _startListening();
        });
      }
    }
  }

  void _onError(dynamic error) {
    print('Speech Error: $error');
    _display('語音辨識錯誤，稍後重試');
  }

  void _startListening() {
    if (!_speechAvailable) return;

    _speech.listen(
      onResult: (result) async {
        final spokenText = result.recognizedWords.trim();
        if (spokenText.isEmpty) return;

        switch (_mode) {
          case VoiceMode.awaitingWakeWord:
            if (_wakeWords.any((w) => spokenText.contains(w))) {
              _display('老爺，歡迎回來~請問有什麼需要我幫忙的呢？');
              _mode = VoiceMode.awaitingQuestion;
            }
            break;
          case VoiceMode.awaitingQuestion:
          case VoiceMode.conversing:
            if (_exitWords.any((w) => spokenText.contains(w))) {
              _display('好的，老爺，有需要再叫我。');
              _mode = VoiceMode.awaitingWakeWord;
            } else {
              _display('思考中...');
              final reply = await _getOpenAIResponse(spokenText);
              _display(reply);
              _mode = VoiceMode.conversing;
            }
            break;
        }
      },
      listenMode: stt.ListenMode.dictation,
      localeId: 'zh-TW',
    );
  }

  void _display(String text) {
    setState(() {
      _displayText = text;
    });
  }

  Future<String> _getOpenAIResponse(String prompt) async {
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': '你是我的專屬 AI 女僕「天城」，語氣溫柔、知性成熟，稱呼我為「老爺」。'
          },
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final utf8Str = utf8.decode(response.bodyBytes);
      final data = jsonDecode(utf8Str);
      final content = data['choices'][0]['message']['content'];
      return content;
    } else {
      return '抱歉老爺，我暫時無法回應（${response.statusCode}）';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('天城 AI 助理')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_displayText, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
