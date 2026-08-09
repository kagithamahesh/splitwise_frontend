import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sample/config/api.dart';
import 'package:sample/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool darkMode = themeNotifier.value == ThemeMode.dark;
  bool notifications = true;
  String currency = "INR (₹)";
  String name = "";
  String email = "";
  bool isLoading = true;

  /// Local file chosen by the picker (not yet uploaded / just uploaded).
  File? _pickedImage;

  /// Remote URL returned by the server after a successful upload.
  String? _avatarUrl;

  /// True while the upload HTTP request is in flight.
  bool _isUploading = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "";
      email = prefs.getString("email") ?? "";
      _avatarUrl = prefs.getString("avatarUrl");
      darkMode = prefs.getBool('darkMode') ?? false;
      isLoading = false;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Image pick + upload
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickAndUpload(ImageSource source) async {
    // Capture context-dependent references before any await.
    final messenger = ScaffoldMessenger.of(context);

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return; // user cancelled

    setState(() {
      _pickedImage = File(picked.path);
      _isUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/user/upload-avatar"),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath('avatar', picked.path),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Server may return the hosted URL; fall back to local file display.
        final url = _parseAvatarUrl(response.body);
        await prefs.setString("avatarUrl", url ?? "");
        setState(() {
          _avatarUrl = url;
          _isUploading = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      } else {
        setState(() => _isUploading = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text("Upload failed (${response.statusCode}). "
                "Showing local preview."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      messenger.showSnackBar(
        SnackBar(content: Text("Upload error: $e")),
      );
    }
  }

  /// Tries to parse the avatar URL from the server's JSON response body.
  String? _parseAvatarUrl(String body) {
    // Handles: {"url":"https://..."} or {"avatarUrl":"https://..."}
    final urlMatch = RegExp(r'"(?:url|avatarUrl|avatar)"\s*:\s*"([^"]+)"')
        .firstMatch(body);
    return urlMatch?.group(1);
  }

  void _showPickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xff5B4BFF)),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xff5B4BFF)),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── Avatar with edit button ──────────────────────────────
            GestureDetector(
              onTap: _showPickerDialog,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _buildAvatar(),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xff5B4BFF),
                      shape: BoxShape.circle,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              email,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            settingsTile(
              icon: Icons.person_outline,
              title: "Personal Details",
              onTap: () {},
            ),

            currencyTile(),

            switchTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              value: darkMode,
              onChanged: (val) async {
                setState(() => darkMode = val);
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('darkMode', val);
              },
            ),

            switchTile(
              icon: Icons.notifications_none,
              title: "Notifications",
              value: notifications,
              onChanged: (val) {
                setState(() => notifications = val);
              },
            ),

            settingsTile(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {},
            ),

            settingsTile(
              icon: Icons.info_outline,
              title: "About Split Money",
              onTap: () {},
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (!mounted) return;
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Avatar widget — local file > remote URL > placeholder icon
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAvatar() {
    ImageProvider? imageProvider;

    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_avatarUrl!);
    }

    return CircleAvatar(
      radius: 45,
      backgroundColor: const Color(0xffEEEAFE),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(Icons.person, size: 50, color: Color(0xff5B4BFF))
          : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tile helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xff5B4BFF)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget currencyTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.currency_rupee, color: Color(0xff5B4BFF)),
          const SizedBox(width: 15),
          const Expanded(
            child: Text("Currency", style: TextStyle(fontSize: 16)),
          ),
          DropdownButton<String>(
            value: currency,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: "INR (₹)", child: Text("INR")),
              DropdownMenuItem(value: "USD (\$)", child: Text("USD")),
              DropdownMenuItem(value: "EUR (€)", child: Text("EUR")),
            ],
            onChanged: (value) => setState(() => currency = value!),
          ),
        ],
      ),
    );
  }

  Widget switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff5B4BFF)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xff5B4BFF),
          ),
        ],
      ),
    );
  }
}
