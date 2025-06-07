import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            final words = result.recognizedWords;
            setState(() {
              _text = words;
            });

            if (words.contains('天城')) {
              _speech.stop();
              setState(() => _isListening = false);
              _startConversation();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _startConversation() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('已喚醒天城'),
        content: Text('開始對話功能準備中...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('天城 AI 助理')),
      body: Center(child: Text(_text, style: const TextStyle(fontSize: 24))),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
