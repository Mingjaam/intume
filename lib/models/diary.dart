class Diary {
  final int? id;
  final String content;
  final String tag;
  final DateTime createdAt;
  final List<String> imagePaths;

  Diary({
    this.id,
    required this.content,
    required this.tag,
    required this.createdAt,
    this.imagePaths = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'tag': tag,
      'created_at': createdAt.toIso8601String(),
      'image_paths': imagePaths.join('||'),
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      content: map['content'],
      tag: map['tag'],
      createdAt: DateTime.parse(map['created_at']),
      imagePaths: map['image_paths']?.split('||') ?? [],
    );
  }
} 