import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_stats.dart';
import '../services/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StatsService _statsService = StatsService();
  UserStats? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    setState(() {
      _isLoading = true;
    });

    final stats = await _statsService.getUserStats();
    
    setState(() {
      _userStats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê người chơi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userStats == null
              ? _buildNoStatsView()
              : _buildStatsView(),
    );
  }

  Widget _buildNoStatsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu thống kê',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy hoàn thành một vài bài tập để xem thống kê',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView() {
    final stats = _userStats!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(stats),
          const SizedBox(height: 24),
          const Text(
            'Lịch sử lượt chơi gần đây',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          stats.recentSessions.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Chưa có lượt chơi nào'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.recentSessions.length,
                  itemBuilder: (context, index) {
                    final session = stats.recentSessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          '${session.gameType} - ${dateFormat.format(session.date)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Điểm: ${session.score}'),
                            Text(
                              'Đúng: ${session.correctAnswers}/${session.totalQuestions} (${session.accuracyRate.toStringAsFixed(1)}%)',
                            ),
                          ],
                        ),
                        trailing: CircleAvatar(
                          backgroundColor: _getAccuracyColor(session.accuracyRate),
                          child: Text(
                            '${session.accuracyRate.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(UserStats stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    stats.userName.isNotEmpty ? stats.userName[0] : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('ID: ${stats.userId}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildStatRow(
              icon: Icons.games,
              title: 'Tổng số lượt chơi',
              value: '${stats.totalGames}',
            ),
            _buildStatRow(
              icon: Icons.check_circle,
              title: 'Câu trả lời đúng',
              value: '${stats.correctAnswers}',
            ),
            _buildStatRow(
              icon: Icons.score,
              title: 'Tổng điểm',
              value: '${stats.totalScore}',
            ),
            _buildStatRow(
              icon: Icons.percent,
              title: 'Tỷ lệ chính xác',
              value: '${stats.accuracyRate.toStringAsFixed(1)}%',
              valueColor: _getAccuracyColor(stats.accuracyRate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Text(title),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) {
      return Colors.green;
    } else if (accuracy >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
