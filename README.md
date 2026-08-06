# 📖 Lingua

Lingua is a language learning app built with Flutter that helps you expand your vocabulary through an interactive dictionary, quizzes, and a built-in translator.

## ✨ Features

- 🗣️ **Vocabulary Dictionary** — browse a collection of everyday words with English–Indonesian translations
- 🌐 **Translator** — translate text back and forth between English and Indonesian
- 🧠 **Quizzes** — test your knowledge with multiple-choice quizzes in both `en_to_id` and `id_to_en` directions
- 📊 **User Scores** — track your quiz results and review your progress
- 👤 **Accounts** — sign up, sign in, and reset your password with Firebase Authentication
- 🛡️ **Admin Dashboard** — manage quizzes and view user scores (admin role)

## 🧰 Tech Stack

- **Flutter** — cross-platform UI framework
- **Firebase** — Authentication, Realtime Database, and Storage
- **Dart** — programming language

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- A Firebase project with **Email/Password** authentication enabled and a **Realtime Database**

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/CodeMelvin/Lingua.git
   cd Lingua
   ```

2. Place your own `google-services.json` (from your Firebase console → *Project settings → Your apps*) into `android/app/`.

3. Update the Firebase configuration in `lib/firebase_options.dart` to match your project.

4. Run the app:

   ```bash
   flutter pub get
   flutter run
   ```

5. Build a release APK:

   ```bash
   flutter build apk --release
   ```

The app expects four top-level nodes in your Realtime Database: `accounts`, `language`, `quiz`, and `user_scores`.

## 🧪 Testing

```bash
flutter test
```

## 📝 License

This project is licensed under the [MIT License](LICENSE).

**Melvin** ([@CodeMelvin](https://github.com/CodeMelvin)) — *built with 💙*
