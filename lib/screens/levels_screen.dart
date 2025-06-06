import 'package:flutter/material.dart';
import '../models/level_model.dart';
import '../services/level_service.dart';
import 'game_screen.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({Key? key}) : super(key: key);

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  final LevelService _levelService = LevelService();
  List<Level> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    setState(() {
      _isLoading = true;
    });

    final levels = await _levelService.getLevels();
    
    setState(() {
      _levels = levels;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn cấp độ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  return _buildLevelItem(level);
                },
              ),
            ),
    );
  }

  Widget _buildLevelItem(Level level) {
    final bool isCompleted = level.isCompleted;
    final bool isLocked = level.id > 1 && !_levels[level.id - 2].isCompleted;

    return InkWell(
      onTap: isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hoàn thành cấp độ trước để mở khóa cấp độ này!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(levelId: level.id),
                ),
              ).then((_) => _loadLevels());
            },
      child: Container(
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey[300]
              : isCompleted
                  ? Colors.green[100]
                  : Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLocked
                ? Colors.grey
                : isCompleted
                    ? Colors.green
                    : Colors.blue,
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${level.id}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.black87,
              ),
            ),
            if (isLocked)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            if (isCompleted)
              const Positioned(
                bottom: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
              ),
            if (level.stars > 0 && isCompleted)
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    level.stars,
                    (index) => const Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
