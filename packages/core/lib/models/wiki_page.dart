import 'package:uuid/uuid.dart';

import 'wiki_page_type.dart';

class WikiPage {
  final String id;
  final String title;
  final WikiPageType pageType;
  final String body;
  final List<String> tags;
  final List<String> aliases;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? referenceId;
  final Map<String, dynamic> statBlock;

  WikiPage({
    String? id,
    required this.title,
    required this.pageType,
    this.body = '',
    this.tags = const [],
    this.aliases = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.referenceId,
    this.statBlock = const {},
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pageType': pageType.name,
      'body': body,
      'tags': tags,
      'aliases': aliases,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'referenceId': referenceId,
      'statBlock': statBlock,
    };
  }

  factory WikiPage.fromJson(Map<String, dynamic> json) {
    return WikiPage(
      id: json['id'] as String,
      title: json['title'] as String,
      pageType: WikiPageType.values.byName(json['pageType'] as String),
      body: json['body'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      referenceId: json['referenceId'] as String?,
      statBlock: json['statBlock'] != null
          ? Map<String, dynamic>.from(json['statBlock'] as Map)
          : {},
    );
  }
}
