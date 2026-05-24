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

  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  bool isCreating = false;

  List users = [];
  List filteredUsers = [];

  List<int> selectedMembers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    groupNameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // ==========================
  // FETCH USERS
  // ==========================
  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

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
        if (!mounted) return;

        setState(() {
          users = data ?? [];

          filteredUsers = users;
        });
      } else {
        showSnack("Failed to fetch users");
      }
    } catch (e) {
      showSnack(e.toString());
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // ==========================
  // SEARCH USERS
  // ==========================
  void filterUsers(String value) {
    setState(() {
      filteredUsers = users.where((user) {
        final name = user["name"].toString().toLowerCase();

        final email = user["email"].toString().toLowerCase();

        return name.contains(value.toLowerCase()) ||
            email.contains(value.toLowerCase());
      }).toList();
    });
  }

  // ==========================
  // CREATE GROUP
  // ==========================
  Future<void> createGroup() async {
    if (groupNameController.text.trim().isEmpty) {
      showSnack("Enter group name");

      return;
    }

    if (selectedMembers.isEmpty) {
      showSnack("Select at least one member");

      return;
    }

    setState(() {
      isCreating = true;
    });

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSnack("Group Created Successfully");

        Navigator.pop(context, true);
      } else {
        showSnack(data["error"] ?? "Failed to create group");
      }
    } catch (e) {
      showSnack(e.toString());
    }

    if (!mounted) return;

    setState(() {
      isCreating = false;
    });
  }

  // ==========================
  // SNACKBAR
  // ==========================
  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.black),

        title: const Text(
          "Create Group",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =====================
                  // GROUP NAME
                  // =====================
                  const Text(
                    "Group Name",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

                  // =====================
                  // SEARCH
                  // =====================
                  TextField(
                    controller: searchController,

                    onChanged: filterUsers,

                    decoration: InputDecoration(
                      hintText: "Search users",

                      prefixIcon: const Icon(Icons.search),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Select Members",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        "${selectedMembers.length} Selected",
                        style: const TextStyle(
                          color: Color(0xff5B4BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // =====================
                  // EMPTY USERS
                  // =====================
                  if (filteredUsers.isEmpty)
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(25),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: const Column(
                        children: [
                          Icon(Icons.group_off, size: 60, color: Colors.grey),

                          SizedBox(height: 10),

                          Text(
                            "No Users Found",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                  // =====================
                  // USER LIST
                  // =====================
                  ...filteredUsers.map((user) {
                    int id = user["id"];

                    bool selected = selectedMembers.contains(id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: CheckboxListTile(
                        value: selected,

                        activeColor: const Color(0xff5B4BFF),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),

                        secondary: CircleAvatar(
                          backgroundColor: const Color(0xffEEEAFE),

                          child: Text(
                            user["name"][0].toUpperCase(),

                            style: const TextStyle(
                              color: Color(0xff5B4BFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        title: Text(
                          user["name"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(user["email"]),

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

                  // =====================
                  // BUTTON
                  // =====================
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
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Create Group",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
