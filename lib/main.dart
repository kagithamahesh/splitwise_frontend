import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';

/// Global notifier so any screen can toggle the theme.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore saved theme preference.
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Split Money',
          themeMode: mode,

          // ── Light theme ──────────────────────────────────────────────
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xff5B4BFF),
            scaffoldBackgroundColor: const Color(0xffF8F9FF),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
          ),

          // ── Dark theme ───────────────────────────────────────────────
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xff5B4BFF),
            scaffoldBackgroundColor: const Color(0xff121212),
            cardColor: const Color(0xff1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}
