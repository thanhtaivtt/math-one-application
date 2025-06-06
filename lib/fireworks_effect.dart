import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import 'widgets/star_burst_effect.dart';

class FireworksEffect extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onComplete;

  const FireworksEffect({
    Key? key,
    required this.isPlaying,
    required this.onComplete,
  }) : super(key: key);

  @override
  _FireworksEffectState createState() => _FireworksEffectState();
}

class _FireworksEffectState extends State<FireworksEffect> {
  late ConfettiController _confettiController;
  bool _showStarBurst = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    if (widget.isPlaying) {
      _confettiController.play();
      setState(() {
        _showStarBurst = true;
      });
    }
    
    // Thêm timer để gọi onComplete khi hiệu ứng kết thúc
    Future.delayed(const Duration(seconds: 2), () {
      if (widget.isPlaying && mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void didUpdateWidget(FireworksEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _confettiController.play();
      setState(() {
        _showStarBurst = true;
      });
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _confettiController.stop();
      setState(() {
        _showStarBurst = false;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Path drawStar(Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    
    double radius = size.width / 2;
    double innerRadius = radius * 0.4;
    
    Path path = Path();
    double rotation = -math.pi / 2; // Bắt đầu từ đỉnh
    
    // Di chuyển đến điểm đầu tiên
    double initialX = centerX + math.cos(rotation) * radius;
    double initialY = centerY + math.sin(rotation) * radius;
    path.moveTo(initialX, initialY);
    
    // Vẽ 5 đỉnh của ngôi sao
    for (int i = 1; i <= 5; i++) {
      // Điểm ngoài
      double outerX = centerX + math.cos(rotation + (2 * i - 1) * math.pi / 5) * radius;
      double outerY = centerY + math.sin(rotation + (2 * i - 1) * math.pi / 5) * radius;
      
      // Điểm trong
      double innerX = centerX + math.cos(rotation + 2 * i * math.pi / 5) * innerRadius;
      double innerY = centerY + math.sin(rotation + 2 * i * math.pi / 5) * innerRadius;
      
      path.lineTo(outerX, outerY);
      path.lineTo(innerX, innerY);
    }
    
    // Đóng đường dẫn để hoàn thành ngôi sao
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hiệu ứng pháo hoa với hình ngôi sao từ thư viện confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            createParticlePath: drawStar, // Sử dụng hàm vẽ ngôi sao
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.yellow,
              Colors.green,
              Colors.purple,
              Colors.orange,
              Colors.pink,
              Colors.amber,
              Colors.cyan,
              Colors.teal,
            ],
          ),
        ),
        // Thêm hiệu ứng pháo hoa thứ hai với góc khác
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.1,
            shouldLoop: false,
            maxBlastForce: 7,
            minBlastForce: 2,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.yellow,
              Colors.green,
              Colors.purple,
              Colors.orange,
              Colors.pink,
              Colors.amber,
              Colors.cyan,
              Colors.teal,
            ],
          ),
        ),
        // Hiệu ứng bùng nổ ngôi sao tùy chỉnh
        if (_showStarBurst)
          const StarBurstEffect(
            isPlaying: true,
            numberOfStars: 30,
            duration: Duration(seconds: 3),
          ),
      ],
    );
  }
}
