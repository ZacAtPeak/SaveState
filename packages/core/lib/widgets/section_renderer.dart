import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'field_renderer.dart';

class SectionRenderer extends StatelessWidget {
  const SectionRenderer({
    super.key,
    required this.title,
    required this.fields,
    required this.data,
    required this.onChanged,
    this.gameModel,
  });

  final String title;
  final List<FieldSchema> fields;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final GameModel? gameModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...fields.map((field) => _renderField(field, context)),
          ],
        ),
      ),
    );
  }

  Widget _renderField(FieldSchema field, BuildContext context) {
    if (field.inputType == FieldInputType.group && field.subFields != null) {
      return _renderGroupField(field, context);
    }
    return FieldRenderer(
      field: field,
      value: data[field.key],
      onChanged: (v) => _updateField(field.key, v),
      gameModel: gameModel,
      data: data,
    );
  }

  Widget _renderGroupField(FieldSchema field, BuildContext context) {
    final theme = Theme.of(context);
    final groupData = data[field.key] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        ...field.subFields!.map(
          (subField) => FieldRenderer(
            field: subField,
            value: groupData[subField.key],
            onChanged: (v) {
              final updated = Map<String, dynamic>.from(groupData)..[subField.key] = v;
              _updateField(field.key, updated);
            },
            gameModel: gameModel,
            data: groupData,
          ),
        ),
      ],
    );
  }

  void _updateField(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(data)..[key] = value;
    onChanged(updated);
  }
}
