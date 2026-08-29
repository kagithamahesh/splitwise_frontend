import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState
    extends State<CreateGroupScreen> {

  final TextEditingController groupNameController =
  TextEditingController();

  bool isCreating = false;
  bool isGeneratingInvite = false;

  String? inviteUrl;
  int? groupId;

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  // ==========================
  // CREATE GROUP
  // ==========================

  Future<void> createGroup() async {

    final groupName =
    groupNameController.text.trim();

    if (groupName.isEmpty) {
      showSnack("Enter group name");
      return;
    }

    setState(() {
      isCreating = true;
    });

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final token =
      prefs.getString("token");

      final response = await http.post(
        Uri.parse(
          "${ApiConfig.baseUrl}/groups",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": groupName,
        }),
      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 201 ||
          response.statusCode == 200) {

        final createdGroupId =
        data["data"]["groupId"];

        setState(() {
          groupId = createdGroupId;
        });

        // Generate invite automatically
        await createInvite(createdGroupId);

      } else {

        showSnack(
          data["error"] ??
              "Failed to create group",
        );
      }

    } catch (e) {

      showSnack(
        "Something went wrong: $e",
      );

    } finally {

      if (mounted) {
        setState(() {
          isCreating = false;
        });
      }
    }
  }

  // ==========================
  // CREATE INVITE
  // ==========================

  Future<void> createInvite(int groupId) async {

    setState(() {
      isGeneratingInvite = true;
    });

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final token =
      prefs.getString("token");

      final response = await http.post(
        Uri.parse(
          "${ApiConfig.baseUrl}/groups/$groupId/invite",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 201 ||
          response.statusCode == 200) {

        setState(() {
          inviteUrl =
          data["data"]["inviteUrl"];
        });

      } else {

        showSnack(
          data["error"] ??
              "Failed to generate invite",
        );
      }

    } catch (e) {

      showSnack(
        "Failed to generate invite: $e",
      );

    } finally {

      if (mounted) {
        setState(() {
          isGeneratingInvite = false;
        });
      }
    }
  }

  // ==========================
  // SHARE
  // ==========================

  Future<void> shareInvite() async {

    if (inviteUrl == null) {
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        text:
        "Join my Splitwise group!\n\n$inviteUrl",
      ),
    );
  }

  // ==========================
  // COPY
  // ==========================

  Future<void> copyInvite() async {

    if (inviteUrl == null) {
      return;
    }

    await Clipboard.setData(
      ClipboardData(
        text: inviteUrl!,
      ),
    );

    showSnack(
      "Invite link copied",
    );
  }

  // ==========================
  // DONE
  // ==========================

  void finish() {

    Navigator.pop(
      context,
      true,
    );
  }

  // ==========================
  // SNACKBAR
  // ==========================

  void showSnack(String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final bool groupCreated =
        groupId != null && inviteUrl != null;

    return Scaffold(

      backgroundColor:
      const Color(0xffF8F9FF),

      appBar: AppBar(

        backgroundColor:
        Colors.transparent,

        elevation: 0,

        iconTheme:
        const IconThemeData(
          color: Colors.black,
        ),

        title: Text(
          groupCreated
              ? "Invite People"
              : "Create Group",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: groupCreated
            ? buildInviteScreen()
            : buildCreateScreen(),
      ),
    );
  }

  // ==========================
  // CREATE SCREEN
  // ==========================

  Widget buildCreateScreen() {

    return Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        const Text(
          "Create a new group",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Create the group and invite people using a shareable link.",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 30),

        const Text(
          "Group Name",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 10),

        TextField(

          controller:
          groupNameController,

          decoration:
          InputDecoration(

            hintText:
            "Flatmates / Trip / Office",

            filled: true,

            fillColor:
            Colors.white,

            border:
            OutlineInputBorder(

              borderRadius:
              BorderRadius.circular(18),

              borderSide:
              BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 25),

        Container(

          width: double.infinity,

          padding:
          const EdgeInsets.all(20),

          decoration:
          BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(18),
          ),

          child: Row(

            children: [

              Container(

                padding:
                const EdgeInsets.all(10),

                decoration:
                BoxDecoration(

                  color:
                  const Color(0xffEEEAFE),

                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.link,
                  color:
                  Color(0xff5B4BFF),
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Invite people later",
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "After creating the group, "
                          "you can share an invite link "
                          "with anyone.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
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

            onPressed:
            isCreating
                ? null
                : createGroup,

            style:
            ElevatedButton.styleFrom(

              backgroundColor:
              const Color(0xff5B4BFF),

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(18),
              ),
            ),

            child: isCreating

                ? const SizedBox(

              width: 22,

              height: 22,

              child:
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )

                : const Text(
              "Create Group",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================
  // INVITE SCREEN
  // ==========================

  Widget buildInviteScreen() {

    if (isGeneratingInvite) {

      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    return Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Container(

          width: double.infinity,

          padding:
          const EdgeInsets.all(25),

          decoration:
          BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(22),
          ),

          child: Column(

            children: [

              Container(

                padding:
                const EdgeInsets.all(18),

                decoration:
                BoxDecoration(

                  color:
                  const Color(0xffEEEAFE),

                  shape:
                  BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check,
                  size: 40,
                  color:
                  Color(0xff5B4BFF),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Group Created 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                groupNameController.text.trim(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Invite people",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Share this link with your friends. "
              "Anyone who opens it and logs in can join this group.",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 20),

        Container(

          width: double.infinity,

          padding:
          const EdgeInsets.all(15),

          decoration:
          BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(16),

            border:
            Border.all(
              color:
              const Color(0xffE5E5E5),
            ),
          ),

          child: Row(

            children: [

              const Icon(
                Icons.link,
                color:
                Color(0xff5B4BFF),
              ),

              const SizedBox(width: 10),

              Expanded(

                child: Text(
                  inviteUrl ?? "",
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),

              IconButton(

                onPressed:
                copyInvite,

                icon:
                const Icon(
                  Icons.copy,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(

          width: double.infinity,

          height: 55,

          child: ElevatedButton.icon(

            onPressed:
            shareInvite,

            icon:
            const Icon(
              Icons.share,
              color: Colors.white,
            ),

            label:
            const Text(
              "Share Invite Link",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            style:
            ElevatedButton.styleFrom(

              backgroundColor:
              const Color(0xff5B4BFF),

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(18),
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(

          width: double.infinity,

          height: 55,

          child: OutlinedButton(

            onPressed:
            finish,

            style:
            OutlinedButton.styleFrom(

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(18),
              ),
            ),

            child:
            const Text(
              "Done",
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}