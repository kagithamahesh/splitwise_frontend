import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'invite_people_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();

  bool isCreating = false;

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  // ==========================
  // CREATE GROUP
  // ==========================

  Future<void> createGroup() async {
    final groupName = groupNameController.text.trim();

    if (groupName.isEmpty) {
      showSnack("Enter group name");
      return;
    }

    setState(() => isCreating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      // Step 1 — create the group, get back the groupId.
      final createResponse = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/groups"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"name": groupName}),
      );

      final createData = jsonDecode(createResponse.body);

      if (createResponse.statusCode != 201 && createResponse.statusCode != 200) {
        if (!mounted) return;
        showSnack(createData["error"] ?? "Failed to create group");
        return;
      }

      final groupId = createData["data"]["groupId"] as int;

      // Step 2 — fetch the invite link for the newly created group.
      final inviteResponse = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/groups/$groupId/invite"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (!mounted) return;

      if (inviteResponse.statusCode == 200 || inviteResponse.statusCode == 201) {
        final inviteData = jsonDecode(inviteResponse.body);
        final inviteUrl = inviteData["data"]["inviteUrl"] as String;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvitePeopleScreen(inviteLink: inviteUrl),
          ),
        );
      } else {
        showSnack("Group created but failed to generate invite link.");
      }
    } catch (e) {
      if (!mounted) return;
      showSnack("Something went wrong: $e");
    } finally {
      if (mounted) setState(() => isCreating = false);
    }
  }

  // ==========================
  // SNACKBAR
  // ==========================

  void showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a new group",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Create the group and invite people using a shareable link.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

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

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffEEEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.link, color: Color(0xff5B4BFF)),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Invite people later",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "After creating the group, you can share an invite link with anyone.",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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
          ],
        ),
      ),
    );
  }
}
