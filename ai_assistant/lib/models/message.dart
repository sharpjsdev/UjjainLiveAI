import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isFromUser;
  final MessageStatus status;
  final String? audioUrl;
  final Map<String, dynamic>? metadata;

  Message({
    String? id,
    required this.content,
    required this.type,
    required this.isFromUser,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
    this.audioUrl,
    this.metadata,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? content,
    MessageType? type,
    MessageStatus? status,
    String? audioUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp,
      isFromUser: isFromUser,
      status: status ?? this.status,
      audioUrl: audioUrl ?? this.audioUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('voice')
  voice,
  @JsonValue('image')
  image,
  @JsonValue('location')
  location,
  @JsonValue('recommendation')
  recommendation,
}

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('error')
  error,
}