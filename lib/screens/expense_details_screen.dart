import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';
import 'edit_expense_screen.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final int groupId;
  final int expenseId;

  const ExpenseDetailsScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
  });

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  Map<String, dynamic>? expense;
  bool isUpdated = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExpense();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (expense == null) {
      return const Scaffold(
        body: Center(child: Text("Expense not found")),
      );
    }

    final title = expense!["title"] as String? ?? "";
    final cardColor = Theme.of(context).cardColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, isUpdated);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // ── Collapsing app bar ────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              // No title here — the title lives inside FlexibleSpaceBar so it
              // is automatically hidden while expanded and fades in on collapse.
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    if (!mounted) return;
                    final nav = Navigator.of(context);
                    final result = await nav.push(
                      MaterialPageRoute(
                        builder: (_) => EditExpenseScreen(
                          groupId: widget.groupId,
                          expenseId: widget.expenseId,
                          expense: expense!,
                          members: expense?["members"],
                        ),
                      ),
                    );
                    if (result == true) {
                      isUpdated = true;
                      fetchExpense();
                    }
                    nav.pop(isUpdated);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _showDeleteDialog,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                // title fades in only when the bar collapses (built-in behaviour).
                title: Text(
                  title,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 16,
                  bottom: 14,
                ),
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff5B4BFF), Color(0xff6A5CFF)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "₹ ${expense!["amount"]}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            expense!["date"] ?? "",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Scrollable body ───────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    "Paid By",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _infoTile(
                    Icons.person,
                    "${expense!["paid_by"]} paid the full amount",
                    cardColor,
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Split Between",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...(expense!["members"] as List).map((member) {
                    return _memberTile(
                      member["name"],
                      "₹ ${member["share"]}",
                      Colors.deepPurple,
                      cardColor,
                    );
                  }),
                  const SizedBox(height: 25),
                  const Text(
                    "Notes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(expense!["notes"] ?? ""),
                  ),
                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Private widget helpers ──────────────────────────────────────────────────

  Widget _infoTile(IconData icon, String title, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffEEEAFE),
            child: Icon(icon, color: const Color(0xff5B4BFF)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }

  Widget _memberTile(
      String name, String amount, Color color, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffEEEAFE),
            child: Icon(Icons.person, color: Color(0xff5B4BFF)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(
            amount,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Data / dialog logic ─────────────────────────────────────────────────────

  Future<void> fetchExpense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/groups/${widget.groupId}/expenses/${widget.expenseId}",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          expense = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

  Future<void> deleteExpense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse(
          "${ApiConfig.baseUrl}/groups/${widget.groupId}/expenses/${widget.expenseId}",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense deleted successfully")),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text(
          "Are you sure you want to delete this expense?\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      deleteExpense();
    }
  }
}
