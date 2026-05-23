import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController searchController =
  TextEditingController();

  final List<Map<String, dynamic>> friends = [
    {
      "name": "Rahul Sharma",
      "email": "rahul@gmail.com",
      "amount": 500,
      "type": "owes_you"
    },
    {
      "name": "Priya Reddy",
      "email": "priya@gmail.com",
      "amount": 320,
      "type": "you_owe"
    },
    {
      "name": "Amit Kumar",
      "email": "amit@gmail.com",
      "amount": 0,
      "type": "settled"
    },
    {
      "name": "Sneha Patel",
      "email": "sneha@gmail.com",
      "amount": 1250,
      "type": "owes_you"
    },
  ];

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final filteredFriends = friends.where((friend) {
      return friend["name"]
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Friends",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// Search
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search friends",
                  prefixIcon:
                  const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Summary Cards
              Row(
                children: [
                  Expanded(
                    child: summaryCard(
                      "You Get",
                      "₹1,750",
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: summaryCard(
                      "You Owe",
                      "₹320",
                      Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "All Friends",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend =
                    filteredFriends[index];

                    return friendTile(friend);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget summaryCard(
      String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            title,
            style:
            const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget friendTile(Map<String, dynamic> friend) {
    Color amountColor = Colors.grey;
    String text = "Settled up";

    if (friend["type"] == "owes_you") {
      amountColor = Colors.green;
      text = "owes you";
    } else if (friend["type"] == "you_owe") {
      amountColor = Colors.red;
      text = "you owe";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
            const Color(0xffEEEAFE),
            child: Text(
              friend["name"][0],
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
                  friend["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  friend["email"],
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
                text,
                style: TextStyle(
                  color: amountColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₹${friend["amount"]}",
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}