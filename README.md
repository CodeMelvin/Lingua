# 📖 Lingua

> A Flutter language learning app with a vocabulary dictionary, English–Indonesian translator, and interactive quizzes.

## ✨ Features

- 🗣️ **Vocabulary Dictionary** — browse everyday words with English–Indonesian translations and search
- 🌐 **Translator** — translate text between English and Indonesian (with text-to-speech)
- 🧠 **Quizzes** — multiple-choice quizzes in `en_to_id` and `id_to_en` directions
- 📊 **User Scores** — per-user quiz history with score tracking
- 🔐 **Accounts** — sign up, sign in, and reset your password (Firebase Authentication)
- ⚙️ **Admin Dashboard** — manage quiz questions and view all user scores (admin role)
- 🖼️ **Profile Photo** — pick a photo from gallery or camera (session only)

---

## 🛠️ Built With

- 🟣 **Flutter** — cross-platform UI framework (Dart)
- 🔥 **Firebase** — Authentication (Email/Password), Realtime Database
- 🗄️ **flutter_tts** — text-to-speech for pronunciation

---

## 🔑 Demo Account

| Role | Email | Password | Access |
|---|---|---|---|
| User | `demo@lingua.app` | `demo123` | Browse dictionary, take quizzes, view own scores |

> You can also register a new account from the **Register** screen (role: user).
>
> ⚠️ The demo account is a **regular user** — with the published database rules it can only read the dictionary/quiz and write its **own** score. It cannot read other users' data, delete or edit quiz questions, or modify any other data.

---

## 🚀 Getting Started

### Option A - Install the APK (fastest)

Download `Lingua-v1.0.0.apk` from the [Releases](../../releases) section and install it on any Android device (Android 8.0+). The app connects to the project's Firebase backend.

### Option B - Run with VS Code

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and the **Flutter** extension in VS Code
2. Open the project folder: `File → Open Folder → C:\Users\kokny\Documents\Github File\Lingua`
3. Connect an Android device (USB debugging) or start an Android emulator
4. Press `F5` (or the **Run ▸ Start Debugging** menu) with `lib/main.dart` open
5. Alternatively, run `flutter run` in the terminal

> 💡 Lingua is an Android-first app (Firebase config is set for Android). On web/desktop the Firebase settings are placeholders.

### Option C - Build from the command line

```bash
flutter pub get
flutter run                       # run on a connected device/emulator
flutter build apk --release       # build the release APK
```

---

## 🗄️ Using Your Own Firebase Database

The app currently points to the owner's Firebase project (`android/app/google-services.json` + `lib/firebase_options.dart`). To use **your own** Firebase backend:

1. Create a project at [Firebase Console](https://console.firebase.google.com/) and add an **Android app** with package name `com.codemelvin.lingua`
2. Download the generated `google-services.json` and replace `android/app/google-services.json`
3. In **Authentication → Sign-in method**, enable **Email/Password**
4. In **Realtime Database**, create a database and paste the security rules (below)
5. Optionally import the data (nodes: `language`, `quiz`, `accounts`, `user_scores`) or seed `language`/`quiz` yourself
6. Update the Firebase values in `lib/firebase_options.dart` (apiKey, appId, projectId, databaseURL, messagingSenderId) to match your project

**Recommended Realtime Database rules:**

```json
{
  "rules": {
    "accounts": {
      ".read": "auth != null && root.child('accounts').child(auth.uid).child('role').val() == 'admin'",
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid && newData.child('role').val() == 'user'"
      }
    },
    "language": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('accounts').child(auth.uid).child('role').val() == 'admin'"
    },
    "quiz": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('accounts').child(auth.uid).child('role').val() == 'admin'"
    },
    "user_scores": {
      ".read": "auth != null && root.child('accounts').child(auth.uid).child('role').val() == 'admin'",
      "lingua-quiz-app": {
        "users": {
          "$uid": {
            ".read": "auth != null && auth.uid == $uid",
            ".write": "auth != null && auth.uid == $uid"
          }
        }
      }
    }
  }
}
```

---

## 📁 Project Structure

```
lib/
├── constants.dart               # App constants (quiz app identifier)
├── firebase_options.dart        # Firebase project configuration
├── main.dart                    # Entry point & routes
├── models/
│   ├── quiz_question.dart       # Quiz question model
│   └── quiz_result.dart         # Quiz result model
├── services/
│   ├── dictionary_service.dart  # Dictionary / translation logic
│   └── quiz_service.dart        # Quiz fetch & result submission
└── screens/
    ├── auth/                    # Slider, login, register, forgot password
    ├── home/                    # Main dashboard
    ├── dictionary/              # Vocabulary dictionary
    ├── translate/               # Translator
    ├── quiz/                    # Quiz player & question management
    ├── profile/                 # Profile & logout
    └── admin/                   # Admin dashboard & user scores
```

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Melvin** ([@CodeMelvin](https://github.com/CodeMelvin))
