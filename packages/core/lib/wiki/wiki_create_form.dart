import 'package:core/models/models.dart';
import 'package:flutter/material.dart';

class WikiCreateDraft {
  const WikiCreateDraft({
    required this.title,
    required this.body,
    required this.tags,
    required this.aliases,
    required this.statBlock,
  });

  final String title;
  final String body;
  final List<String> tags;
  final List<String> aliases;
  final Map<String, dynamic> statBlock;
}

class WikiCreateForm extends StatefulWidget {
  const WikiCreateForm({
    super.key,
    required this.selectedType,
    required this.onCancel,
    required this.onSubmit,
  });

  final WikiPageType selectedType;
  final VoidCallback onCancel;
  final Future<void> Function(WikiCreateDraft) onSubmit;

  @override
  State<WikiCreateForm> createState() => _WikiCreateFormState();
}

class _WikiCreateFormState extends State<WikiCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _tags = TextEditingController();
  final _aliases = TextEditingController();
  final Map<String, TextEditingController> _structured = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.selectedType.fields) {
      _structured[field.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _tags.dispose();
    _aliases.dispose();
    for (final controller in _structured.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: widget.onCancel, icon: const Icon(Icons.arrow_back)),
                  const SizedBox(width: 8),
                  Text('Create ${widget.selectedType.displayName}', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
              ),
              TextFormField(controller: _body, decoration: const InputDecoration(labelText: 'Body (markdown)'), minLines: 3, maxLines: 6),
              TextFormField(controller: _tags, decoration: const InputDecoration(labelText: 'Tags (comma-separated)')),
              TextFormField(controller: _aliases, decoration: const InputDecoration(labelText: 'Aliases (comma-separated)')),
              const SizedBox(height: 16),
              Text('Structured fields', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...widget.selectedType.fields.map(_buildStructuredField),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Saving...' : 'Create page'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStructuredField(WikiPageFieldDefinition field) {
    if (field.inputType == WikiFieldInputType.select) {
      final options = field.options ?? const <String>[];
      return DropdownButtonFormField<String>(
        initialValue: _structured[field.key]!.text.isEmpty ? null : _structured[field.key]!.text,
        decoration: InputDecoration(labelText: field.label, hintText: field.hint),
        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        validator: field.required ? (value) => (value == null || value.isEmpty) ? '${field.label} is required' : null : null,
        onChanged: (value) => _structured[field.key]!.text = value ?? '',
      );
    }

    final isNumber = field.inputType == WikiFieldInputType.number;
    final isMultiline = field.inputType == WikiFieldInputType.multiline;
    return TextFormField(
      controller: _structured[field.key],
      decoration: InputDecoration(labelText: field.label, hintText: field.hint),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      minLines: isMultiline ? 3 : 1,
      maxLines: isMultiline ? 5 : 1,
      validator: (value) {
        if (field.required && (value == null || value.trim().isEmpty)) {
          return '${field.label} is required';
        }
        if (isNumber && value != null && value.trim().isNotEmpty && num.tryParse(value.trim()) == null) {
          return '${field.label} must be a number';
        }
        return null;
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final statBlock = <String, dynamic>{};
    for (final field in widget.selectedType.fields) {
      final raw = _structured[field.key]!.text.trim();
      if (raw.isEmpty) continue;
      statBlock[field.key] = field.inputType == WikiFieldInputType.number ? num.parse(raw) : raw;
    }

    try {
      await widget.onSubmit(
        WikiCreateDraft(
          title: _title.text.trim(),
          body: _body.text.trim(),
          tags: _splitCsv(_tags.text),
          aliases: _splitCsv(_aliases.text),
          statBlock: statBlock,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save page. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  List<String> _splitCsv(String value) {
    return value.split(',').map((entry) => entry.trim()).where((entry) => entry.isNotEmpty).toList();
  }
}
