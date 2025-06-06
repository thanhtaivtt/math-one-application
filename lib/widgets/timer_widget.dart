import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback onTimeUp;

  const TimerWidget({
    required this.seconds,
    required this.onTimeUp,
    Key? key,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _secondsRemaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.seconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          widget.onTimeUp();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate percentage for progress indicator
    double progress = _secondsRemaining / widget.seconds;
    
    // Determine color based on time remaining
    Color progressColor;
    if (_secondsRemaining > widget.seconds * 0.6) {
      progressColor = Colors.green;
    } else if (_secondsRemaining > widget.seconds * 0.3) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      children: [
        Text(
          'Thời gian: $_secondsRemaining giây',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}
