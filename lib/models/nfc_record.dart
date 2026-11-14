import 'package:uuid/uuid.dart';

enum NfcRecordType { text, uri, mime, external, unknown, smartPoster }

class NfcRecord {
  final String id;
  final NfcRecordType type;
  final String content;
  final DateTime timestamp;
  final String? mimeType;
  final Map<String, dynamic>? metadata;
  final bool isFavorite;

  NfcRecord({
    String? id,
    required this.type,
    required this.content,
    DateTime? timestamp,
    this.mimeType,
    this.metadata,
    this.isFavorite = false,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  NfcRecord copyWith({bool? isFavorite}) {
    return NfcRecord(
      id: id,
      type: type,
      content: content,
      timestamp: timestamp,
      mimeType: mimeType,
      metadata: metadata,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'mimeType': mimeType,
      'metadata': metadata,
      'isFavorite': isFavorite,
    };
  }

  factory NfcRecord.fromJson(Map<String, dynamic> json) {
    return NfcRecord(
      id: json['id'],
      type: NfcRecordType.values[json['type'] as int],
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mimeType: json['mimeType'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
