import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  AudioService._internal();
  
  AudioPlayer? _tickPlayer;
  AudioPlayer? _effectPlayer;
  bool _isTickingActive = false;
  bool _isInitialized = false;
  
  // Khởi tạo âm thanh
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _tickPlayer = AudioPlayer();
      _effectPlayer = AudioPlayer();
      
      await _tickPlayer?.setReleaseMode(ReleaseMode.loop); // Chế độ lặp cho âm thanh tích tắc
      await _effectPlayer?.setReleaseMode(ReleaseMode.release); // Chế độ phát một lần cho hiệu ứng
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing audio service: $e');
    }
  }
  
  // Phát âm thanh tích tắc
  Future<void> startTicking() async {
    if (!_isInitialized) await initialize();
    if (_isTickingActive) return;
    
    try {
      _isTickingActive = true;
      await _tickPlayer?.play(AssetSource('audio/tick.mp3'));
    } catch (e) {
      print('Error playing tick sound: $e');
    }
  }
  
  // Dừng âm thanh tích tắc
  Future<void> stopTicking() async {
    if (!_isInitialized || !_isTickingActive) return;
    
    try {
      await _tickPlayer?.stop();
      _isTickingActive = false;
    } catch (e) {
      print('Error stopping tick sound: $e');
    }
  }
  
  // Phát âm thanh trả lời đúng
  Future<void> playCorrectSound() async {
    if (!_isInitialized) await initialize();
    
    try {
      await _effectPlayer?.play(AssetSource('audio/correct_answer.mp3'));
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }
  
  // Phát âm thanh hết giờ
  Future<void> playTimeUpSound() async {
    if (!_isInitialized) await initialize();
    
    try {
      await _effectPlayer?.play(AssetSource('audio/time_up.mp3'));
    } catch (e) {
      print('Error playing time up sound: $e');
    }
  }
  
  // Giải phóng tài nguyên
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    try {
      await stopTicking();
      await _tickPlayer?.dispose();
      await _effectPlayer?.dispose();
      _tickPlayer = null;
      _effectPlayer = null;
      _isInitialized = false;
    } catch (e) {
      print('Error disposing audio service: $e');
    }
  }
}
