import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  final List<String> _suggestions = [
    'Show my groups',
    'Add dinner ₹2300 in Travelling paid by mahesh',
    'Get group details for Travelling',
    'Set budget ₹50000 for Travelling',
    "This month's report for Travelling",
    'Check budget alerts',
    'Show analytics',
    'Settle up between mahesh and manideep in Travelling',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'text':
      'Hi! I\'m FinSplit AI 👋\nAsk me to create expenses, check balances, set budgets, and more.',
      'data': null,
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    _controller.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': text, 'data': null});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/agent/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final agentText = data['message'] ??
            (data['success'] == true ? 'Done!' : 'Something went wrong.');

        setState(() {
          _messages.add({'role': 'bot', 'text': agentText, 'data': data});
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'bot',
            'text': 'Server error (${response.statusCode}). Try again.',
            'data': null,
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': 'Cannot reach server. Make sure the backend is running.',
          'data': null,
        });
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ── AppBar ─────────────────────────────────────────────────────────
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xffEEEAFE),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Color(0xff5B4BFF),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FinSplit AI',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xff1D9E75),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Groq LLaMA 3.3 70B',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ── Messages list ─────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return isUser
                    ? _buildUserBubble(msg['text'])
                    : _buildBotBubble(msg['text'], msg['data']);
              },
            ),
          ),

          // ── Suggestion chips ──────────────────────────────────────────
          if (!_isLoading)
            Container(
              height: 44,
              color: cardColor,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _sendMessage(_suggestions[index]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                      color: isDark ? const Color(0xff2A2A2A) : const Color(0xffF8F9FF),
                    ),
                    child: Text(
                      _suggestions[index],
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ),
              ),
            ),

          // ── Input bar ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
            color: cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Ask about expenses...',
                      filled: true,
                      fillColor: isDark ? const Color(0xff2A2A2A) : const Color(0xffF8F9FF),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xff5B4BFF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── User bubble ──────────────────────────────────────────────────────────
  Widget _buildUserBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xff5B4BFF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xffEEEAFE),
            child: Icon(Icons.person,
                size: 18, color: Color(0xff5B4BFF)),
          ),
        ],
      ),
    );
  }

  // ── Bot bubble ───────────────────────────────────────────────────────────
  Widget _buildBotBubble(
      String text, Map<String, dynamic>? data) {
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xffEEEAFE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                size: 18, color: Color(0xff5B4BFF)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (data != null && data['success'] == true)
                  _buildResponseCard(data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Response card ────────────────────────────────────────────────────────
  Widget _buildResponseCard(Map<String, dynamic> data) {
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Done badge ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffEAF3DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle,
                    size: 13,
                    color: Color(0xff3B6D11)),
                SizedBox(width: 4),
                Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff3B6D11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Expense created ─────────────────────────
          if (data['expense'] != null) ...[
            _infoRow('Description', data['expense']),
            _infoRow('Amount', '₹${data['amount']}'),
            _infoRow('Group', data['group']),
          ],

          // ── Groups list ─────────────────────────────
          if (data['groups'] != null &&
              data['groups'] is List) ...[
            _sectionTitle('Groups'),
            ...List<Map>.from(data['groups']).map(
                  (g) => _infoRow(
                  g['name'] ?? '', 'ID: ${g['id'] ?? ''}'),
            ),
          ],

          // ── Monthly summary ─────────────────────────
          if (data['summary'] != null) ...[
            _sectionTitle(
                'Monthly — ${data['month'] ?? ''}'),
            if (data['summary']['perPerson'] != null)
              ...List<Map>.from(
                  data['summary']['perPerson'])
                  .map((p) => _infoRow(
                  p['name'], '₹${p['total']}')),
            _infoRow(
              'Total',
              '₹${data['summary']['grandTotal'] ?? 0}',
              bold: true,
            ),
          ],

          // ── Budget alerts ───────────────────────────
          if (data['alerts'] != null &&
              data['alerts'] is List) ...[
            _sectionTitle('Budget Alerts'),
            ...List<Map>.from(data['alerts'])
                .map((a) => _alertRow(a)),
          ],

          // ── Analytics ───────────────────────────────
          if (data['topGroups'] != null) ...[
            _sectionTitle('Top Groups'),
            ...List<Map>.from(data['topGroups']).map(
                  (g) => _infoRow(
                  g['group'], '₹${g['total']}'),
            ),
          ],
          if (data['totalSpend'] != null)
            _infoRow('Total spend',
                '₹${data['totalSpend']}',
                bold: true),

          // ── Group details ───────────────────────────
          if (data['group'] != null &&
              data['group'] is Map) ...[
            _sectionTitle('Group Details'),
            _infoRow(
                'Name', data['group']['name'] ?? ''),
            _infoRow(
              'Total expense',
              '₹${data['group']['totalExpense'] ?? 0}',
            ),
            if (data['group']['members'] != null)
              _infoRow(
                'Members',
                List<Map>.from(
                    data['group']['members'])
                    .map((m) => m['name'])
                    .join(', '),
              ),
          ],

          // ── Budget set ──────────────────────────────
          if (data['budget'] != null)
            _infoRow(
                'Budget set', '₹${data['budget']}',
                bold: true),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 6),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xff5B4BFF),
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _infoRow(String label, String value,
      {bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _alertRow(Map alert) {
    final status = alert['status'] ?? 'ok';
    final isExceeded = status == 'exceeded';
    final color = isExceeded
        ? const Color(0xffA32D2D)
        : const Color(0xffBA7517);
    final bgColor = isExceeded
        ? const Color(0xffFCEBEB)
        : const Color(0xffFAEEDA);
    final percent =
    (alert['percent'] as num).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                alert['group'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$percent% used',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ((alert['percent'] as num) / 100)
                  .clamp(0.0, 1.0),
              backgroundColor: Colors.white,
              valueColor:
              AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget: ₹${alert['budget']}',
                  style: TextStyle(
                      fontSize: 11, color: color)),
              Text('Spent: ₹${alert['spent']}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xffEEEAFE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                size: 18, color: Color(0xff5B4BFF)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(150),
                const SizedBox(width: 4),
                _dot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: child,
      ),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}