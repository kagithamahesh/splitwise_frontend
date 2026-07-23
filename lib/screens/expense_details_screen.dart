import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/screens/settle_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';
import 'edit_expense_screen.dart';

class ExpenseDetailsScreen extends StatefulWidget  {
  final int groupId;
  final int expenseId;

  const ExpenseDetailsScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
  });

  Widget infoTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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

  Widget memberTile(String name, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffEEEAFE),
            child: Icon(Icons.person,
                color: Color(0xff5B4BFF)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  @override
  State<ExpenseDetailsScreen> createState() =>
      _ExpenseDetailsScreenState ();
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
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (expense == null) {
      return const Scaffold(
        body: Center(
          child: Text("Expense not found"),
        ),
      );
    }

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          Navigator.pop(context, isUpdated);
        },
        child: Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      appBar: AppBar(
        title: const Text("Expense Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditExpenseScreen(
                    groupId: widget.groupId,
                    expenseId: widget.expenseId,
                    expense: expense!,
                    members:expense?["members"]
                  ),
                ),
              );

              if (result == true) {
                isUpdated = true;
                fetchExpense();
              }
              Navigator.pop(context, isUpdated);
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff5B4BFF),
                    Color(0xff6A5CFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    expense!["title"] ?? "",
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
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Paid By",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            infoTile(
              Icons.person,
              "${expense!["paid_by"]} paid the full amount",
            ),

            const SizedBox(height: 25),

            const Text(
              "Split Between",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...(expense!["members"] as List).map((member) {
              return memberTile(
                member["name"],
                "₹ ${member["share"]}",
                Colors.deepPurple,
              );
            }),

            const SizedBox(height: 25),

            const Text(
              "Notes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                expense!["notes"] ?? "",
              ),
            ),
          ],
        ),
      ),
    ),);
  }
  Future<void> fetchExpense() async {

    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString("token");

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

        setState(() {
          isLoading = false;
        });
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  Widget infoTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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

  Widget memberTile(String name, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffEEEAFE),
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


}
