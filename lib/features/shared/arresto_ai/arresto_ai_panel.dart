import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';

class ArrestoAIPanel extends StatefulWidget {
  final String? seedQuestion;
  const ArrestoAIPanel({super.key, this.seedQuestion});

  @override
  State<ArrestoAIPanel> createState() => _ArrestoAIPanelState();
}

class _ArrestoAIPanelState extends State<ArrestoAIPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _typing = false;

  static const _suggestions = [
    'What is the minimum anchor strength for fall arrest?',
    'How do I inspect a full-body harness?',
    'Explain the 6-foot free-fall rule.',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.seedQuestion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _send(widget.seedQuestion!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _typing = true;
    });
    _scrollToBottom();

    // Simulate AI response
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(_Message(
        text: _mockResponse(text),
        isUser: false,
      ));
    });
    _scrollToBottom();
  }

  String _mockResponse(String q) {
    if (q.toLowerCase().contains('anchor')) {
      return 'Anchor points for personal fall arrest systems must support a minimum of **5,000 lbs (22 kN)** per attached worker, or be designed and tested by a qualified person under a supervised fall arrest system.';
    }
    if (q.toLowerCase().contains('inspect') || q.toLowerCase().contains('harness')) {
      return 'Before each use, inspect your harness for: ① Cut, frayed, or worn webbing ② Damaged stitching ③ Corroded or bent hardware ④ Damaged D-rings ⑤ Deformed buckles. Remove from service if any defects are found.';
    }
    if (q.toLowerCase().contains('free-fall') || q.toLowerCase().contains('6-foot')) {
      return 'The **6-foot (1.8 m) free-fall rule** means your fall arrest system must stop a fall within 6 feet of where you started falling. This limits forces on your body and ensures adequate clearance above the lower level.';
    }
    return 'That\'s a great question about fall protection! Based on the course material, the key principles are: always use certified equipment, inspect before each use, and ensure your system has adequate clearance below your working position. Would you like more detail on any specific aspect?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: ArrestoColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: ArrestoColors.lineStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: ArrestoColors.ink,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ArrestoColors.amber, ArrestoColors.orange],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Arresto AI',
                        style:
                            ArrestoText.h4(color: Colors.white)),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: ArrestoColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('Online — Fall Protection Expert',
                            style: ArrestoText.xs(color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white54, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(onChip: _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _messages.length) return const _TypingIndicator();
                      return _MessageBubble(msg: _messages[i]);
                    },
                  ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ArrestoColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask Arresto AI anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (v) {
                      _send(v);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _send(_controller.text);
                    _controller.clear();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ArrestoColors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        size: 18, color: ArrestoColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onChip;
  const _EmptyState({required this.onChip});

  static const _suggestions = [
    'What is the minimum anchor strength?',
    'How do I inspect a full-body harness?',
    'Explain the 6-foot free-fall rule.',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [ArrestoColors.amber, ArrestoColors.orange]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text('Ask me anything about fall protection',
                style: ArrestoText.bodyMd(color: ArrestoColors.ink),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestions.map((s) {
                return GestureDetector(
                  onTap: () => onChip(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ArrestoColors.bg2,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: ArrestoColors.line),
                    ),
                    child: Text(s,
                        style: ArrestoText.small()
                            .copyWith(fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? ArrestoColors.amber : ArrestoColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: msg.isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: msg.isUser
              ? null
              : Border.all(color: ArrestoColors.cardBorder),
          boxShadow: msg.isUser ? null : ArrestoColors.sh1,
        ),
        child: Text(
          msg.text,
          style: ArrestoText.body(
            color: msg.isUser ? ArrestoColors.ink : ArrestoColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true);
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) c.forward();
      });
      _controllers.add(c);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ArrestoColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ArrestoColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _controllers[i],
              builder: (_, __) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: ArrestoColors.textMuted
                      .withOpacity(0.3 + 0.7 * _controllers[i].value),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  const _Message({required this.text, required this.isUser});
}
