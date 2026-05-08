import 'package:core/models/models.dart';
import 'package:flutter/material.dart';
import 'game_model_form_builder.dart';

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
    required this.entitySchema,
    required this.onCancel,
    required this.onSubmit,
  });

  final EntityTypeSchema entitySchema;
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
    for (final field in widget.entitySchema.fields) {
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
                  Text('Create ${widget.entitySchema.displayName}', style: Theme.of(context).textTheme.titleLarge),
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
              GameModelFormBuilder(fields: widget.entitySchema.fields, controllers: _structured),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final statBlock = <String, dynamic>{};
    for (final field in widget.entitySchema.fields) {
      final raw = _structured[field.key]!.text.trim();
      if (raw.isEmpty) continue;
      statBlock[field.key] = field.inputType == FieldInputType.number ? num.parse(raw) : raw;
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
