import 'dart:convert';

enum AiMessageRole { user, assistant }
enum ActionConfirmationState { none, awaitingConfirmation, confirmed, rejected }

abstract class ProposedAction {
  const ProposedAction();
}

class SendReminderAction extends ProposedAction {
  final String customerId;
  final String channel;
  final String customerName;
  const SendReminderAction({required this.customerId, required this.channel, required this.customerName});
}

class RecordPaymentAction extends ProposedAction {
  final String customerId;
  final double amount;
  final String customerName;
  const RecordPaymentAction({required this.customerId, required this.amount, required this.customerName});
}

class AiMessage {
  final String id;
  final AiMessageRole role;
  final String content;
  final ProposedAction? proposedAction;
  final ActionConfirmationState confirmationState;

  AiMessage({required this.id, required this.role, required this.content, this.proposedAction, required this.confirmationState});

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    final role = json['role'] == 'assistant' ? AiMessageRole.assistant : AiMessageRole.user;
    final proposed = _parseProposedAction(json['proposed_action']);
    final confirmationState = _parseConfirmationState(json['action_confirmed']);
    return AiMessage(id: json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(), role: role, content: json['content'] ?? '', proposedAction: proposed, confirmationState: confirmationState);
  }

  static ProposedAction? _parseProposedAction(dynamic json) {
    if (json == null) return null;
    try {
      final map = json is String ? jsonDecode(json) : json as Map<String, dynamic>;
      final type = map['type'];
      switch (type) {
        case 'send_reminder':
          return SendReminderAction(customerId: map['customer_id'], channel: map['channel'], customerName: map['customer_name'] ?? '');
        case 'record_payment':
          return RecordPaymentAction(customerId: map['customer_id'], amount: (map['amount'] as num).toDouble(), customerName: map['customer_name'] ?? '');
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  static ActionConfirmationState _parseConfirmationState(dynamic val) {
    if (val == null) return ActionConfirmationState.none;
    if (val == true) return ActionConfirmationState.confirmed;
    return ActionConfirmationState.awaitingConfirmation;
  }

  static AiMessage mockAssistantSuggestReminder() {
    return AiMessage(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      role: AiMessageRole.assistant,
      content: 'I can remind Ramesh about his overdue amount.',
      proposedAction: SendReminderAction(customerId: 'cust-123', channel: 'whatsapp', customerName: 'Ramesh'),
      confirmationState: ActionConfirmationState.awaitingConfirmation,
    );
  }
}
