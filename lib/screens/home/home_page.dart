import 'dart:async';
import 'package:flutter/material.dart';

import '../dictionary/dictionary_page.dart';
import '../quiz/quiz_page.dart';
import '../profile/profile_page.dart';
import '../translate/translate_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final List<String> slides = [
    "images/vocabulary.png",
    "images/quiz.png",
    "images/translate.png",
  ];

  late PageController _pageController;
  int currentSlide = 0;
  Timer? sliderTimer;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        currentSlide = (currentSlide + 1) % slides.length;
        _pageController.animateToPage(
          currentSlide,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(),
      const DictionaryPage(),
      const QuizPage(),
      const TranslatePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: index == 0
          ? AppBar(
              leading: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.home, color: Colors.white, size: 28),
              ),
              title: const Text(
                "Home",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              backgroundColor: Colors.indigo[900],
              elevation: 0,
            )
          : null,
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) => setState(() => index = value),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo[900],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: "Dictionary",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: "Quiz",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate_outlined),
            activeIcon: Icon(Icons.translate),
            label: "Translate",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),

          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() {
                  currentSlide = index;
                });
              },
              itemBuilder: (context, i) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(slides[i], fit: BoxFit.cover),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: currentSlide == i ? 30 : 12,
                height: 6,
                decoration: BoxDecoration(
                  color: currentSlide == i
                      ? Colors.indigo
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF4A63FF),
                  child: Text("👋", style: TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    "Welcome to Lingua! A language learning app with vocabulary, quizzes, and fast translation features.",
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Available Feature",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _featureBox(Icons.menu_book, "Dictionary"),
              _featureBox(Icons.translate, "Translate"),
              _featureBox(Icons.quiz, "Quiz"),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _featureBox(IconData icon, String title) {
    return Container(
      width: 130,
      height: 120,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 212, 230, 239),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black87),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
