import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../services/dictionary_service.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String? selectedLang = 'EN → ID';
  final TextEditingController inputController = TextEditingController();
  String translatedText = '';

  List<Map<String, dynamic>> _availableWords = [];
  bool _loadingWords = true;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadAvailableWords();
  }

  Future<void> _loadAvailableWords() async {
    try {
      final entries = await DictionaryService.fetchEntries();
      if (!mounted) return;
      setState(() {
        _availableWords = entries;
        _loadingWords = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingWords = false);
    }
  }

  Future<void> speakText(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await flutterTts.setLanguage(
        selectedLang == 'EN → ID' ? "id-ID" : "en-US",
      );

      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> translateWord() async {
    final input = inputController.text.trim().toLowerCase();
    if (input.isEmpty) return;

    final entries = await DictionaryService.fetchEntries();

    setState(() {
      translatedText = DictionaryService.translateText(
        entries,
        input,
        englishToId: selectedLang == 'EN → ID',
      );
    });
  }

  @override
  void dispose() {
    try {
      flutterTts.stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: Row(
          children: const [
            Icon(Icons.translate, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Translate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('EN → ID'),
                  selected: selectedLang == 'EN → ID',
                  selectedColor: Colors.grey.shade300,
                  onSelected: (_) {
                    setState(() => selectedLang = 'EN → ID');
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('ID → EN'),
                  selected: selectedLang == 'ID → EN',
                  selectedColor: Colors.blue.shade100,
                  onSelected: (_) {
                    setState(() => selectedLang = 'ID → EN');
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  TextField(
                    controller: inputController,
                    decoration: const InputDecoration(
                      hintText: "Enter text ...",
                      border: InputBorder.none,
                    ),
                    maxLines: 6,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: translateWord,
              child: const Text("Translate", style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Text(translatedText, style: const TextStyle(fontSize: 16)),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => speakText(translatedText),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Row(
              children: [
                Icon(Icons.menu_book, size: 20, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Available words',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_loadingWords)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_availableWords.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No words available yet.'),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in _availableWords)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            selectedLang == 'EN → ID'
                                ? '${item['word']} → ${item['meaning']}'
                                : '${item['meaning']} → ${item['word']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
