import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/quiz_question.dart';
import '../../services/quiz_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedCategory;

  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;

  String? _selectedAnswerText;
  int? _selectedIndex;

  String _userId = '';

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;

    if (user != null) {
      _userId = user.uid;
    } else {
      debugPrint(
        'Auth Warning: User is not logged in! Cannot proceed with quiz.',
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _selectCategory(String category) {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must log in first to start the quiz.'),
        ),
      );
      return;
    }

    setState(() {
      _selectedCategory = category;
      _questions = [];
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerText = null;
      _selectedIndex = null;
      _isLoading = true;
    });
    _fetchQuestions(category);
  }

  Future<void> _fetchQuestions(String category) async {
    _questions = await QuizService.fetchQuestions(category);

    _questions.shuffle(Random());

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleAnswer(int selectedIndex, String selectedAnswerText) {
    if (_selectedAnswerText != null) return;

    final currentQuestion = _questions[_currentQuestionIndex];

    if (selectedIndex == currentQuestion.correctIndex) {
      _score++;
    }

    setState(() {
      _selectedAnswerText = selectedAnswerText;
      _selectedIndex = selectedIndex;
    });
  }

  void _nextQuestion() {
    if (_selectedAnswerText == null) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerText = null;
        _selectedIndex = null;
      });
    } else {
      _submitQuizResult();
    }
  }

  Future<void> _submitQuizResult({bool interrupted = false}) async {
    final String? submittedCategory = _selectedCategory;

    if (_questions.isEmpty || _userId.isEmpty || submittedCategory == null) {
      setState(() => _isLoading = false);
      _showResultDialog(
        title: 'Save Failed ⛔️',
        content:
            'You must log in to save your score, or there are no questions loaded.',
        success: false,
        resetAction: _resetQuizState,
      );
      return;
    }

    setState(() => _isLoading = true);

    final totalAnswered = _currentQuestionIndex + 1;

    try {
      await QuizService.submitResult(
        userId: _userId,
        category: submittedCategory,
        correctAnswers: _score,
        totalQuestions: _questions.length,
        questionsAnswered: interrupted ? totalAnswered : _questions.length,
        finishedEarly: interrupted,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }

      _showResultDialog(
        title: interrupted ? 'Quiz Stopped' : 'Great job! Quiz Finished 🎉',
        content: interrupted
            ? 'Your current score: $_score out of $totalAnswered questions. Result saved successfully.'
            : 'Your final score: $_score out of ${_questions.length} questions. Result saved successfully!',
        success: true,
        resetAction: _resetQuizState,
      );
    } catch (e) {
      debugPrint('Error submitting result to RTDB: $e');

      if (mounted) {
        setState(() => _isLoading = false);
      }

      _showResultDialog(
        title: 'Save Failed ⚠️',
        content:
            'Your score: $_score. Failed to save the result to the database. Please try again.',
        success: false,
        resetAction: _resetQuizState,
      );
    }
  }

  void _resetQuizState() {
    if (mounted) {
      setState(() {
        _selectedCategory = null;
        _currentQuestionIndex = 0;
        _score = 0;
        _selectedAnswerText = null;
        _selectedIndex = null;
        _questions = [];
        _isLoading = false;
      });
    }
  }

  void _showFinishEarlyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Early?'),
        content: Text(
          'You have answered ${_currentQuestionIndex + 1} of ${_questions.length} questions. Your current score ($_score) will be submitted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Quiz'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              _submitQuizResult(interrupted: true);
            },
            child: const Text('Finish Now'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog({
    required String title,
    required String content,
    required bool success,
    required VoidCallback resetAction,
  }) {
    final String? categoryToRestart = _selectedCategory;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          actions: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue.shade700, width: 1.5),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  resetAction();
                },
                child: const Text(
                  'Another Quiz',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  if (categoryToRestart != null && _questions.isNotEmpty) {
                    _selectCategory(categoryToRestart);
                  } else {
                    resetAction();
                  }
                },
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

  Widget _buildCategorySelectionUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),

          Text(
            'Choose a Quiz Type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          _buildCategoryCard(
            title: 'Translation: English to Indonesian',
            subtitle: 'Test your English comprehension skills.',
            icon: Icons.g_translate,
            categoryKey: 'en_to_id',
            color: Colors.indigo.shade900,
          ),

          const SizedBox(height: 20),

          _buildCategoryCard(
            title: 'Translation: Indonesian to English',
            subtitle: 'Test your English translation skills.',
            icon: Icons.language,
            categoryKey: 'id_to_en',
            color: Colors.indigo.shade900,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String categoryKey,
    required Color color,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _isLoading ? null : () => _selectCategory(categoryKey),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _isLoading ? 'Loading...' : 'Start Quiz',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizUI() {
    if (_questions.isEmpty && _selectedCategory != null && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied,
                size: 50,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 10),
              Text(
                'Failed to load questions.\nMake sure the admin has added questions to the ${_selectedCategory == 'en_to_id' ? 'EN -> ID' : 'ID -> EN'} category.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetQuizState,
                child: const Text('Back to Quiz Selection'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
              Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),

          const Divider(height: 20, thickness: 1.5),

          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                currentQuestion.question,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 30),

          ...currentQuestion.options.asMap().entries.map((entry) {
            final int index = entry.key;
            final String option = entry.value;

            bool isSelected = _selectedIndex == index;
            bool isCorrectOption = index == currentQuestion.correctIndex;

            Color? tileColor = Colors.white;
            Color borderColor = Colors.blue.shade300;
            Color textColor = Colors.black87;

            if (_selectedAnswerText != null) {
              if (isCorrectOption) {
                tileColor = Colors.green.shade100;
                borderColor = Colors.green.shade700;
                textColor = Colors.green.shade900;
              } else if (isSelected) {
                tileColor = Colors.red.shade100;
                borderColor = Colors.red.shade700;
                textColor = Colors.red.shade900;
              }
            } else if (isSelected) {
              borderColor = Colors.blue.shade700;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                onTap: _selectedAnswerText == null
                    ? () => _handleAnswer(index, option)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: borderColor,

                    width: isSelected || _selectedAnswerText != null ? 3 : 1.5,
                  ),
                ),
                tileColor: tileColor,
                title: Text(
                  option,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: isSelected || _selectedAnswerText != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: textColor,
                  ),
                ),
                trailing: _selectedAnswerText != null
                    ? (isCorrectOption
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : isSelected
                          ? const Icon(Icons.cancel, color: Colors.red)
                          : null)
                    : null,
              ),
            );
          }),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: _selectedAnswerText == null ? null : _nextQuestion,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: Text(
              isLastQuestion
                  ? 'Submit Answer & Finish'
                  : 'Next Question',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          if (!isLastQuestion)
            TextButton(
              onPressed: _showFinishEarlyDialog,
              child: Text(
                'Finish Quiz Now',
                style: TextStyle(color: Colors.red.shade600, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'Language Test (Quiz)';
    if (_selectedCategory != null) {
      appBarTitle =
          'Quiz: ${_selectedCategory == 'en_to_id' ? 'EN -> ID' : 'ID -> EN'}';
    }

    return PopScope(
      canPop: _selectedCategory == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (_selectedCategory != null) {
          _showFinishEarlyDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            appBarTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          automaticallyImplyLeading: false,
          leading: null,

          backgroundColor: Colors.indigo[900],
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : _selectedCategory == null
            ? _buildCategorySelectionUI()
            : _buildQuizUI(),
      ),
    );
  }
}
