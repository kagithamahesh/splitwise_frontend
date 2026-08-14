import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sample/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddExpenseScreen extends StatefulWidget {
  final int groupId;
  final List members;

  const AddExpenseScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String splitType = "equal";

  int? paidBy;

  DateTime selectedDate = DateTime.now();

  List<int> selectedMembers = [];

  bool isLoading = false;

  // Validation error messages
  String? titleError;
  String? amountError;
  String? paidByError;

  @override
  void initState() {
    super.initState();
    selectedMembers =
        widget.members.map<int>((e) => e["id"] as int).toList();
  }

  // =========================
  // VALIDATE FIELDS
  // =========================
  bool _validate() {
    bool valid = true;

    setState(() {
      titleError = titleController.text.trim().isEmpty
          ? "Expense title is required"
          : null;

      if (amountController.text.trim().isEmpty) {
        amountError = "Amount is required";
        valid = false;
      } else if (double.tryParse(amountController.text.trim()) == null ||
          double.parse(amountController.text.trim()) <= 0) {
        amountError = "Enter a valid amount greater than 0";
        valid = false;
      } else {
        amountError = null;
      }

      paidByError = paidBy == null ? "Please select who paid" : null;

      if (titleError != null || amountError != null || paidByError != null) {
        valid = false;
      }
    });

    return valid;
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
  // SAVE EXPENSE API
  // =========================
  Future<void> saveExpense() async {
    if (!_validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/expenses"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "group_id": widget.groupId,
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Expense Added Successfully"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["error"] ?? "Failed"),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());

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

  // =========================
  // LABEL WITH OPTIONAL RED *
  // =========================
  Widget _fieldLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black,
        ),
        children: required
            ? const [
                TextSpan(
                  text: " *",
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }

  // =========================
  // INLINE ERROR TEXT
  // =========================
  Widget _errorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        error,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
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
            // =========================
            // TITLE
            // =========================
            _fieldLabel("Expense Title", required: true),

            const SizedBox(height: 10),

            TextField(
              controller: titleController,
              onChanged: (_) {
                if (titleError != null) {
                  setState(() => titleError = null);
                }
              },
              decoration: InputDecoration(
                hintText: "Dinner, Rent, Taxi...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: titleError != null
                      ? const BorderSide(color: Colors.red)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: titleError != null
                        ? Colors.red
                        : const Color(0xff5B4BFF),
                  ),
                ),
              ),
            ),

            _errorText(titleError),

            const SizedBox(height: 20),

            // =========================
            // AMOUNT
            // =========================
            _fieldLabel("Amount", required: true),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (_) {
                if (amountError != null) {
                  setState(() => amountError = null);
                }
              },
              decoration: InputDecoration(
                hintText: "0.00",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: amountError != null
                      ? const BorderSide(color: Colors.red)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: amountError != null
                        ? Colors.red
                        : const Color(0xff5B4BFF),
                  ),
                ),
              ),
            ),

            _errorText(amountError),

            const SizedBox(height: 20),

            // =========================
            // PAID BY
            // =========================
            _fieldLabel("Paid By", required: true),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: paidByError != null
                    ? Border.all(color: Colors.red)
                    : null,
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
                      paidByError = null;
                    });
                  },
                ),
              ),
            ),

            _errorText(paidByError),

            const SizedBox(height: 20),

            // =========================
            // SPLIT TYPE
            // =========================
            _fieldLabel("Split Type"),

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
            _fieldLabel("Split With"),

            const SizedBox(height: 15),

            ...widget.members.map((member) {
              bool selected = selectedMembers.contains(member["id"]);

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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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
            }).toList(),

            const SizedBox(height: 20),

            // =========================
            // DATE
            // =========================
            _fieldLabel("Date"),

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
                        DateFormat("dd/MM/yyyy").format(selectedDate),
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
            _fieldLabel("Notes"),

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
            // SAVE BUTTON
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
                        "Save Expense",
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
