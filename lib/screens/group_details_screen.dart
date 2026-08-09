import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/config/api.dart';
import 'package:sample/screens/add_expense_screen.dart';
import 'package:sample/screens/add_member_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense_details_screen.dart';

class GroupDetailsScreen extends StatefulWidget {

  final int groupId;

  const GroupDetailsScreen({
    super.key,
    required this.groupId, required groupName,
  });

  @override
  State<GroupDetailsScreen> createState() =>
      _GroupDetailsScreenState();
}

class _GroupDetailsScreenState
    extends State<GroupDetailsScreen> {
  bool isUpdated = false;
  Map<String, dynamic>? groupData;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
  }

  Future<void> fetchGroupDetails() async {

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      print(widget);
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/groups/${widget.groupId}",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        setState(() {

          groupData =
              jsonDecode(response.body);

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });

        print("API Error");
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      print(e);
    }
  }
  String fmt(dynamic v) {
    if (v == null) return '₹ 0';
    final n = (v as num).toDouble();
    return n == n.truncateToDouble()
        ? '₹ ${n.toStringAsFixed(0)}'
        : '₹ ${n.toStringAsFixed(2)}';
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

    return Scaffold(

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [

            Expanded(
              child: OutlinedButton.icon(

                style: OutlinedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  side: const BorderSide(
                    color: Colors.deepPurple,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),

                // onPressed: () {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (_) => AddExpenseScreen(groupId: widget.groupId, members: groupData?['members'],))
                //   );
                // },
                onPressed: () async {

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddExpenseScreen(
                        groupId: widget.groupId,
                        members: groupData?['members'],
                      ),
                    ),
                  );

                  if (result == true) {
                    isUpdated = true;
                    fetchGroupDetails();
                  }
                },
                icon:
                const Icon(Icons.receipt_long),

                label:
                const Text("Add Expense"),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.deepPurple,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddMemberScreen(groupId: widget.groupId, members: groupData!["members"]))
                  );
                },

                icon:
                const Icon(Icons.group_add),

                label:
                const Text("Add Member"),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        leading:  IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context, isUpdated);
          },
        ),

        title: Text(
          groupData?['name'] ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 10),

            /// HEADER
            Row(
              children: [

                CircleAvatar(
                  radius: 40,

                  backgroundColor:
                  Colors.blue.shade100,

                  child: const Icon(
                    Icons.group,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(width: 16),

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      groupData?['name'] ?? "",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${groupData?['members']?.length ?? 0} Members",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 24),

            /// SUMMARY CARDS
            Row(
              children: [

                Expanded(
                  child: SummaryCard(
                    title: "Total\nExpense",

                    amount:
                    fmt(groupData?['totalExpense']),

                    amountColor:
                    Colors.deepPurple,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SummaryCard(
                    title: "You\nOwe",

                    amount:
                    fmt(groupData?['youOwe']),

                    amountColor:
                    Colors.red,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SummaryCard(
                    title: "You\nGet",

                    amount:
                    fmt(groupData?['youGet']),

                    amountColor:
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// MEMBERS HEADER
            Text(
              "Members (${groupData?['members']?.length ?? 0})",

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            /// MEMBERS LIST
            ListView.builder(

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              itemCount:
              groupData?['members']?.length ?? 0,

              itemBuilder: (context, index) {

                final member =
                groupData!['members'][index];

                return MemberTile(
                  name: member['name'],
                  email: member['email'],
                );
              },
            ),

            const SizedBox(height: 30),

            /// EXPENSES HEADER
            const Text(
              "Recent Expenses",

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            /// EXPENSES LIST
            ListView.builder(

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              itemCount:
              groupData?['expenses']?.length ?? 0,

              itemBuilder: (context, index) {

                final expense =
                groupData!['expenses'][index];

                return  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpenseDetailsScreen(
                            expenseId: expense["id"],  groupId: widget.groupId,
                          ),
                        ),
                      );

                      if (result == true) {
                        print("hello");
                        fetchGroupDetails();
                      }
                    },
                    child: ExpenseTile(
                  title:
                  expense['title'] ?? "",

                  paidBy:
                  expense['paid_by'] ?? "",

                  amount:
                  "₹ ${expense['amount'] ?? 0}",

                  date:
                  expense['date'] ?? "",
                    ),
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {

  final String title;
  final String amount;
  final Color amountColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding:
      const EdgeInsets.symmetric(
        vertical: 18,
      ),

      decoration: BoxDecoration(

        color: Colors.grey.shade100,

        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            amount,

            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }
}

class MemberTile extends StatelessWidget {

  final String name;
  final String email;

  const MemberTile({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(

      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        backgroundColor:
        Colors.orange.shade100,

        child: const Icon(
          Icons.person,
          color: Colors.black,
        ),
      ),

      title: Text(
        name,

        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(email),
    );
  }
}

class ExpenseTile extends StatelessWidget {

  final String title;
  final String paidBy;
  final String amount;
  final String date;

  const ExpenseTile({
    super.key,
    required this.title,
    required this.paidBy,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(

      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        backgroundColor:
        Colors.green.shade100,

        child: const Icon(
          Icons.receipt,
          color: Colors.black,
        ),
      ),

      title: Text(
        title,

        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(paidBy),

      trailing: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        crossAxisAlignment:
        CrossAxisAlignment.end,

        children: [

          Text(
            amount,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            date,

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          )
        ],
      ),
    ));
  }
}