import 'package:flutter/material.dart';
import 'package:mobo_app/features/mobo_ai/data/mobo_ai_repository.dart';
import 'package:mobo_app/features/mobo_ai/domain/ai_message.dart';

class AiChatScreen extends StatefulWidget {
  final String conversationId;
  const AiChatScreen({super.key, required this.conversationId});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _repo = MoboAiRepository();
  final _messages = <AiMessage>[];
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() { _messages.add(AiMessage(id: 'local-${DateTime.now().microsecondsSinceEpoch}', role: AiMessageRole.user, content: text, proposedAction: null, confirmationState: ActionConfirmationState.none)); _sending = true; _controller.clear(); });
    final resp = await _repo.sendMessage(widget.conversationId, text);
    setState(() { _messages.add(resp); _sending = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MOBO AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: m.role == AiMessageRole.user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: m.role == AiMessageRole.user ? Colors.grey[200] : Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: Text(m.content),
                      ),
                      if (m.proposedAction != null) _buildProposedActionCard(m),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Ask MOBO...'))),
              IconButton(icon: _sending ? const CircularProgressIndicator() : const Icon(Icons.send), onPressed: _sending ? null : _send),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProposedActionCard(AiMessage message) {
    final action = message.proposedAction!;
    String title = 'Proposed action';
    if (action is SendReminderAction) title = 'Send reminder to ${action.customerName} via ${action.channel}';
    if (action is RecordPaymentAction) title = 'Record payment of ₹${action.amount.toStringAsFixed(0)} from ${action.customerName}';

    return Card(
      color: Colors.yellow[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(onPressed: () async { await _confirmAction(message); }, child: const Text('Confirm')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () async { await _repo.rejectAction(message.id); setState(() => message.confirmationState == ActionConfirmationState.rejected); }, child: const Text('Not now')),
            ])
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAction(AiMessage message) async {
    try {
      await _repo.confirmAction(message.id);
      setState(() {
        // optimistic update
        message.confirmationState == ActionConfirmationState.confirmed;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action confirmed')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not confirm action: $e')));
    }
  }
}
