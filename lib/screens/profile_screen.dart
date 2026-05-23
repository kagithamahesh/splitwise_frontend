import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool darkMode = false;
  bool notifications = true;
  String currency = "INR (₹)";

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

            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xffEEEAFE),
              child: Icon(
                Icons.person,
                size: 50,
                color: Color(0xff5B4BFF),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Jack",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "jack@example.com",
              style: TextStyle(color: Colors.grey),
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
              onChanged: (val) {
                setState(() {
                  darkMode = val;
                });
              },
            ),

            switchTile(
              icon: Icons.notifications_none,
              title: "Notifications",
              value: notifications,
              onChanged: (val) {
                setState(() {
                  notifications = val;
                });
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
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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
          const Icon(Icons.currency_rupee,
              color: Color(0xff5B4BFF)),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "Currency",
              style: TextStyle(fontSize: 16),
            ),
          ),
          DropdownButton<String>(
            value: currency,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: "INR (₹)",
                child: Text("INR"),
              ),
              DropdownMenuItem(
                value: "USD (\$)",
                child: Text("USD"),
              ),
              DropdownMenuItem(
                value: "EUR (€)",
                child: Text("EUR"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                currency = value!;
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
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xff5B4BFF),
          ),
        ],
      ),
    );
  }
}