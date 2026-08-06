import 'package:firebase_database/firebase_database.dart';

class DictionaryService {
  static const String path = 'language';

  static List<Map<String, dynamic>> parseEntries(Object? raw) {
    final List<Map<String, dynamic>> items = [];

    if (raw is List) {
      for (final e in raw) {
        if (e == null) continue;

        final item = Map<String, dynamic>.from(e);
        items.add({
          'word': item['word'] ?? '',
          'meaning': item['meaning'] ?? '',
        });
      }
    }

    return items;
  }

  static Future<List<Map<String, dynamic>>> fetchEntries() async {
    final snapshot = await FirebaseDatabase.instance.ref(path).get();
    return parseEntries(snapshot.value);
  }

  static String translateText(
    List<Map<String, dynamic>> entries,
    String input, {
    required bool englishToId,
  }) {
    final List<String> words = input.split(' ');
    final List<Map<String, dynamic>> sorted = [...entries]
      ..sort(
        (a, b) => b['word']
            .toString()
            .split(' ')
            .length
            .compareTo(a['word'].toString().split(' ').length),
      );

    final List<String> result = [];
    int i = 0;

    while (i < words.length) {
      bool matched = false;

      for (final item in sorted) {
        String key = englishToId
            ? item['word'].toString().toLowerCase()
            : item['meaning'].toString().toLowerCase();

        final List<String> keyWords = key.split(' ');

        if (i + keyWords.length > words.length) continue;

        bool same = true;
        for (int k = 0; k < keyWords.length; k++) {
          if (words[i + k] != keyWords[k]) {
            same = false;
            break;
          }
        }

        if (same) {
          String value = englishToId ? item['meaning'] : item['word'];
          result.add(value);
          i += keyWords.length;
          matched = true;
          break;
        }
      }

      if (!matched) {
        result.add(words[i]);
        i++;
      }
    }

    return result.join(' ');
  }
}
