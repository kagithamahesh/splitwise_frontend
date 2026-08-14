import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sample/config/api.dart';
import 'package:sample/screens/chat_screen.dart';
import 'package:sample/screens/group_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      const ChatScreen(),
      const FriendsScreen(),
      ProfileScreen(onBack: () => setState(() => selectedIndex = 0)),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  "Exit",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: selectedIndex,
              children: pages,
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5B4BFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Re-fetch home data whenever the user taps back to the Home tab
          if (index == 0 && selectedIndex != 0) {
            fetchHomeData();
          }
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
            icon: Icon(Icons.smart_toy_outlined),
            label: 'AI Chat',
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
    ));
  }

  Widget buildHomePage() {
    final groups = homeData["groups"] ?? [];
    final friends = homeData["friends"] ?? [];
    final cardColor = Theme.of(context).cardColor;

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
                      formatAmount(homeData["totalBalance"]),
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
                      amount: formatAmount(homeData["youOwe"]),
                      color: Colors.red,
                      cardColor: cardColor,
                      onTap: () => _showBalanceSheet(
                        title: "You Owe",
                        accentColor: Colors.red,
                        entries: (friends as List)
                            .where((f) => f["type"] == "you_owe")
                            .toList(),
                        emptyMessage: "You don't owe anyone right now 🎉",
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: balanceCard(
                      title: "You Get",
                      amount: formatAmount(homeData["youGet"]),
                      color: Colors.green,
                      cardColor: cardColor,
                      onTap: () => _showBalanceSheet(
                        title: "You Get",
                        accentColor: Colors.green,
                        entries: (friends as List)
                            .where((f) => f["type"] == "owes_you")
                            .toList(),
                        emptyMessage: "Nobody owes you anything right now.",
                      ),
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
                    color: cardColor,
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
                  double balance = (group["balance"] ?? 0).toDouble();
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
                        await fetchHomeData();
                      }
                    },
                    child: groupTile(
                      icon: Icons.group,
                      title: group["name"] ?? "",
                      subtitle: "${group["members"] ?? 0} members",
                      amount: formatAmount(balance),
                      color: balance >= 0 ? Colors.green : Colors.red,
                      cardColor: cardColor,
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
                    color: cardColor,
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
                    formatAmount(friend["amount"]),
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

  void _showBalanceSheet({
    required String title,
    required Color accentColor,
    required List entries,
    required String emptyMessage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cardColor = Theme.of(ctx).cardColor;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: entries.isEmpty ? 0.35 : 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (_, scrollController) => Column(
            children: [
              // drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            emptyMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: entries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final entry = entries[i];
                          final isOwedByThem =
                              entry["type"] == "owes_you";
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      const Color(0xffEEEAFE),
                                  child: Text(
                                    (entry["name"] as String? ?? "?")
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xff5B4BFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry["name"] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        isOwedByThem
                                            ? "owes you"
                                            : "you owe",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatAmount(entry["amount"]),
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget balanceCard({
    required String title,
    required String amount,
    required Color color,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
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
      ),
    );
  }

  Widget groupTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
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

  String formatAmount(dynamic value) {
    if (value == null) return '₹ 0';
    final amount = (value as num).toDouble();
    if (amount == amount.truncateToDouble()) {
      return '₹ ${amount.toStringAsFixed(0)}';
    }
    return '₹ ${amount.toStringAsFixed(2)}';
  }
}
