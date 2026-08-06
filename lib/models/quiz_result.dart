class QuizResult {
  final String userId;
  final String resultKey;
  final int correctAnswers;
  final int totalQuestions;
  final int questionsAnswered;
  final String category;
  final bool finishedEarly;
  final DateTime completedAt;

  String userEmail = 'Loading...';
  String userName = 'Loading...';

  QuizResult({
    required this.userId,
    required this.resultKey,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.questionsAnswered,
    required this.category,
    required this.finishedEarly,
    required this.completedAt,
  });

  factory QuizResult.fromMap(
    String userId,
    String resultKey,
    Map<dynamic, dynamic> data,
  ) {
    return QuizResult(
      userId: userId,
      resultKey: resultKey,

      correctAnswers: data['correctAnswers'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      questionsAnswered: data['questionsAnswered'] ?? 0,
      category: data['category'] ?? 'N/A',

      finishedEarly: data['finishedEarly'] == true,

      completedAt: DateTime.fromMillisecondsSinceEpoch(
        data['completedAt'] ?? 0,
      ),
    );
  }
}
