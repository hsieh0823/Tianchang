import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tianchang Voice',
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
  bool _isListening = false;
  String _text = '請說出「天城」喚醒我...';
  final String _apiKey = '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';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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
            'content': '你是我的專屬 AI 女僕「天城」，語氣溫柔、知性成熟，稱呼我為「主人」。'
          },
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return '發生錯誤：${response.statusCode}';
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) async {
          setState(() {
            _text = result.recognizedWords;
          });
          if (result.finalResult) {
            final aiReply = await _getOpenAIResponse(result.recognizedWords);
            setState(() {
              _text = aiReply;
              _isListening = false;
            });
            _speech.stop();
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('天城 AI 助理')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_text, style: const TextStyle(fontSize: 20)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
