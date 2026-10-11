import 'package:flutter/material.dart';
import 'package:sample/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  static const Color primaryBlue = Color(0xff06477F);

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Track Shared Expenses",
      "description":
      "Keep all group spending organized in one place.",
    },
    {
      "title": "Split Bills Easily",
      "description":
      "Divide rent, food, trips and more instantly.",
    },
    {
      "title": "Settle Fast",
      "description":
      "See balances and settle payments smoothly.",
    },
  ];

  // ============================================================
  // GO TO NEXT PAGE
  // ============================================================

  void nextPage() {
    if (currentPage < 2) {
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      goToLogin();
    }
  }

  // ============================================================
  // SKIP
  // ============================================================

  void skipOnboarding() {
    goToLogin();
  }

  // ============================================================
  // GO TO LOGIN
  // ============================================================

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(inviteCode: '',),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      body: SafeArea(
        child: Stack(
          children: [

            // ====================================================
            // PAGES
            // ====================================================

            PageView(
              controller: _pageController,

              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },

              children: [
                buildPage(
                  title: "Track Shared Expenses",
                  description:
                  "Keep all group spending organized in one place.",
                ),

                buildPage(
                  title: "Split Bills Easily",
                  description:
                  "Divide rent, food, trips and more instantly.",
                ),

                buildPage(
                  title: "Settle Fast",
                  description:
                  "See balances and settle payments smoothly.",
                ),
              ],
            ),

            // ====================================================
            // SKIP
            // ====================================================

            Positioned(
              top: 8,
              right: 16,

              child: TextButton(
                onPressed: skipOnboarding,

                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),

                child: const Text(
                  "Skip",

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: primaryBlue,
                  ),
                ),
              ),
            ),

            // ====================================================
            // BOTTOM CONTROLS
            // ====================================================

            Positioned(
              left: 14,
              right: 14,
              bottom: 2,

              child: Column(
                children: [

                  // ==================================================
                  // DOTS
                  // ==================================================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      buildDot(0),
                      buildDot(1),
                      buildDot(2),
                    ],
                  ),

                  const SizedBox(height: 29),

                  // ==================================================
                  // BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: nextPage,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 1,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(17),
                        ),
                      ),

                      child: Text(
                        currentPage == 2
                            ? "Get Started"
                            : "Next",

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ONBOARDING PAGE
  // ============================================================

  Widget buildPage({
    required String title,
    required String description,
  }) {
    return Column(
      children: [

        // ========================================================
        // TOP SPACE
        // ========================================================

        const SizedBox(height: 70),

        // ========================================================
        // LOGO
        // ========================================================

        Expanded(
          flex: 5,

          child: Center(
            child: Container(
              width: 220,
              height: 220,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(30),

                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: Offset(0, 5),
                  ),
                ],
              ),

              padding: const EdgeInsets.all(15),

              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(15),

                child: Image.asset(
                  "assets/split.png",

                  fit: BoxFit.contain,

                  errorBuilder:
                      (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // ========================================================
        // TEXT
        // ========================================================

        Expanded(
          flex: 3,

          child: Column(
            children: [

              Text(
                title,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff202127),
                ),
              ),

              const SizedBox(height: 15),

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 25,
                ),

                child: Text(
                  description,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff9B9BA0),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ========================================================
        // BOTTOM SPACE
        // ========================================================

        const SizedBox(height: 150),
      ],
    );
  }

  // ============================================================
  // DOT
  // ============================================================

  Widget buildDot(int index) {
    final bool active = currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),

      width: active ? 24 : 8,
      height: 8,

      decoration: BoxDecoration(
        color: active
            ? primaryBlue
            : const Color(0xffD9DCE2),

        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }
}