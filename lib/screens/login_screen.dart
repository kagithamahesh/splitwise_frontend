import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/config/api.dart';
import 'package:sample/screens/home_screen.dart';
import 'package:sample/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ================= LOGIN =================

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Email": emailController.text.trim(),
          "Password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final String token = data["token"];
        final user = data["user"] ?? {};

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", token);
        await prefs.setString("name", user["name"] ?? "");
        await prefs.setString("email", user["email"] ?? "");

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Login Success",
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        final errorMessage =
        data["message"]?.toString().isNotEmpty == true
            ? data["message"].toString()
            : "Login failed. Please check your credentials.";

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 29,
            vertical: 20,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =====================================================
              // LOGO
              // =====================================================

              const SizedBox(height: 8),

              Center(
                child: Container(
                  height: 115,
                  width: 115,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),

                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 18,
                        spreadRadius: 1,
                        color: Colors.black12,
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),

                    child: Image.asset(
                      'assets/split.png',
                      width: 105,
                      height: 105,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // =====================================================
              // WELCOME TEXT
              // =====================================================

              const SizedBox(height: 42),

              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff171820),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Login to continue managing shared expenses.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff9B9BA0),
                  fontWeight: FontWeight.w400,
                ),
              ),

              // =====================================================
              // EMAIL
              // =====================================================

              const SizedBox(height: 46),

              const Text(
                "Email",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff202127),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: emailController,

                keyboardType: TextInputType.emailAddress,

                decoration: InputDecoration(
                  hintText: "Enter your email",

                  hintStyle: const TextStyle(
                    fontSize: 17,
                    color: Color(0xff56565F),
                  ),

                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xff55555E),
                    size: 25,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 19,
                    horizontal: 18,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xff013A6F),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // =====================================================
              // PASSWORD
              // =====================================================

              const SizedBox(height: 27),

              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff202127),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: passwordController,

                obscureText: hidePassword,

                decoration: InputDecoration(
                  hintText: "Enter your password",

                  hintStyle: const TextStyle(
                    fontSize: 17,
                    color: Color(0xff56565F),
                  ),

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xff55555E),
                    size: 25,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },

                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,

                      color: const Color(0xff55555E),
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 19,
                    horizontal: 18,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xff013A6F),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // =====================================================
              // FORGOT PASSWORD
              // =====================================================

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,

                child: TextButton(
                  onPressed: () {},

                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                  ),

                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff5A58A1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // =====================================================
              // LOGIN BUTTON
              // =====================================================

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 69,

                child: ElevatedButton(
                  onPressed: isLoading ? null : loginUser,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff06477F),

                    disabledBackgroundColor:
                    const Color(0xff06477F),

                    elevation: 1,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // =====================================================
              // OR DIVIDER
              // =====================================================

              const SizedBox(height: 39),

              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xffC9C9D0),
                      thickness: 1,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 13,
                    ),

                    child: Text(
                      "OR",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff33333A),
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Divider(
                      color: Color(0xffC9C9D0),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              // =====================================================
              // GOOGLE BUTTON
              // =====================================================

              const SizedBox(height: 38),

              SizedBox(
                width: double.infinity,
                height: 69,

                child: OutlinedButton.icon(
                  onPressed: () {},

                  icon: const Text(
                    "G",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff5A58A1),
                    ),
                  ),

                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff5A58A1),
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xff85858D),
                      width: 1.2,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                ),
              ),

              // =====================================================
              // SIGN UP
              // =====================================================

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff55555E),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                          const SignupScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Sign Up",

                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff013A6F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}