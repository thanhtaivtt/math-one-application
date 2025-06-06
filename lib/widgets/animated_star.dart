import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedStar extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final bool animate;

  const AnimatedStar({
    Key? key,
    this.size = 30.0,
    required this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.animate = true,
  }) : super(key: key);

  @override
  State<AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.9),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedStar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0.0);
    } else if (!widget.animate && oldWidget.animate) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: StarPainter(color: widget.color),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    final double radius = size.width / 2;
    final double innerRadius = radius * 0.4;
    
    final Path path = Path();
    final double rotation = -math.pi / 2; // Bắt đầu từ đỉnh
    
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
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Thêm hiệu ứng lấp lánh
    final Paint shimmerPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawPath(path, shimmerPaint);
    
    // Thêm điểm sáng ở giữa
    final Paint centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.1, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
