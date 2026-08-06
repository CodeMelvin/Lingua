import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class QuizManagementPage extends StatefulWidget {
  const QuizManagementPage({super.key});

  @override
  State<QuizManagementPage> createState() => _QuizManagementPageState();
}

class _QuizManagementPageState extends State<QuizManagementPage> {
  final DatabaseReference _quizRef = FirebaseDatabase.instance.ref('quiz');
  String _selectedCategory = 'en_to_id';
  Map<String, dynamic> _quizQuestions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _quizRef.child(_selectedCategory).get();
      if (snapshot.exists && snapshot.value is Map) {
        final Map<String, dynamic> rawData = Map<String, dynamic>.from(
          snapshot.value as Map,
        );
        _quizQuestions = rawData;
      } else {
        _quizQuestions = {};
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load questions: $e")));
      }
      _quizQuestions = {};
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteQuestion(String questionKey) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _quizRef.child(_selectedCategory).child(questionKey).remove();
      _fetchQuestions();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Question deleted successfully!")));
      }
    }
  }

  void _openQuestionForm({String? key, Map? questionData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuestionForm(
        category: _selectedCategory,
        questionKey: key,
        initialData: questionData,
        onSave: _fetchQuestions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Quiz Questions"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton('en_to_id', 'EN -> ID'),
                _buildCategoryButton('id_to_en', 'ID -> EN'),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _quizQuestions.isEmpty
                ? Center(
                    child: Text(
                      "No questions in the ${_selectedCategory == 'en_to_id' ? 'EN -> ID' : 'ID -> EN'} category. Please add a question.",
                    ),
                  )
                : ListView(
                    children: _quizQuestions.entries.map((entry) {
                      final key = entry.key;
                      final data = Map<String, dynamic>.from(entry.value);
                      final question = data['question'] ?? 'No Question';
                      final options = List<String>.from(data['options'] ?? []);
                      final correctAnswerIndex = data['answer'] ?? 0;
                      final correctAnswer =
                          (correctAnswerIndex >= 0 &&
                              correctAnswerIndex < options.length)
                          ? options[correctAnswerIndex]
                          : 'N/A';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            question,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text("Answer: $correctAnswer"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _openQuestionForm(
                                  key: key,
                                  questionData: data,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteQuestion(key),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openQuestionForm(),
        label: Text(
          "Add Question (${_selectedCategory == 'en_to_id' ? 'EN -> ID' : 'ID -> EN'})",
        ),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCategoryButton(String category, String label) {
    return ElevatedButton(
      onPressed: () {
        if (_selectedCategory == category) return;
        setState(() {
          _selectedCategory = category;
        });
        _fetchQuestions();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategory == category
            ? Colors.blue.shade700
            : Colors.grey.shade300,
        foregroundColor: _selectedCategory == category
            ? Colors.white
            : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}

class QuestionForm extends StatefulWidget {
  final String category;
  final String? questionKey;
  final Map? initialData;
  final VoidCallback onSave;

  const QuestionForm({
    super.key,
    required this.category,
    this.questionKey,
    this.initialData,
    required this.onSave,
  });

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int _correctAnswerIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      _questionController.text = widget.initialData!['question'] ?? '';

      final options = List<String>.from(widget.initialData!['options'] ?? []);
      for (int i = 0; i < options.length && i < 4; i++) {
        _optionControllers[i].text = options[i];
      }
      _correctAnswerIndex = widget.initialData!['answer'] ?? 0;
    }
  }

  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      final options = _optionControllers.map((c) => c.text).toList();

      final data = {
        'question': _questionController.text,
        'options': options,
        'answer': _correctAnswerIndex,
      };

      final DatabaseReference ref = FirebaseDatabase.instance.ref(
        'quiz/${widget.category}',
      );

      try {
        if (widget.questionKey == null) {
          await ref.push().set(data);
        } else {
          await ref.child(widget.questionKey!).set(data);
        }

        widget.onSave();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Question saved successfully!")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed to save data: $e")));
        }
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.questionKey == null ? 'Add New Question' : 'Edit Question',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Category: ${widget.category == 'en_to_id' ? 'English to Indonesian' : 'Indonesian to English'}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Question is required.'
                    : null,
              ),
              const SizedBox(height: 10),

              RadioGroup<int>(
                groupValue: _correctAnswerIndex,
                onChanged: (value) {
                  setState(() {
                    _correctAnswerIndex = value ?? 0;
                  });
                },
                child: Column(
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                labelText:
                                    'Option ${index + 1} ${index == _correctAnswerIndex ? '(Correct Answer)' : ''}',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Option ${index + 1} is required.'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saveQuestion,
                icon: const Icon(Icons.save),
                label: const Text('Save Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
