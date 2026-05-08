import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:core/models/models.dart';
import 'wiki_stat_block.dart';

class WikiPageDetail extends StatelessWidget {
  const WikiPageDetail({super.key, required this.page});

  final WikiPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(page.title, style: theme.textTheme.headlineSmall),
            if (page.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: page.tags
                    .map((t) => Chip(label: Text(t), visualDensity: VisualDensity.compact))
                    .toList(),
              ),
            ],
            if (_isReferenceType(page.entityTypeKey) && page.statBlock.isNotEmpty)
              WikiStatBlock(statBlock: page.statBlock),
            if (page.body.isNotEmpty) ...[
              const SizedBox(height: 8),
              MarkdownBody(data: page.body),
            ],
          ],
        ),
      ),
    );
  }
}

bool _isReferenceType(String entityTypeKey) =>
    entityTypeKey == 'creature' || entityTypeKey == 'npc';
