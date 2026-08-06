import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../models/quiz_question.dart';

class QuizService {
  static const String quizPath = 'quiz';

  static Future<List<QuizQuestion>> fetchQuestions(String category) async {
    final DatabaseReference categoryRef = FirebaseDatabase.instance.ref(
      '$quizPath/$category',
    );

    try {
      final snapshot = await categoryRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);

        return rawData.entries
            .map(
              (entry) => QuizQuestion.fromRTDB(entry.key, entry.value as Map),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching quiz questions from RTDB: $e');
    }

    return [];
  }

  static Future<void> submitResult({
    required String userId,
    required String category,
    required int correctAnswers,
    required int totalQuestions,
    required int questionsAnswered,
    required bool finishedEarly,
  }) async {
    final DatabaseReference resultsRef = FirebaseDatabase.instance
        .ref('user_scores/$appIdentifier/users/$userId/results')
        .push();

    await resultsRef.set({
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'questionsAnswered': questionsAnswered,
      'completedAt': ServerValue.timestamp,
      'userId': userId,
      'category': category,
      'finishedEarly': finishedEarly,
    });
  }
}
