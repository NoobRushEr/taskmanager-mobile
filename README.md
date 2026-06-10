# taskmanager_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



## Firebase (FlutterFire) setup — recommended workflow

Use the FlutterFire CLI to configure Firebase for this Flutter project. The CLI can generate `lib/firebase_options.dart` and help set up platform files. Keep platform config files out of version control.

1. Install required tooling

```bash
# Firebase CLI (needed for some flows)
npm install -g firebase-tools

# FlutterFire CLI (Dart global package)
dart pub global activate flutterfire_cli

firebase login
# From the project root, run and follow prompts:
flutterfire configure --project your-firebase-project-id