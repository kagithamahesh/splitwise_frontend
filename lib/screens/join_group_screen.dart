
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';
import 'home_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  final String inviteCode;

  const JoinGroupScreen({
    super.key,
    required this.inviteCode,
  });

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  bool isLoading = false;
  String? errorMessage;

  Future<void> joinGroup() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage = 'Please log in to join this group.';
        });
        return;
      }

      // IMPORTANT:
      // Replace this endpoint and request format with your
      // actual Go join-group route and authentication scheme.
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/invites/${widget.inviteCode}/join',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined group')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
              (route) => false,
        );
      } else {
        setState(() {
          errorMessage = decoded is Map
              ? (decoded['message']?.toString() ??
              'Unable to join group.')
              : 'Unable to join group.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Unable to join group. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Group')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.group_add_outlined,
                size: 72,
                color: Color(0xff5B4BFF),
              ),
              const SizedBox(height: 20),
              const Text(
                'You have been invited!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Join your group to start sharing expenses.',
                textAlign: TextAlign.center,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : joinGroup,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Join Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
