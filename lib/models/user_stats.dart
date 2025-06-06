class UserStats {
  final String userId;
  final String userName;
  final int totalGames;
  final int correctAnswers;
  final int totalScore;
  final List<GameSession> recentSessions;

  UserStats({
    required this.userId,
    required this.userName,
    required this.totalGames,
    required this.correctAnswers,
    required this.totalScore,
    required this.recentSessions,
  });

  double get accuracyRate => 
      totalGames > 0 ? (correctAnswers / totalGames) * 100 : 0;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'],
      userName: json['userName'],
      totalGames: json['totalGames'],
      correctAnswers: json['correctAnswers'],
      totalScore: json['totalScore'],
      recentSessions: (json['recentSessions'] as List)
          .map((session) => GameSession.fromJson(session))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'totalGames': totalGames,
      'correctAnswers': correctAnswers,
      'totalScore': totalScore,
      'recentSessions': recentSessions.map((session) => session.toJson()).toList(),
    };
  }
}

class GameSession {
  final DateTime date;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final String gameType;

  GameSession({
    required this.date,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.gameType,
  });

  double get accuracyRate => 
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      date: DateTime.parse(json['date']),
      score: json['score'],
      correctAnswers: json['correctAnswers'],
      totalQuestions: json['totalQuestions'],
      gameType: json['gameType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'gameType': gameType,
    };
  }
}
