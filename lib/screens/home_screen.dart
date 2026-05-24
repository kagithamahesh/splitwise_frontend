import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/config/api.dart';
import 'package:sample/screens/group_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_expense_screen.dart';
import 'activity_screen.dart';
import 'friends_screen.dart';
import 'profile_screen.dart';
import 'create_group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  bool isLoading = true;
  Map<String, dynamic> homeData = {};

  @override
  void initState() {
    super.initState();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/home"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        homeData = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> goToCreateGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );

    if (result == true) {
      fetchHomeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomePage(),
      const ActivityScreen(),
      const FriendsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[selectedIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5B4BFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff5B4BFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: "Activity",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_rounded),
            label: "Friends",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    final groups = homeData["groups"] ?? [];
    final friends = homeData["friends"] ?? [];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: fetchHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(
                "Hi ${homeData["userName"] ?? "User"} 👋",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Manage your shared expenses easily",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 25),

              // TOTAL BALANCE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff5B4BFF), Color(0xff6A5CFF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "₹ ${homeData["totalBalance"] ?? 0}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: balanceCard(
                      title: "You Owe",
                      amount: "₹ ${homeData["youOwe"] ?? 0}",
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: balanceCard(
                      title: "You Get",
                      amount: "₹ ${homeData["youGet"] ?? 0}",
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Groups",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: goToCreateGroup,
                    child: const Text("Create"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // EMPTY GROUP STATE
              if (groups.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.group_off_rounded,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "No Groups Yet",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Create your first group and split expenses easily",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: goToCreateGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff5B4BFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Create Group",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // GROUP LIST
              if (groups.isNotEmpty)
                ...groups.map<Widget>((group) {
                  int balance = group["balance"] ?? 0;
                  print(group);
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDetailsScreen(
                            groupId: group["id"],
                            groupName: group["name"],
                          ),
                        ),
                      );

                      if (result == true) {
                        fetchHomeData();
                      }
                    },

                    child: groupTile(
                      icon: Icons.group,
                      title: group["name"] ?? "",
                      subtitle: "${group["members"] ?? 0} members",
                      amount: "₹ $balance",
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
                  );
                }).toList(),

              const SizedBox(height: 28),

              const Text(
                "Friends",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              if (friends.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "No friends added yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              if (friends.isNotEmpty)
                ...friends.map<Widget>((friend) {
                  return friendTile(
                    friend["type"] == "owes_you"
                        ? "${friend["name"]} owes you"
                        : "You owe ${friend["name"]}",
                    "₹ ${friend["amount"]}",
                    friend["type"] == "owes_you" ? Colors.green : Colors.red,
                  );
                }).toList(),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget balanceCard({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(title),
          const SizedBox(height: 10),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget groupTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffEEEAFE),
            child: Icon(icon, color: const Color(0xff5B4BFF)),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          Text(
            amount,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget friendTile(String title, String amount, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xffEEEAFE),
        child: Icon(Icons.person, color: Color(0xff5B4BFF)),
      ),
      title: Text(title),
      trailing: Text(
        amount,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
