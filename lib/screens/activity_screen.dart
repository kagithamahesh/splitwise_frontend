import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int selectedTab = 0; // 0 = All, 1 = You Owe, 2 = You Get
  int bottomIndex = 1;

  final List<Map<String, dynamic>> todayData = [
    {
      "title": "Dinner at BBQ Nation",
      "subtitle": "Paid by Rahul",
      "amount": "₹2,200",
      "date": "Today",
      "icon": Icons.restaurant,
      "color": Colors.orange,
      "type": "all"
    },
    {
      "title": "Cafe Coffee Day",
      "subtitle": "Paid by You",
      "amount": "₹450",
      "date": "16 May",
      "icon": Icons.local_cafe,
      "color": Colors.brown,
      "type": "get"
    },
    {
      "title": "Petrol",
      "subtitle": "Paid by Amit",
      "amount": "₹1,500",
      "date": "15 May",
      "icon": Icons.local_gas_station,
      "color": Colors.blue,
      "type": "owe"
    },
  ];

  final List<Map<String, dynamic>> monthData = [
    {
      "title": "Grocery Shopping",
      "subtitle": "Paid by Priya",
      "amount": "₹2,540",
      "date": "10 May",
      "icon": Icons.shopping_cart,
      "color": Colors.green,
      "type": "get"
    },
    {
      "title": "Movie Tickets",
      "subtitle": "Paid by Neha",
      "amount": "₹800",
      "date": "8 May",
      "icon": Icons.movie,
      "color": Colors.purple,
      "type": "owe"
    },
  ];

  List<Map<String, dynamic>> filterList(List<Map<String, dynamic>> data) {
    if (selectedTab == 0) return data;
    if (selectedTab == 1) {
      return data.where((e) => e["type"] == "owe").toList();
    }
    return data.where((e) => e["type"] == "get").toList();
  }

  @override
  Widget build(BuildContext context) {
    final today = filterList(todayData);
    final month = filterList(monthData);

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5B4BFF),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),


      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Activity",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.filter_list),
                ],
              ),

              const SizedBox(height: 20),

              /// Tabs
              Row(
                children: [
                  buildTab("All", 0),
                  buildTab("You Owe", 1),
                  buildTab("You Get Back", 2),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [
                    if (today.isNotEmpty) ...[
                      const Text(
                        "This Week",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...today.map((e) => activityTile(e)),
                      const SizedBox(height: 20),
                    ],

                    if (month.isNotEmpty) ...[
                      const Text(
                        "This Month",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...month.map((e) => activityTile(e)),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTab(String title, int index) {
    bool selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xff5B4BFF)
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget activityTile(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: item["color"].withOpacity(.12),
            child: Icon(
              item["icon"],
              color: item["color"],
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["subtitle"],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                item["amount"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item["date"],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}