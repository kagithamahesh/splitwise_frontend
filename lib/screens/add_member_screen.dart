import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';

class AddMemberScreen extends StatefulWidget {

  final int groupId;
  final List members;

  const AddMemberScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  @override
  State<AddMemberScreen> createState() =>
      _AddMemberScreenState();
}

class _AddMemberScreenState
    extends State<AddMemberScreen> {

  final TextEditingController
  searchController = TextEditingController();

  final TextEditingController
  emailController = TextEditingController();

  List<dynamic> allUsers = [];
  List<dynamic> filteredUsers = [];
  List<int> groupMemberIds = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    groupMemberIds = widget.members
        .map<int>((e) => e["id"] as int)
        .toList();

    fetchUsers();
    searchController.addListener(filterUsers);
  }

  /// FETCH USERS API
  Future<void> fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        allUsers = jsonDecode(response.body);

        setState(() {
          filteredUsers = allUsers.where((user) {
            return !groupMemberIds.contains(user["id"]);
          }).toList();

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

      print(e);
    }
  }

  void filterUsers() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredUsers = allUsers.where((user) {

        if (groupMemberIds.contains(user["id"])) {
          return false;
        }

        final name = user["name"]
            .toString()
            .toLowerCase();

        final email = user["email"]
            .toString()
            .toLowerCase();

        return name.contains(query) ||
            email.contains(query);

      }).toList();
    });
  }

  /// ADD MEMBER API
  Future<void> addMember(
      int userId,
      ) async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      String? token =
      prefs.getString("token");

      final response = await http.post(

        Uri.parse(
          "${ApiConfig.baseUrl}/groups/${widget.groupId}/members",
        ),

        headers: {

          "Content-Type":
          "application/json",

          "Authorization":
          "Bearer $token",
        },

        body: jsonEncode({
          "user_id": userId,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        setState(() {
          groupMemberIds.add(userId);

          filteredUsers.removeWhere(
                (user) => user["id"] == userId,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Member added successfully"),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add member"),
          ),
        );
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );

      print(e);
    }
  }
  @override
  void dispose() {
    searchController.removeListener(filterUsers);
    searchController.dispose();
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Add Member",

          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(18),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            /// SEARCH
            TextField(

              controller:
              searchController,

              decoration: InputDecoration(

                hintText:
                "Search by name or email",

                prefixIcon:
                const Icon(Icons.search),

                filled: true,

                fillColor:
                Colors.grey.shade100,

                border: OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// TITLE
            const Text(
              "Suggested Users",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// USERS LIST
            filteredUsers.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No users available",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ): ListView.builder(

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              itemCount: filteredUsers.length,

              itemBuilder: (context, index) {

                final user =
                filteredUsers[index];

                return Padding(

                  padding:
                  const EdgeInsets.only(
                    bottom: 18,
                  ),

                  child: Row(

                    children: [

                      /// AVATAR
                      CircleAvatar(

                        radius: 26,

                        backgroundColor:
                        Colors.deepPurple.shade100,

                        child: Text(

                          user['name'][0]
                              .toUpperCase(),

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// USER DETAILS
                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(

                              user['name'],

                              style:
                              const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(

                              user['email'],

                              style:
                              const TextStyle(
                                color:
                                Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ADD BUTTON
                      OutlinedButton.icon(

                        onPressed: () {

                          addMember(
                            user['id'],
                          );
                        },

                        style:
                        OutlinedButton.styleFrom(

                          foregroundColor:
                          Colors.deepPurple,

                          side:
                          const BorderSide(
                            color:
                            Colors.deepPurple,
                          ),

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),

                        icon: const Icon(
                          Icons.add,
                          size: 18,
                        ),

                        label:
                        const Text("Add"),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            /// INVITE TITLE
            const Text(
              "Invite by Email",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            /// EMAIL FIELD
            TextField(

              controller:
              emailController,

              decoration: InputDecoration(

                hintText:
                "Enter email address",

                filled: true,

                fillColor:
                Colors.grey.shade100,

                border: OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// SEND INVITE BUTTON
            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.deepPurple,

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),

                onPressed: () {},

                child: const Text(
                  "Send Invite",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
