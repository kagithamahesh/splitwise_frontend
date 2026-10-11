import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class InvitePeopleScreen extends StatelessWidget {
  final String inviteLink;

  const InvitePeopleScreen({
    super.key,
    required this.inviteLink,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite People')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this link to invite people to your group',
            ),
            const SizedBox(height: 12),

            // Rounded container so the link sits inside the card style
            // used across the rest of the app.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(
                inviteLink,
                style: const TextStyle(fontSize: 13),
              ),
            ),

            const SizedBox(height: 12),

            // ── Copy button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: inviteLink));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite link copied')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5B4BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy Link'),
              ),
            ),

            const SizedBox(height: 12),

            // ── Share button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await SharePlus.instance.share(
                    ShareParams(text: inviteLink),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff5B4BFF),
                  side: const BorderSide(color: Color(0xff5B4BFF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
