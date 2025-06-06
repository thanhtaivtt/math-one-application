import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/level_model.dart';

class LevelService {
  static const String _levelsKey = 'user_levels';
  
  // Lấy danh sách tất cả các level
  Future<List<Level>> getLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final levelsJson = prefs.getString(_levelsKey);
    
    if (levelsJson == null) {
      // Khởi tạo 100 levels mặc định nếu chưa có dữ liệu
      return _initializeLevels();
    }
    
    try {
      final List<dynamic> decodedList = jsonDecode(levelsJson);
      return decodedList.map((item) => Level(
        id: item['id'],
        isCompleted: item['isCompleted'] ?? false,
        stars: item['stars'] ?? 0,
      )).toList();
    } catch (e) {
      // Nếu có lỗi, trả về danh sách mặc định
      return _initializeLevels();
    }
  }
  
  // Cập nhật thông tin của một level
  Future<void> updateLevel(Level level) async {
    final levels = await getLevels();
    final index = levels.indexWhere((l) => l.id == level.id);
    
    if (index != -1) {
      levels[index] = level;
      await _saveLevels(levels);
    }
  }
  
  // Đánh dấu một level là đã hoàn thành
  Future<void> completeLevel(int levelId, {int stars = 1}) async {
    final levels = await getLevels();
    final index = levels.indexWhere((l) => l.id == levelId);
    
    if (index != -1) {
      levels[index] = levels[index].copyWith(
        isCompleted: true,
        stars: stars,
      );
      await _saveLevels(levels);
    }
  }
  
  // Lưu danh sách levels vào SharedPreferences
  Future<void> _saveLevels(List<Level> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final levelsJson = jsonEncode(
      levels.map((level) => {
        'id': level.id,
        'isCompleted': level.isCompleted,
        'stars': level.stars,
      }).toList(),
    );
    
    await prefs.setString(_levelsKey, levelsJson);
  }
  
  // Khởi tạo danh sách 100 levels mặc định
  List<Level> _initializeLevels() {
    return List.generate(100, (index) => Level(id: index + 1));
  }
}
