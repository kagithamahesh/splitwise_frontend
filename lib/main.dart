import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/invite.dart';
import 'screens/join_group_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

/// Global notifier so any screen can toggle the theme.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _restoreTheme();
  }

  Future<void> _restoreTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('darkMode') ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

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
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xff5B4BFF),
              unselectedItemColor: Colors.grey,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            switchTheme: SwitchThemeData(
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xff5B4BFF)
                    : Colors.grey.shade300,
              ),
            ),
          ),

          // ── Dark theme ───────────────────────────────────────────────
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xff5B4BFF),
            scaffoldBackgroundColor: const Color(0xff121212),
            cardColor: const Color(0xff1E1E1E),
            dividerColor: Colors.white12,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff1A1A1A),
              elevation: 0,
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
              bodySmall: TextStyle(color: Colors.white60),
              titleLarge: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xff1A1A1A),
              selectedItemColor: Color(0xff9B8FFF),
              unselectedItemColor: Colors.grey,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xff2A2A2A),
              hintStyle: const TextStyle(color: Colors.white38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            switchTheme: SwitchThemeData(
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xff9B8FFF)
                    : Colors.white24,
              ),
            ),
            dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(color: Colors.white),
            ),
          ),

          home: const InviteEntryScreen(),
        );
      },
    );
  }
}

// ── Invite entry point ────────────────────────────────────────────────────────
// Shown for one frame while the URL and session are inspected.
// Immediately replaces itself with the correct screen.

class InviteEntryScreen extends StatefulWidget {
  const InviteEntryScreen({super.key});

  @override
  State<InviteEntryScreen> createState() => _InviteEntryScreenState();
}

class _InviteEntryScreenState extends State<InviteEntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleEntry());
  }

  Future<void> _handleEntry() async {
    final inviteToken = getInviteTokenFromUrl();

    if (!mounted) return;

    if (inviteToken != null) {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = (prefs.getString('token') ?? '').isNotEmpty;

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isLoggedIn
              ? JoinGroupScreen(inviteCode: inviteToken)
              : LoginScreen(inviteCode: inviteToken),
        ),
      );
      return;
    }

    // No invite in the URL — normal startup.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shown for at most one frame before navigation replaces it.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
