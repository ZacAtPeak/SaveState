import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'list_field_renderer.dart';

class FieldRenderer extends StatelessWidget {
  const FieldRenderer({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.gameModel,
    this.data,
  });

  final FieldSchema field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final GameModel? gameModel;

  /// Full data map for derivedFrom formula evaluation context.
  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    // Derived fields are read-only
    if (field.derivedFrom != null) {
      return _buildDerivedField(context);
    }

    // Group type is handled by parent (SectionRenderer)
    if (field.inputType == FieldInputType.group) {
      return const SizedBox.shrink();
    }

    // List type delegates to ListFieldRenderer
    if (field.inputType == FieldInputType.list) {
      return ListFieldRenderer(
        field: field,
        value: value as List<dynamic>?,
        onChanged: onChanged,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: _buildInput(context),
    );
  }

  Widget _buildDerivedField(BuildContext context) {
    final theme = Theme.of(context);
    final contextData = data ?? _extractDataFromValue();
    try {
      final result = FormulaEvaluator.evaluate(field.derivedFrom!, contextData);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                field.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              result is int ? '$result' : result.toStringAsFixed(1),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } on FormulaError {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          '${field.label}: Error',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }
  }

  Map<String, dynamic> _extractDataFromValue() {
    // Value is expected to be a Map<String, dynamic> from parent data context
    if (value is Map<String, dynamic>) return value as Map<String, dynamic>;
    return {};
  }

  Widget _buildInput(BuildContext context) {
    final label = field.required ? '${field.label} *' : field.label;

    switch (field.inputType) {
      case FieldInputType.text:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            labelText: label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
          ),
          validator: field.required
              ? (v) => (v == null || v.trim().isEmpty) ? '${field.label} is required' : null
              : null,
          onChanged: onChanged,
        );

      case FieldInputType.number:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
          ),
          validator: (v) {
            if (field.required && (v == null || v.trim().isEmpty)) {
              return '${field.label} is required';
            }
            if (v != null && v.trim().isNotEmpty && num.tryParse(v.trim()) == null) {
              return '${field.label} must be a number';
            }
            return null;
          },
          onChanged: (v) {
            final parsed = num.tryParse(v.trim());
            if (parsed != null) onChanged(parsed);
          },
        );

      case FieldInputType.multiline:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
          ),
          validator: field.required
              ? (v) => (v == null || v.trim().isEmpty) ? '${field.label} is required' : null
              : null,
          onChanged: onChanged,
        );

      case FieldInputType.select:
        final options = field.enumOptions ?? [];
        return DropdownButtonFormField<String>(
          initialValue: options.contains(value) ? value as String? : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
          ),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          validator: field.required
              ? (v) => (v == null) ? '${field.label} is required' : null
              : null,
        );

      case FieldInputType.checkbox:
        return SwitchListTile(
          title: Text(label),
          value: value == true,
          onChanged: (v) => onChanged(v),
        );

      case FieldInputType.dice:
        return _buildDiceButton(context);

      case FieldInputType.group:
        return const SizedBox.shrink();

      case FieldInputType.list:
        return const SizedBox.shrink(); // handled above
    }
  }

  Widget _buildDiceButton(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(field.label, style: theme.textTheme.bodyMedium)),
        ElevatedButton.icon(
          onPressed: field.derivedFrom != null
              ? () {
                  try {
                    final contextData = data ?? _extractDataFromValue();
                    final result = FormulaEvaluator.evaluate(
                      field.derivedFrom!,
                      contextData,
                    );
                    onChanged(result);
                  } on FormulaError catch (_) {
                    // Show snackbar or silent fail
                  }
                }
              : null,
          icon: const Icon(Icons.casino),
          label: Text(field.hint ?? 'Roll'),
        ),
      ],
    );
  }
}
