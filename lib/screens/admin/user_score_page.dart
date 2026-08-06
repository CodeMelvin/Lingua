import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/quiz_result.dart';

class UserScorePage extends StatefulWidget {
  const UserScorePage({super.key});

  @override
  State<UserScorePage> createState() => _UserScorePageState();
}

class _UserScorePageState extends State<UserScorePage> {
  List<QuizResult> _allResults = [];
  bool _isLoading = true;
  String _error = '';

  Map<String, Map<String, String>> _userInfo = {};

  @override
  void initState() {
    super.initState();
    _fetchAllScores();
  }

  Future<void> _fetchUserInfo(Set<String> uids) async {
    if (uids.isEmpty) return;

    final DatabaseReference accountsRef = FirebaseDatabase.instance.ref(
      'accounts',
    );
    final Map<String, Map<String, String>> fetchedInfo = {};

    try {
      final snapshot = await accountsRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);

        for (var uid in uids) {
          final accountData = rawData[uid];
          if (accountData != null && accountData is Map) {
            fetchedInfo[uid] = {
              'email': accountData['email'] ?? 'Email Not Found',
              'username': accountData['username'] ?? 'Name Not Found',
            };
          } else {
            fetchedInfo[uid] = {
              'email': 'UID: $uid',
              'username': 'Name Not Found',
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }

    if (mounted) {
      setState(() {
        _userInfo.addAll(fetchedInfo);
      });
    }
  }

  Future<void> _fetchAllScores() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _allResults = [];
      _userInfo = {};
    });

    final DatabaseReference scoresRef = FirebaseDatabase.instance.ref(
      'user_scores/$appIdentifier/users',
    );

    try {
      final snapshot = await scoresRef.get();
      final Set<String> uidsToFetch = {};

      if (snapshot.exists && snapshot.value is Map) {
        final rawUsers = Map<String, dynamic>.from(snapshot.value as Map);

        for (var userEntry in rawUsers.entries) {
          final String userId = userEntry.key;
          uidsToFetch.add(userId);

          final Map<dynamic, dynamic> rawResults = Map<dynamic, dynamic>.from(
            userEntry.value['results'] ?? {},
          );

          for (var resultEntry in rawResults.entries) {
            final String resultKey = resultEntry.key;
            final Map<dynamic, dynamic> resultData = Map<dynamic, dynamic>.from(
              resultEntry.value,
            );

            _allResults.add(QuizResult.fromMap(userId, resultKey, resultData));
          }
        }

        _allResults.sort((a, b) => b.completedAt.compareTo(a.completedAt));

        await _fetchUserInfo(uidsToFetch);
      } else {
        _error = 'No user score data yet.';
      }
    } catch (e) {
      debugPrint('Error fetching scores: $e');
      if (e.toString().contains('permission-denied')) {
        _error =
            'Failed to load scores: Access Denied (Check your Firebase Rules).';
      } else {
        _error =
            'An error occurred while loading data: ${e.toString().split(':')[0]}';
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;

        for (var result in _allResults) {
          final info = _userInfo[result.userId];
          result.userEmail = info?['email'] ?? result.userEmail;
          result.userName = info?['username'] ?? result.userName;
        }
      });
    }
  }

  String _getCategoryDisplay(String categoryKey) {
    switch (categoryKey) {
      case 'en_to_id':
        return 'Translation EN -> ID';
      case 'id_to_en':
        return 'Translation ID -> EN';
      default:
        return categoryKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Score History (Admin)'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchAllScores,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _allResults.length,
              itemBuilder: (context, index) {
                final result = _allResults[index];

                final answeredVsTotalText =
                    'Answered: ${result.questionsAnswered} of ${result.totalQuestions} questions';
                final categoryDisplay = _getCategoryDisplay(result.category);
                final finishedText = result.finishedEarly
                    ? 'Stopped Early'
                    : 'Completed';

                final dateText = DateFormat(
                  'dd MMM yyyy, HH:mm',
                ).format(result.completedAt);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: result.finishedEarly
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      child: Text(
                        result.correctAnswers.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: result.finishedEarly
                              ? Colors.orange.shade900
                              : Colors.green.shade900,
                        ),
                      ),
                    ),

                    title: Text(
                      result.userEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'User: ${result.userName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text('Category: $categoryDisplay'),
                        Text(answeredVsTotalText),
                        Text(
                          finishedText,
                          style: TextStyle(
                            color: result.finishedEarly
                                ? Colors.orange.shade800
                                : Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Time: $dateText',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: null,
                    onTap: null,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAllScores,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
