import 'package:flutter/material.dart';
import 'dart:ui';

class TimeUpDialog extends StatefulWidget {
  final Function() onContinue;
  final Function() onQuit;
  final int score;
  final int correctAnswers;
  final int totalQuestions;

  const TimeUpDialog({
    Key? key,
    required this.onContinue,
    required this.onQuit,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  _TimeUpDialogState createState() => _TimeUpDialogState();
}

class _TimeUpDialogState extends State<TimeUpDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accuracyRate = widget.totalQuestions > 0
        ? (widget.correctAnswers / widget.totalQuestions * 100).toStringAsFixed(1)
        : '0.0';
        
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0 * _opacityAnimation.value,
            sigmaY: 5.0 * _opacityAnimation.value,
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.timer_off,
                        size: 40,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Hết giờ!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Thời gian làm bài đã kết thúc',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildResultItem(
                      icon: Icons.score,
                      label: 'Điểm số',
                      value: '${widget.score}',
                    ),
                    const SizedBox(height: 12),
                    _buildResultItem(
                      icon: Icons.check_circle,
                      label: 'Câu trả lời đúng',
                      value: '${widget.correctAnswers}/${widget.totalQuestions}',
                    ),
                    const SizedBox(height: 12),
                    _buildResultItem(
                      icon: Icons.percent,
                      label: 'Tỷ lệ chính xác',
                      value: '$accuracyRate%',
                    ),
                    const SizedBox(height: 32),
                    
                    // Nút "Tiếp tục" - Hiển thị đầu tiên và nổi bật nhất
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onContinue,
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
                    
                    // Nút "Thoát"
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onQuit,
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
      },
    );
  }

  Widget _buildResultItem({
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
