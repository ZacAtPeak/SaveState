import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'section_renderer.dart';

class SchemaFormBuilder extends StatelessWidget {
  const SchemaFormBuilder({
    super.key,
    required this.fields,
    required this.data,
    required this.onDataChanged,
    this.gameModel,
  });

  final List<FieldSchema> fields;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onDataChanged;
  final GameModel? gameModel;

  @override
  Widget build(BuildContext context) {
    // Group fields by section
    final sections = <String, List<FieldSchema>>{};
    for (final field in fields) {
      final section = field.section ?? 'General';
      sections.putIfAbsent(section, () => []).add(field);
    }

    // Render sections in schema order (or alphabetical if no order)
    final sectionOrder = [
      'Vitals',
      'Abilities',
      'Combat',
      'Skills',
      'Spells',
      'Lore',
      'General',
    ];
    final orderedSections = sectionOrder.where(sections.containsKey).toList();
    for (final key in sections.keys) {
      if (!orderedSections.contains(key)) {
        orderedSections.add(key);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: orderedSections.map((section) {
          return SectionRenderer(
            title: section,
            fields: sections[section]!,
            data: data,
            onChanged: onDataChanged,
            gameModel: gameModel,
          );
        }).toList(),
      ),
    );
  }
}
