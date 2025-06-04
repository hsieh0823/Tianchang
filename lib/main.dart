import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(TianchangApp());

class TianchangApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '天城語音助理',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: VoiceHomePage(),
    );
  }
}

class VoiceHomePage extends StatefulWidget {
  @override
  _VoiceHomePageState createState() => _VoiceHomePageState();
}

class _VoiceHomePageState extends State<VoiceHomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '點擊開始語音辨識';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) => setState(() {
          _text = result.recognizedWords;
        }),
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('天城語音助理')),
      body: Center(child: Text(_text, style: TextStyle(fontSize: 24))),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _stopListening : _startListening,
        child: Icon(_isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
