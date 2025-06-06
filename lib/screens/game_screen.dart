import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../services/stats_service.dart';
import '../services/audio_service.dart';
import '../services/level_service.dart';
import '../fireworks_effect.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/time_up_dialog.dart';
import 'dart:ui';

class GameScreen extends StatefulWidget {
  final int? levelId;
  
  const GameScreen({Key? key, this.levelId}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _answerController = TextEditingController();
  final StatsService _statsService = StatsService();
  final AudioService _audioService = AudioService();
  final LevelService _levelService = LevelService();
  
  bool _showFireworks = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  bool _isTimerActive = true;
  int? _currentLevelId;
  
  // Thời gian cho mỗi câu hỏi (giây)
  final int _questionTimeLimit = 30;
  
  // Danh sách câu hỏi mẫu
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '2 + 3 = ?',
      'answer': '5',
      'points': 10,
    },
    {
      'question': '5 - 2 = ?',
      'answer': '3',
      'points': 10,
    },
    {
      'question': '4 + 4 = ?',
      'answer': '8',
      'points': 10,
    },
    {
      'question': '10 - 5 = ?',
      'answer': '5',
      'points': 10,
    },
    {
      'question': '3 + 6 = ?',
      'answer': '9',
      'points': 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentLevelId = widget.levelId;
    _audioService.initialize();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final userAnswer = _answerController.text.trim();
    final correctAnswer = currentQuestion['answer'];
    
    if (userAnswer == correctAnswer) {
      // Câu trả lời đúng
      setState(() {
        _showFireworks = true;
        _score += currentQuestion['points'] as int;
        _correctAnswers++;
      });
      
      // Phát âm thanh trả lời đúng
      _audioService.playCorrectSound();
      
      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chính xác! +${currentQuestion['points']} điểm'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
      
      // Chuyển sang câu hỏi tiếp theo sau 2 giây
      Future.delayed(const Duration(microseconds: 500), () {
        _nextQuestion();
      });
    } else {
      // Câu trả lời sai
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sai rồi, hãy thử lại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextQuestion() {
    _answerController.clear();
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isTimerActive = true;
      });
    } else {
      // Kết thúc trò chơi
      _finishGame();
    }
  }

  void _onTimeUp() {
    setState(() {
      _isTimerActive = false;
    });
    
    // Hiển thị dialog hết giờ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TimeUpDialog(
        score: _score,
        correctAnswers: _correctAnswers,
        totalQuestions: _currentQuestionIndex + 1,
        onContinue: () {
          Navigator.pop(context);
          _nextQuestion();
        },
        onQuit: () {
          Navigator.pop(context);
          _saveGameStats();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _finishGame() async {
    // Lưu kết quả trò chơi
    await _saveGameStats();
    
    // Hiển thị dialog kết quả
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 50,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _currentLevelId != null ? 'Level $_currentLevelId hoàn thành!' : 'Hoàn thành!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bạn đã hoàn thành tất cả ${_questions.length} câu hỏi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildResultRow(
                  icon: Icons.score,
                  label: 'Điểm số',
                  value: '$_score',
                ),
                const SizedBox(height: 12),
                _buildResultRow(
                  icon: Icons.check_circle,
                  label: 'Câu trả lời đúng',
                  value: '$_correctAnswers/${_questions.length}',
                ),
                const SizedBox(height: 12),
                _buildResultRow(
                  icon: Icons.percent,
                  label: 'Tỷ lệ chính xác',
                  value: '${(_correctAnswers / _questions.length * 100).toStringAsFixed(1)}%',
                ),
                const SizedBox(height: 32),
                
                // Nút "Tiếp tục" - Hiển thị đầu tiên và nổi bật nhất
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _playNextLevel();
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Tiếp tục'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Nút "Chơi lại"
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetGame();
                        },
                        icon: const Icon(Icons.replay),
                        label: const Text('Chơi lại'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Nút "Về trang chủ"
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Về trang chủ'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _saveGameStats() async {
    // Tạo phiên chơi mới
    final gameSession = GameSession(
      date: DateTime.now(),
      score: _score,
      correctAnswers: _correctAnswers,
      totalQuestions: _currentQuestionIndex + 1,
      gameType: 'Toán lớp 1',
    );
    
    // Nếu đang chơi một level cụ thể, đánh dấu level đã hoàn thành
    if (_currentLevelId != null) {
      // Tính số sao dựa trên tỷ lệ câu trả lời đúng
      int stars = 0;
      final correctRatio = _correctAnswers / _questions.length;
      
      if (correctRatio >= 0.9) {
        stars = 3; // 90% trở lên: 3 sao
      } else if (correctRatio >= 0.7) {
        stars = 2; // 70-89%: 2 sao
      } else if (correctRatio >= 0.5) {
        stars = 1; // 50-69%: 1 sao
      }
      
      await _levelService.completeLevel(_currentLevelId!, stars: stars);
    }
    
    // Cập nhật thống kê
    await _statsService.updateStatsAfterGame(gameSession);
  }

  void _resetGame() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _correctAnswers = 0;
      _answerController.clear();
      _isTimerActive = true;
    });
  }
  
  void _playNextLevel() {
    if (_currentLevelId != null) {
      // Chuyển đến level tiếp theo
      int nextLevelId = _currentLevelId! + 1;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(levelId: nextLevelId),
        ),
      );
    } else {
      // Nếu không có level cụ thể, chỉ reset game
      _resetGame();
    }
  }

  // Hàm tạo các widget hiển thị phép tính màu mè
  List<Widget> _buildColorfulMathProblem(String problem) {
    // Phân tích chuỗi phép tính
    List<Widget> result = [];
    
    // Tách phép tính thành các phần
    RegExp regExp = RegExp(r'(\d+)|([+\-×÷=\?])');
    Iterable<RegExpMatch> matches = regExp.allMatches(problem);
    
    List<String> parts = [];
    for (var match in matches) {
      parts.add(match.group(0)!);
    }
    
    // Tạo widget cho từng phần
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      
      // Kiểm tra xem phần này là số, phép toán hay dấu bằng
      if (RegExp(r'^\d+$').hasMatch(part)) {
        // Đây là số
        result.add(
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: i == 0 ? Colors.blue.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (i == 0 ? Colors.blue : Colors.green).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              part,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: i == 0 ? Colors.blue.shade800 : Colors.green.shade800,
              ),
            ),
          ),
        );
      } else if (part == '+' || part == '-' || part == '×' || part == '÷') {
        // Đây là phép toán
        result.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              part,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
          ),
        );
      } else if (part == '=') {
        // Đây là dấu bằng
        result.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              part,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        );
      } else if (part == '?') {
        // Đây là dấu hỏi
        result.add(
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              part,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
          ),
        );
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài tập toán'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CountdownTimer(
              durationInSeconds: _questionTimeLimit,
              onTimeUp: _onTimeUp,
              isActive: _isTimerActive,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Điểm: $_score',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Hiển thị phép tính với màu sắc
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildColorfulMathProblem(currentQuestion['question']),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    decoration: InputDecoration(
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
                      fillColor: Colors.purple.withOpacity(0.05),
                      hintText: '?',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 24,
                      ),
                    ),
                    onSubmitted: (_) => _checkAnswer(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Kiểm tra',
                    style: TextStyle(fontSize: 18),
                  ),
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
}
