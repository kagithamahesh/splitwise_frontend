import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String paidBy = "Jack";
  String splitType = "Equal";

  DateTime selectedDate = DateTime.now();

  List<String> members = ["Jack", "Rahul", "Priya", "Amit"];
  List<String> selectedMembers = ["Jack", "Rahul"];

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Add Expense",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Expense Title",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              decoration: inputDecoration("Dinner, Rent, Taxi..."),
            ),

            const SizedBox(height: 20),

            const Text(
              "Amount",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("₹ Enter amount"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Paid By",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: boxStyle(),
              child: DropdownButton(
                value: paidBy,
                isExpanded: true,
                underline: const SizedBox(),
                items: members.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    paidBy = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Split Type",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                splitButton("Equal"),
                const SizedBox(width: 10),
                splitButton("Exact"),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Split With",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: members.map((member) {
                bool selected = selectedMembers.contains(member);

                return FilterChip(
                  selected: selected,
                  label: Text(member),
                  onSelected: (value) {
                    setState(() {
                      if (selected) {
                        selectedMembers.remove(member);
                      } else {
                        selectedMembers.add(member);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              "Date",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: boxStyle(),
                child: Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Notes",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: inputDecoration("Optional notes"),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Expense Saved Successfully"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5B4BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Save Expense",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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

  Widget splitButton(String type) {
    bool active = splitType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            splitType = type;
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xff5B4BFF)
                : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  BoxDecoration boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    );
  }
}