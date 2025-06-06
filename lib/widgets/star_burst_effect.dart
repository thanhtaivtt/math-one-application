import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'star_particle.dart';

/// Widget hiển thị hiệu ứng bùng nổ ngôi sao
class StarBurstEffect extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onComplete;
  final int numberOfStars;
  final Duration duration;

  const StarBurstEffect({
    Key? key,
    required this.isPlaying,
    this.onComplete,
    this.numberOfStars = 20,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<StarBurstEffect> createState() => _StarBurstEffectState();
}

class _StarBurstEffectState extends State<StarBurstEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<StarParticleData> _stars = [];
  final math.Random _random = math.Random();
  
  // Danh sách màu sắc cho các ngôi sao
  final List<Color> _colors = [
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
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _generateStars();
    
    if (widget.isPlaying) {
      _controller.forward();
    }
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onComplete != null && mounted) {
          widget.onComplete!();
        }
      }
    });
  }

  @override
  void didUpdateWidget(StarBurstEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _generateStars();
      _controller.reset();
      _controller.forward();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateStars() {
    _stars.clear();
    
    for (int i = 0; i < widget.numberOfStars; i++) {
      // Tạo vị trí ngẫu nhiên cho ngôi sao
      final double angle = _random.nextDouble() * 2 * math.pi;
      final double distance = _random.nextDouble() * 150 + 50;
      
      // Tạo kích thước ngẫu nhiên cho ngôi sao
      final double size = _random.nextDouble() * 20 + 10;
      
      // Chọn màu ngẫu nhiên từ danh sách màu
      final Color color = _colors[_random.nextInt(_colors.length)];
      
      // Tạo thời gian hiển thị ngẫu nhiên
      final Duration duration = Duration(
        milliseconds: _random.nextInt(1000) + 1000,
      );
      
      // Tạo độ trễ ngẫu nhiên
      final Duration delay = Duration(
        milliseconds: _random.nextInt(500),
      );
      
      _stars.add(StarParticleData(
        angle: angle,
        distance: distance,
        size: size,
        color: color,
        duration: duration,
        delay: delay,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            for (final star in _stars)
              _buildAnimatedStar(star),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedStar(StarParticleData star) {
    final double progress = _controller.value;
    
    // Tính toán vị trí dựa trên góc và khoảng cách
    final double maxDistance = star.distance;
    final double currentDistance = progress * maxDistance;
    
    final double dx = math.cos(star.angle) * currentDistance;
    final double dy = math.sin(star.angle) * currentDistance;
    
    // Chỉ hiển thị ngôi sao sau khi đã trễ đủ thời gian
    final double delayProgress = (widget.duration.inMilliseconds - star.delay.inMilliseconds) / 
                                widget.duration.inMilliseconds;
    
    if (progress < star.delay.inMilliseconds / widget.duration.inMilliseconds) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 + dx - star.size / 2,
      top: MediaQuery.of(context).size.height / 2 + dy - star.size / 2,
      child: StarParticle(
        size: star.size,
        color: star.color,
        duration: star.duration,
      ),
    );
  }
}

class StarParticleData {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final Duration duration;
  final Duration delay;

  StarParticleData({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.duration,
    required this.delay,
  });
}
