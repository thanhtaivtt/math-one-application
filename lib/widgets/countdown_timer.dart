import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class CountdownTimer extends StatefulWidget {
  final int durationInSeconds;
  final Function() onTimeUp;
  final bool isActive;

  const CountdownTimer({
    Key? key,
    required this.durationInSeconds,
    required this.onTimeUp,
    this.isActive = true,
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _secondsRemaining;
  Timer? _timer;
  final AudioService _audioService = AudioService();
  bool _isWarning = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationInSeconds;
    _initAudio();
    
    if (widget.isActive) {
      _startTimer();
    }
  }

  Future<void> _initAudio() async {
    try {
      await _audioService.initialize();
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopTimer();
    }
    
    if (widget.durationInSeconds != oldWidget.durationInSeconds) {
      setState(() {
        _secondsRemaining = widget.durationInSeconds;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          
          // Bắt đầu phát âm thanh tích tắc khi còn 10 giây
          if (_secondsRemaining <= 10 && !_isWarning) {
            _isWarning = true;
            _startTickingSound();
          }
        } else {
          _timer?.cancel();
          _stopTickingSound();
          _playTimeUpSound();
          widget.onTimeUp();
        }
      });
    });
  }

  Future<void> _startTickingSound() async {
    try {
      await _audioService.startTicking();
    } catch (e) {
      print('Error starting ticking sound: $e');
    }
  }

  Future<void> _stopTickingSound() async {
    try {
      await _audioService.stopTicking();
    } catch (e) {
      print('Error stopping ticking sound: $e');
    }
  }

  Future<void> _playTimeUpSound() async {
    try {
      await _audioService.playTimeUpSound();
    } catch (e) {
      print('Error playing time up sound: $e');
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _stopTickingSound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopTickingSound();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isLowTime = _secondsRemaining <= 10;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowTime ? Colors.red : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isLowTime ? Colors.red : Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(_secondsRemaining),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
