import 'package:flutter/material.dart';
import 'dart:ui';

class LevelCompleteDialog extends StatelessWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int? levelId;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const LevelCompleteDialog({
    Key? key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    this.levelId,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính số sao đạt được
    int stars = 0;
    final correctRatio = correctAnswers / totalQuestions;
    
    if (correctRatio >= 0.9) {
      stars = 3; // 90% trở lên: 3 sao
    } else if (correctRatio >= 0.7) {
      stars = 2; // 70-89%: 2 sao
    } else if (correctRatio >= 0.5) {
      stars = 1; // 50-69%: 1 sao
    }

    return BackdropFilter(
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
              // Icon hoàn thành
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
              
              // Tiêu đề
              Text(
                levelId != null ? 'Level $levelId hoàn thành!' : 'Hoàn thành!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Thông tin hoàn thành
              Text(
                'Bạn đã hoàn thành tất cả $totalQuestions câu hỏi',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              
              // Hiển thị số sao đạt được
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: index < stars ? Colors.amber : Colors.grey,
                    size: 40,
                  );
                }),
              ),
              const SizedBox(height: 24),
              
              // Thông tin kết quả
              _buildResultRow(
                icon: Icons.score,
                label: 'Điểm số',
                value: '$score',
              ),
              const SizedBox(height: 12),
              _buildResultRow(
                icon: Icons.check_circle,
                label: 'Câu trả lời đúng',
                value: '$correctAnswers/$totalQuestions',
              ),
              const SizedBox(height: 12),
              _buildResultRow(
                icon: Icons.percent,
                label: 'Tỷ lệ chính xác',
                value: '${(correctRatio * 100).toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 32),
              
              // Các nút hành động
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onNextLevel,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Level tiếp theo'),
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReplay,
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onHome,
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
            ],
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
}
