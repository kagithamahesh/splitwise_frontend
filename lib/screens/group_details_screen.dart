import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense_details_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool isLoading = true;

  Map<String, dynamic> groupData = {};

  List expenses = [];
  List members = [];
  List balances = [];

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);

    fetchGroupDetails();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // ==========================
  // FETCH GROUP DETAILS
  // ==========================
  Future<void> fetchGroupDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/groups/${widget.groupId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          groupData = data;

          expenses = data["expenses"] ?? [];

          members = data["members"] ?? [];

          balances = data["balances"] ?? [];
        });
      } else {
        debugPrint(data.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5B4BFF),

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExpenseDetailsScreen(groupId: widget.groupId),
            ),
          );

          if (result == true) {
            fetchGroupDetails();
          }
        },

        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              icon: const Icon(Icons.arrow_back),
                            ),

                            Expanded(
                              child: Text(
                                widget.groupName,

                                textAlign: TextAlign.center,

                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 48),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "${members.length} Members",

                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 20),

                        // =====================
                        // TOTAL SPENT CARD
                        // =====================
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
                                "Total Spent",

                                style: TextStyle(color: Colors.white70),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "₹ ${groupData["totalExpense"] ?? 0}",

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
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
                              child: summaryCard(
                                title: "You Owe",

                                amount: "₹ ${groupData["youOwe"] ?? 0}",

                                color: Colors.red,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: summaryCard(
                                title: "You Get",

                                amount: "₹ ${groupData["youGet"] ?? 0}",

                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // =========================
                  // TAB BAR
                  // =========================
                  TabBar(
                    controller: tabController,

                    labelColor: const Color(0xff5B4BFF),

                    unselectedLabelColor: Colors.grey,

                    indicatorColor: const Color(0xff5B4BFF),

                    tabs: const [
                      Tab(text: "Expenses"),
                      Tab(text: "Members"),
                      Tab(text: "Balances"),
                    ],
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: tabController,

                      children: [expensesTab(), membersTab(), balancesTab()],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ==========================
  // SUMMARY CARD
  // ==========================
  static Widget summaryCard({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Text(title),

          const SizedBox(height: 8),

          Text(
            amount,

            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // EXPENSE TAB
  // ==========================
  Widget expensesTab() {
    if (expenses.isEmpty) {
      return const Center(child: Text("No expenses yet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),

      itemCount: expenses.length,

      itemBuilder: (context, index) {
        final expense = expenses[index];

        return expenseTile(
          expense["title"] ?? "",
          "${expense["paidBy"] ?? "Unknown"} paid",
          "₹ ${expense["amount"] ?? 0}",
        );
      },
    );
  }

  // ==========================
  // EXPENSE TILE
  // ==========================
  Widget expenseTile(String title, String subtitle, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffEEEAFE),

            child: Icon(Icons.receipt_long, color: Color(0xff5B4BFF)),
          ),

          const SizedBox(width: 14),

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

          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================
  // MEMBERS TAB
  // ==========================
  Widget membersTab() {
    if (members.isEmpty) {
      return const Center(child: Text("No members"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),

      itemCount: members.length,

      itemBuilder: (context, index) {
        final member = members[index];

        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xffEEEAFE),

            child: Icon(Icons.person, color: Color(0xff5B4BFF)),
          ),

          title: Text(member["name"] ?? ""),

          subtitle: Text(member["email"] ?? ""),
        );
      },
    );
  }

  // ==========================
  // BALANCES TAB
  // ==========================
  Widget balancesTab() {
    if (balances.isEmpty) {
      return const Center(child: Text("No balances"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),

      itemCount: balances.length,

      itemBuilder: (context, index) {
        final balance = balances[index];

        double amount = double.tryParse(balance["amount"].toString()) ?? 0;

        return ListTile(
          title: Text("${balance["from"]} owes ${balance["to"]}"),

          trailing: Text(
            "₹ $amount",

            style: TextStyle(
              color: amount > 0 ? Colors.green : Colors.red,

              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
