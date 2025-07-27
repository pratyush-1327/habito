# Habito - Monthly Habit Tracker

A beautiful and intuitive monthly habit tracker built with Flutter, featuring Material 3 design and clean architecture.

## ✨ Features

- **📅 Monthly Calendar View**: Interactive calendar with color-coded habit indicators
- **✅ Habit Tracking**: Click on dates to mark habits as complete/incomplete
- **🎨 Custom Habits**: Create habits with custom names, icons, and colors
- **🌙 Dark/Light Theme**: Automatic theme switching based on system preference
- **📱 Material 3 Design**: Modern, expressive UI following Material 3 guidelines
- **💾 Local Storage**: All data stored locally using Hive database

## 🏗️ Architecture

This project follows Clean Architecture principles:

```
lib/
├── core/              # Core utilities and configuration
├── data/              # Data layer (repositories, models)
├── domain/            # Business logic (entities, use cases)
└── presentation/      # UI layer (pages, widgets, state management)
```

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC Pattern
- **Local Database**: Hive
- **Dependency Injection**: GetIt
- **Code Generation**: build_runner

## 🚀 Getting Started

1. **Prerequisites**
   - Flutter SDK (3.6.2 or higher)
   - Dart SDK
   - Android Studio / VS Code

2. **Installation**
   ```bash
   git clone https://github.com/your-username/habito.git
   cd habito
   flutter pub get
   dart run build_runner build
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 How to Use

1. **Add Habits**: Tap the "+" button to create new habits with custom icons and colors
2. **Track Progress**: Navigate to the calendar view and tap on dates to mark habits
3. **View Habits**: Switch to the habits tab to manage your habit list
4. **Monthly View**: Use navigation arrows to browse different months

## 🎨 Design

The app follows Material 3 design principles with:
- Dynamic color theming
- Expressive typography
- Smooth animations
- Intuitive navigation patterns

## 🔧 Development

To regenerate Hive adapters after modifying entities:
```bash
dart run build_runner build
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
