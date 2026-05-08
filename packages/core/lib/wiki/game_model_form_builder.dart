import 'package:flutter/material.dart';
import 'package:core/models/models.dart';

class GameModelFormBuilder extends StatefulWidget {
  const GameModelFormBuilder({
    super.key,
    required this.fields,
    required this.controllers,
  });

  final List<FieldSchema> fields;
  final Map<String, TextEditingController> controllers;

  @override
  State<GameModelFormBuilder> createState() => _GameModelFormBuilderState();
}

class _GameModelFormBuilderState extends State<GameModelFormBuilder> {
  final Map<String, TextEditingController> _internalControllers = {};

  @override
  void initState() {
    super.initState();
    _ensureControllers();
  }

  void _ensureControllers() {
    for (final field in widget.fields) {
      if (!widget.controllers.containsKey(field.key) &&
          !_internalControllers.containsKey(field.key)) {
        _internalControllers[field.key] = TextEditingController(
          text: field.defaultValue?.toString() ?? '',
        );
      }
    }
  }

  TextEditingController _controllerFor(FieldSchema field) {
    return widget.controllers[field.key] ?? _internalControllers[field.key]!;
  }

  String? _validatorFor(FieldSchema field, String? value) {
    if (field.required && (value == null || value.trim().isEmpty)) {
      return '${field.label} is required';
    }
    if (field.inputType == FieldInputType.number &&
        value != null &&
        value.trim().isNotEmpty) {
      if (num.tryParse(value.trim()) == null) {
        return '${field.label} must be a number';
      }
    }
    return null;
  }

  @override
  void dispose() {
    for (final controller in _internalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.fields.map(_buildField).toList(),
    );
  }

  Widget _buildField(FieldSchema field) {
    switch (field.inputType) {
      case FieldInputType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: _controllerFor(field),
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => _validatorFor(field, value),
          ),
        );

      case FieldInputType.number:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: _controllerFor(field),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => _validatorFor(field, value),
          ),
        );

      case FieldInputType.multiline:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: _controllerFor(field),
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => _validatorFor(field, value),
          ),
        );

      case FieldInputType.select:
        final options = field.enumOptions ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DropdownButtonFormField<String>(
            initialValue: _controllerFor(field).text.isEmpty ? null : _controllerFor(field).text,
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint,
              border: const OutlineInputBorder(),
            ),
            items: options
                .map((option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _controllerFor(field).text = value;
              }
            },
            validator: (value) => _validatorFor(field, value),
          ),
        );

      case FieldInputType.checkbox:
      case FieldInputType.list:
      case FieldInputType.dice:
      case FieldInputType.group:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'TODO: ${field.inputType.name} input',
              border: const OutlineInputBorder(),
            ),
          ),
        );
    }
  }
}
