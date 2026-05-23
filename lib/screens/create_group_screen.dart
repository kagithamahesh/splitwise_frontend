import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();

  bool isLoading = false;
  bool isCreating = false;

  List users = [];
  List<int> selectedMembers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ===========================
  // FETCH USERS
  // ===========================
  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/users"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print(data);
        setState(() {
          users = data ?? [];
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => isLoading = false);
  }

  // ===========================
  // CREATE GROUP
  // ===========================
  Future<void> createGroup() async {
    if (groupNameController.text.trim().isEmpty) {
      showSnack("Enter group name");
      return;
    }

    if (selectedMembers.isEmpty) {
      showSnack("Select at least one member");
      return;
    }

    setState(() => isCreating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/groups"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": groupNameController.text.trim(),
          "members": selectedMembers,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSnack("Group Created Successfully");

        Navigator.pop(context, true);
      } else {
        showSnack(data["error"] ?? "Failed");
      }
    } catch (e) {
      showSnack(e.toString());
    }

    setState(() => isCreating = false);
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ===========================
  // UI
  // ===========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      appBar: AppBar(
        title: const Text(
          "Create Group",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // GROUP NAME
            const Text(
              "Group Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                hintText: "Flatmates / Trip / Office",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Select Members",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...users.map((user) {
              int id = user["id"];
              bool selected = selectedMembers.contains(id);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CheckboxListTile(
                  value: selected,
                  title: Text(user["name"]),
                  subtitle: Text(user["email"]),
                  activeColor: const Color(0xff5B4BFF),
                  onChanged: (value) {
                    setState(() {
                      if (selected) {
                        selectedMembers.remove(id);
                      } else {
                        selectedMembers.add(id);
                      }
                    });
                  },
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isCreating ? null : createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5B4BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isCreating
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Create Group",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}