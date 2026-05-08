import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:core/models/models.dart';
import 'field_renderer.dart';

class ListFieldRenderer extends StatefulWidget {
  const ListFieldRenderer({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final FieldSchema field;
  final List<dynamic>? value;
  final ValueChanged<dynamic> onChanged;

  @override
  State<ListFieldRenderer> createState() => _ListFieldRendererState();
}

class _ListFieldRendererState extends State<ListFieldRenderer> {
  static const _uuid = Uuid();
  late List<dynamic> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.value ?? [];
  }

  @override
  void didUpdateWidget(ListFieldRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _items = widget.value ?? [];
    }
  }

  void _addItem() {
    final newItem = _createEmptyItem();
    setState(() => _items.add(newItem));
    widget.onChanged(_items);
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    widget.onChanged(_items);
  }

  void _updateItem(int index, Map<String, dynamic> updated) {
    setState(() => _items[index] = updated);
    widget.onChanged(_items);
  }

  Map<String, dynamic> _createEmptyItem() {
    final result = <String, dynamic>{};
    if (widget.field.itemSchema != null) {
      if (widget.field.itemSchema!.subFields != null) {
        for (final subField in widget.field.itemSchema!.subFields!) {
          result[subField.key] = subField.defaultValue ?? '';
        }
      } else {
        result['value'] = widget.field.itemSchema!.defaultValue ?? '';
      }
    }
    result['_id'] = _uuid.v4();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.field.label,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addItem,
              tooltip: 'Add ${widget.field.label}',
            ),
          ],
        ),
        ..._items.asMap().entries.map((entry) => _renderItem(entry.key, entry.value)),
      ],
    );
  }

  Widget _renderItem(int index, dynamic item) {
    if (widget.field.itemSchema?.subFields != null) {
      final itemData = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _removeItem(index),
                    tooltip: 'Remove',
                  ),
                ],
              ),
              ...widget.field.itemSchema!.subFields!.map(
                (subField) => FieldRenderer(
                  field: subField,
                  value: itemData[subField.key],
                  onChanged: (v) =>
                      _updateItem(index, Map<String, dynamic>.from(itemData)..[subField.key] = v),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Simple list (text items)
    return ListTile(
      title: Text(item?.toString() ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _removeItem(index),
      ),
    );
  }
}
