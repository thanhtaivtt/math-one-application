import 'dart:math';
import 'package:flutter/material.dart';

class Fireworks extends StatefulWidget {
  const Fireworks({super.key});

  @override
  State<Fireworks> createState() => _FireworksState();
}

class _FireworksState extends State<Fireworks> with TickerProviderStateMixin {
  late List<FireworkParticle> particles;
  late AnimationController _controller;
  final int numberOfParticles = 100;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    particles = List.generate(
      numberOfParticles,
      (index) => FireworkParticle(
        random: random,
        screenWidth: 1, // Will be updated in build
        screenHeight: 1, // Will be updated in build
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
    final size = MediaQuery.of(context).size;
    
    // Update particles with actual screen size
    for (var particle in particles) {
      particle.screenWidth = size.width;
      particle.screenHeight = size.height;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size.width, size.height),
          painter: FireworksPainter(
            particles: particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class FireworkParticle {
  late double x;
  late double y;
  late double velocityX;
  late double velocityY;
  late Color color;
  late double size;
  double screenWidth;
  double screenHeight;
  final Random random;

  FireworkParticle({
    required this.random,
    required this.screenWidth,
    required this.screenHeight,
  }) {
    reset();
  }

  void reset() {
    // Start from center of screen
    x = screenWidth / 2;
    y = screenHeight / 2;
    
    // Random velocity in all directions
    double angle = random.nextDouble() * 2 * pi;
    double speed = 2 + random.nextDouble() * 3;
    velocityX = cos(angle) * speed;
    velocityY = sin(angle) * speed;
    
    // Random color
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    color = colors[random.nextInt(colors.length)];
    
    // Random size
    size = 2 + random.nextDouble() * 4;
  }

  void update(double progress) {
    // Update position based on velocity
    x += velocityX * 10 * progress;
    y += velocityY * 10 * progress;
    
    // Fade out by reducing size
    size = size * (1 - progress * 0.5);
  }
}

class FireworksPainter extends CustomPainter {
  final List<FireworkParticle> particles;
  final double progress;

  FireworksPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(progress);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
