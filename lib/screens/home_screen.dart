import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'stats_screen.dart';
import 'levels_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng Dụng Học Toán Lớp 1', style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.purpleAccent
        )),
        centerTitle: true,
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calculate,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Học toán vui vẻ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Luyện tập toán lớp 1 với các bài tập thú vị và hấp dẫn nhất.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.lightBlueAccent),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Bắt đầu chơi',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LevelsScreen()),
                );
              },
              icon: const Icon(Icons.grid_view),
              label: const Text(
                'Chọn cấp độ',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text(
                'Xem thống kê',
                style: TextStyle(fontSize: 18),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
