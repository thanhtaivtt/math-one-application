import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_stamp_camera/models/math_problem.dart';
import 'package:time_stamp_camera/widgets/fireworks.dart';
import 'package:time_stamp_camera/widgets/timer_widget.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  int score = 0;
  int level = 1;
  int timeLimit = 30; // Starting with 30 seconds
  bool showFireworks = false;
  bool showWrongAnimation = false;
  late MathProblem currentProblem;
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    generateNewProblem();
  }
  
  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }
  
  void generateNewProblem() {
    setState(() {
      currentProblem = MathProblem.generate(level);
      _answerController.clear();
      _answerFocusNode.requestFocus();
    });
  }
  
  void checkAnswer() {
    final userAnswer = int.tryParse(_answerController.text);
    
    if (userAnswer == currentProblem.answer) {
      setState(() {
        score++;
        showFireworks = true;
        
        // Increase difficulty every 5 correct answers
        if (score % 5 == 0) {
          level++;
          // Reduce time limit as level increases, but not below 10 seconds
          if (timeLimit > 10) {
            timeLimit -= 2;
          }
        }
      });
      
      // Hide fireworks after 2 seconds and generate new problem
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showFireworks = false;
            generateNewProblem();
          });
        }
      });
    } else {
      setState(() {
        showWrongAnimation = true;
      });
      
      // Hide wrong animation after 1 second
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showWrongAnimation = false;
            _answerController.clear();
            _answerFocusNode.requestFocus();
          });
        }
      });
    }
  }
  
  void timeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hết giờ!'),
        content: Text('Điểm của bạn: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                score = 0;
                level = 1;
                timeLimit = 30;
                generateNewProblem();
              });
            },
            child: const Text('Chơi lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Về trang chủ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Chuyển sang màn hình tiếp theo hoặc level tiếp theo
              // Có thể thêm logic để chuyển đến level tiếp theo ở đây
              Navigator.of(context).pushReplacementNamed('/next_level');
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Điểm: $score',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Cấp độ: $level',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TimerWidget(
                      seconds: timeLimit,
                      onTimeUp: timeUp,
                      key: Key('timer_$score'), // Reset timer when score changes
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Hiển thị phép tính với màu sắc
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Số thứ nhất
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  currentProblem.getFirstPart(),
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              
                              // Phép toán
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  currentProblem.getOperationSymbol(),
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ),
                              
                              // Số thứ hai
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  currentProblem.getSecondPart(),
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                              
                              // Dấu bằng
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "=",
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                              
                              // Dấu hỏi
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "?",
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: _answerController,
                            focusNode: _answerFocusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Nhập câu trả lời',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 24,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.purple.shade200,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.purple.shade200,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.purple.shade400,
                                  width: 3,
                                ),
                              ),
                              filled: true,
                              fillColor: showWrongAnimation 
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.purple.withOpacity(0.05),
                            ),
                            onSubmitted: (_) => checkAnswer(),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: checkAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Kiểm tra',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showFireworks) const Fireworks(),
            ],
          ),
        ),
      ),
    );
  }
}
