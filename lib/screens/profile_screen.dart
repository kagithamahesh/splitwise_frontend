import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sample/config/api.dart';
import 'package:sample/main.dart';
import 'package:sample/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool darkMode = themeNotifier.value == ThemeMode.dark;
  bool notifications = true;
  String currency = "INR (₹)";
  String name = "";
  String email = "";
  bool isLoading = true;

  Uint8List? _pickedImageBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
    _loadCurrency();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name     = prefs.getString("name")  ?? "";
      email    = prefs.getString("email") ?? "";
      darkMode = prefs.getBool('darkMode') ?? false;
      isLoading = false;
    });

    // GET /users/profile-image returns raw image bytes (image/jpeg)
    // Must send Authorization header — can't use Image.network directly.
    try {
      final token = prefs.getString("token") ?? "";
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users/profile-image"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200 && mounted) {
        setState(() => _pickedImageBytes = res.bodyBytes);
      }
    } catch (e) {
      debugPrint("Profile image fetch error: $e");
    }
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _isUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final filename = picked.name.isNotEmpty ? picked.name : 'image.jpg';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/users/profile-image"),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: filename,
        ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          // _pickedImageBytes already holds the local preview — keep it visible
          _isUploading = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      } else {
        setState(() => _isUploading = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text("Upload failed (${response.statusCode})."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      messenger.showSnackBar(SnackBar(content: Text("Upload error: $e")));
    }
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

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currency = prefs.getString("currency") ?? "INR (₹)";
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── Avatar ──────────────────────────────────────────────
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
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            settingsTile(
              icon: Icons.person_outline,
              title: "Personal Details",
              cardColor: cardColor,
              onTap: () {},
            ),

            currencyTile(cardColor: cardColor, isDark: isDark),

            switchTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              value: darkMode,
              cardColor: cardColor,
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
              cardColor: cardColor,
              onChanged: (val) => setState(() => notifications = val),
            ),

            settingsTile(
              icon: Icons.help_outline,
              title: "Help & Support",
              cardColor: cardColor,
              onTap: () {},
            ),

            settingsTile(
              icon: Icons.info_outline,
              title: "About Split Money",
              cardColor: cardColor,
              onTap: () {},
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove("token");

                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
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

  Widget _buildAvatar() {
    if (_pickedImageBytes != null) {
      return CircleAvatar(
        radius: 45,
        backgroundColor: const Color(0xffEEEAFE),
        backgroundImage: MemoryImage(_pickedImageBytes!),
      );
    }
    return const CircleAvatar(
      radius: 45,
      backgroundColor: Color(0xffEEEAFE),
      child: Icon(Icons.person, size: 50, color: Color(0xff5B4BFF)),
    );
  }

  Widget settingsTile({
    required IconData icon,
    required String title,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
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

  Widget currencyTile({required Color cardColor, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
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
            dropdownColor: isDark ? const Color(0xff2A2A2A) : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
            items: const [
              DropdownMenuItem(value: "INR (₹)", child: Text("INR")),
              DropdownMenuItem(value: "USD (\$)", child: Text("USD")),
              DropdownMenuItem(value: "EUR (€)", child: Text("EUR")),
            ],
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("currency", value!);
              setState(() {
                currency = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color cardColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff5B4BFF)),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
