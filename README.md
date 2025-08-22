# ⏳ Time Of Mine

A modern ⌚ time management app built with Flutter 🚀

---

## 📌 Overview

**Time Of Mine** is a feature-packed productivity app designed to make organizing your day simple & efficient.  
It offers powerful tools for event planning, task tracking, and manual sync between devices.

---

## ✨ Features

- 📅 **Calendar with Event Markers**  
  Add ➕, Edit ✏️, and Delete ❌ your events effortlessly.

- 📝 **Task Management**  
  Keep your to-do list organized & under control.

- 🔍 **Date Filters**  
  Filter events & tasks by specific dates with ease.

- 🔐 **Authentication**  
  Sign in with Firebase Auth 🔑 or continue as a guest 👤.

- 🔄 **Manual Sync**  
  Full control over syncing between Firestore ☁️ & Local Storage 💾.

- 👤 **Profile Editing**  
  Update your Name & Password anytime.

- 🌗 **Dark / Light Themes**  
  Adaptive UI for better user experience.

- 🎉 **Holiday Integration**  
  Uses Holiday API to display official holidays.

---

## 🛠 Tech Stack

- ⚡ **Flutter (Dart)**
- ☁️ **Firebase** – Auth & Firestore
- 💾 **SharedPreferences** – Local Storage
- 📅 **Holiday API** – Holidays Data Integration

---

## 🚀 Getting Started

### ✅ Requirements

- Flutter SDK
- Dart
- Firebase Project
- Holiday API Key

---

### 📦 Installation

1. **Clone the repository**
   ```sh
   https://github.com/CrabRus/Time-of-Mine.git  
   cd time_of_mine
   ```

2. **Install dependencies**
   ```sh
   flutter pub get
   ```

3. **Set up Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
   - Update `firebase_options.dart` if needed.

4. **Configure Holiday API**
   - Add your Holiday API key to the `.env` file.

5. **Run the app**
   ```sh
   flutter run
   ```

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙌 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.