class ApiConfig {
  static const String baseUrl =
      "http://192.168.1.34:8080";
// }
// static const String baseUrl =
//     "https://splitwise-6poo.onrender.com";
}
// 10.0.2.2

// ── Development note ────────────────────────────────────────────────────────
// Flutter Web picks a random port on every `flutter run`. The backend embeds
// FRONTEND_URL into every invite link, so that URL must match the port Flutter
// is actually serving on.
//
// Always start the app with a fixed port so the link works:
//   flutter run -d chrome --web-port=57753
//
// And set the backend environment variable to match:
//   FRONTEND_URL=http://localhost:57753
//
// For production set FRONTEND_URL to your real domain, e.g.:
//   FRONTEND_URL=https://finsplit.app
// ────────────────────────────────────────────────────────────────────────────