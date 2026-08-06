class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswerText;
  final int correctIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerText,
    required this.correctIndex,
  });

  factory QuizQuestion.fromRTDB(String key, Map<dynamic, dynamic> data) {
    final List<String> optionsList = List<String>.from(data['options'] ?? []);

    final int answerIndex = data['answer'] is int ? data['answer'] : -1;

    String correctAnsString =
        (answerIndex >= 0 && answerIndex < optionsList.length)
        ? optionsList[answerIndex]
        : '';

    return QuizQuestion(
      id: key,
      question: data['question'] ?? 'No Question',
      options: optionsList,
      correctAnswerText: correctAnsString,
      correctIndex: answerIndex,
    );
  }
}
