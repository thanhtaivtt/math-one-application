class Level {
  final int id;
  final bool isCompleted;
  final int stars; // Số sao đạt được (0-3)

  Level({
    required this.id,
    this.isCompleted = false,
    this.stars = 0,
  });

  Level copyWith({
    int? id,
    bool? isCompleted,
    int? stars,
  }) {
    return Level(
      id: id ?? this.id,
      isCompleted: isCompleted ?? this.isCompleted,
      stars: stars ?? this.stars,
    );
  }
}
