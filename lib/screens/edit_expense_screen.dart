import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sample/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditExpenseScreen extends StatefulWidget {
  final int groupId;
  final int expenseId;
  final Map<String, dynamic> expense;
  final List members;

  const EditExpenseScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
    required this.expense,
    required this.members,
  });

  @override
  State<EditExpenseScreen> createState() =>
      _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String splitType = "equal";

  int? paidBy;

  DateTime selectedDate = DateTime.now();

  List<int> selectedMembers = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
      titleController.text = widget.expense["description"] ?? "";

      amountController.text =
          widget.expense["amount"].toString();

      notesController.text =
          widget.expense["notes"] ?? "";

      splitType =
          widget.expense["split_type"] ?? "equal";

      paidBy = widget.expense["PaidById"];

      // selectedDate =
      //     DateTime.parse(widget.expense["created_at"]);

      selectedMembers = (widget.expense["members"] as List)
          .map<int>((e) => e["id"])
          .toList();

  }

  // =========================
  // SELECT DATE
  // =========================
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

  // =========================
  // UPDATE EXPENSE API
  // =========================
  Future<void> saveExpense() async {
    if (titleController.text.isEmpty ||
        amountController.text.isEmpty ||
        paidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString("token");

      final response = await http.put(
        Uri.parse(
            "${ApiConfig.baseUrl}/groups/${widget.groupId}/expenses/${widget.expenseId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "description": titleController.text,
          "amount": double.parse(amountController.text),
          "paid_by": paidBy,
          "split_type": splitType,
          "members": selectedMembers,
          "notes": notesController.text,
          "date": selectedDate.toIso8601String(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Expense Updated Successfully"),
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["error"] ?? "Failed"),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Edit Expense",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // TITLE
            // =========================
            const Text(
              "Expense Title",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Dinner, Rent, Taxi...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // AMOUNT
            // =========================
            const Text(
              "Amount",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "₹ 0",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // PAID BY
            // =========================
            const Text(
              "Paid By",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: paidBy,
                  isExpanded: true,
                  hint: const Text("Select Member"),

                  items: widget.members.map((member) {

                    return DropdownMenuItem<int>(
                      value: member["id"],
                      child: Text(member["name"]),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      paidBy = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // SPLIT TYPE
            // =========================
            const Text(
              "Split Type",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        splitType = "equal";
                      });
                    },

                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: splitType == "equal"
                            ? const Color(0xff5B4BFF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Center(
                        child: Text(
                          "Equal",
                          style: TextStyle(
                            color: splitType == "equal"
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        splitType = "exact";
                      });
                    },

                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: splitType == "exact"
                            ? const Color(0xff5B4BFF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Center(
                        child: Text(
                          "Exact",
                          style: TextStyle(
                            color: splitType == "exact"
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // =========================
            // MEMBERS
            // =========================
            const Text(
              "Split With",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 15),

            ...widget.members.map((member) {
              final bool selected = selectedMembers.contains(member["id"]);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xffEEEAFE),
                      child: Text(
                        member["name"][0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xff5B4BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        member["name"],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Checkbox(
                      value: selected,
                      activeColor: const Color(0xff5B4BFF),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedMembers.add(member["id"]);
                          } else {
                            selectedMembers.remove(member["id"]);
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // =========================
            // DATE
            // =========================
            const Text(
              "Date",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: pickDate,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat("dd/MM/yyyy")
                            .format(selectedDate),
                      ),
                    ),

                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // NOTES
            // =========================
            const Text(
              "Notes",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,
              maxLines: 3,

              decoration: InputDecoration(
                hintText: "Add notes here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // UPDATE BUTTON
            // =========================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: isLoading ? null : saveExpense,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5B4BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Update Expense",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
}