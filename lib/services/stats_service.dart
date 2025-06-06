import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';

class StatsService {
  static const String _statsKey = 'user_stats';
  
  // Lưu thống kê người dùng
  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = jsonEncode(stats.toJson());
    await prefs.setString(_statsKey, statsJson);
  }
  
  // Lấy thống kê người dùng
  Future<UserStats?> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    
    if (statsJson == null) {
      return null;
    }
    
    try {
      final Map<String, dynamic> statsMap = jsonDecode(statsJson);
      return UserStats.fromJson(statsMap);
    } catch (e) {
      print('Error loading user stats: $e');
      return null;
    }
  }
  
  // Cập nhật thống kê sau khi hoàn thành một phiên chơi
  Future<UserStats> updateStatsAfterGame(GameSession newSession) async {
    UserStats? currentStats = await getUserStats();
    
    if (currentStats == null) {
      // Tạo thống kê mới nếu chưa có
      currentStats = UserStats(
        userId: 'user_1', // Có thể thay đổi khi có hệ thống đăng nhập
        userName: 'Người chơi',
        totalGames: 0,
        correctAnswers: 0,
        totalScore: 0,
        recentSessions: [],
      );
    }
    
    // Cập nhật thống kê
    final updatedStats = UserStats(
      userId: currentStats.userId,
      userName: currentStats.userName,
      totalGames: currentStats.totalGames + 1,
      correctAnswers: currentStats.correctAnswers + newSession.correctAnswers,
      totalScore: currentStats.totalScore + newSession.score,
      recentSessions: [
        newSession,
        ...currentStats.recentSessions.take(9), // Giữ 10 phiên gần nhất
      ],
    );
    
    // Lưu thống kê đã cập nhật
    await saveUserStats(updatedStats);
    return updatedStats;
  }
}
