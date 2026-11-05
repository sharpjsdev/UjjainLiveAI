import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'message.dart';

part 'chat_session.g.dart';

@JsonSerializable()
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<Message> messages;
  final Map<String, dynamic> context;

  ChatSession({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<Message>? messages,
    Map<String, dynamic>? context,
  }) : id = id ?? const Uuid().v4(),
       title = title ?? 'New Chat',
       createdAt = createdAt ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now(),
       messages = messages ?? [],
       context = context ?? {};

  factory ChatSession.fromJson(Map<String, dynamic> json) => _$ChatSessionFromJson(json);
  
  Map<String, dynamic> toJson() => _$ChatSessionToJson(this);

  ChatSession copyWith({
    String? title,
    DateTime? lastUpdated,
    List<Message>? messages,
    Map<String, dynamic>? context,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
      messages: messages ?? List.from(this.messages),
      context: context ?? Map.from(this.context),
    );
  }

  ChatSession addMessage(Message message) {
    final updatedMessages = List<Message>.from(messages)..add(message);
    return copyWith(
      messages: updatedMessages,
      lastUpdated: DateTime.now(),
    );
  }

  ChatSession updateMessage(String messageId, Message updatedMessage) {
    final updatedMessages = messages.map((msg) {
      return msg.id == messageId ? updatedMessage : msg;
    }).toList();
    return copyWith(messages: updatedMessages);
  }
}