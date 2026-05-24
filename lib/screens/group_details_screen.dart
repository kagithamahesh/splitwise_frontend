import 'package:flutter/material.dart';
import 'package:sample/screens/expense_details_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, required groupId, required groupName});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5B4BFF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExpenseDetailsScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),

                      const Expanded(
                        child: Text(
                          "Flatmates",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "4 Members",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff5B4BFF),
                          Color(0xff6A5CFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Spent",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "₹ 18,540",
                          style: TextStyle(
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
                          amount: "₹800",
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: summaryCard(
                          title: "You Get",
                          amount: "₹1,450",
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
                children: [
                  expensesTab(),
                  membersTab(),
                  balancesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget expensesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        expenseTile("Rent Payment", "Jack paid", "₹12,000"),
        expenseTile("Dinner", "Rahul paid", "₹1,500"),
        expenseTile("Electricity Bill", "Priya paid", "₹2,300"),
        expenseTile("Groceries", "Amit paid", "₹2,740"),
      ],
    );
  }

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
            child: Icon(Icons.receipt_long,
                color: Color(0xff5B4BFF)),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget membersTab() {
    List<String> names = ["Jack", "Rahul", "Priya", "Amit"];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: names.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xffEEEAFE),
            child: Icon(Icons.person,
                color: Color(0xff5B4BFF)),
          ),
          title: Text(names[index]),
        );
      },
    );
  }

  Widget balancesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        ListTile(
          title: Text("Rahul owes Jack"),
          trailing: Text(
            "₹500",
            style: TextStyle(color: Colors.green),
          ),
        ),
        ListTile(
          title: Text("Jack owes Priya"),
          trailing: Text(
            "₹300",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}