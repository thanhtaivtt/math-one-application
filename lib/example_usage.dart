import 'package:flutter/material.dart';
import 'fireworks_effect.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  bool _showFireworks = false;
  final TextEditingController _answerController = TextEditingController();
  final String _correctAnswer = "5"; // Ví dụ: 2 + 3 = ?

  void _checkAnswer() {
    if (_answerController.text.trim() == _correctAnswer) {
      setState(() {
        _showFireworks = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài tập toán'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '2 + 3 = ?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkAnswer,
                  child: const Text('Kiểm tra'),
                ),
              ],
            ),
          ),
          if (_showFireworks)
            FireworksEffect(
              isPlaying: _showFireworks,
              onComplete: () {
                setState(() {
                  _showFireworks = false;
                });
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
