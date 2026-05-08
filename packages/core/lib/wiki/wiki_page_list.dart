import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';
import 'package:core/utils/utils.dart';

class WikiPageList extends StatefulWidget {
  const WikiPageList({
    super.key,
    required this.pages,
    this.onQueryChanged,
    this.onPageSelected,
  });

  final List<WikiPage> pages;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<WikiPage>? onPageSelected;

  @override
  State<WikiPageList> createState() => _WikiPageListState();
}

class _WikiPageListState extends State<WikiPageList> {
  late final WikiSearchService _searchService;
  late final DebounceUtil _debounce;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchService = WikiSearchService();
    _searchService.index(widget.pages);
    _debounce = DebounceUtil(const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce.run(() {
      setState(() => _currentQuery = query);
      widget.onQueryChanged?.call(query);
    });
  }

  List<WikiPage> get _displayedPages {
    if (_currentQuery.isEmpty) return widget.pages;
    return _searchService.search(_currentQuery).map((r) => r.page).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search pages...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _onQueryChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _displayedPages.length,
            itemBuilder: (context, index) {
              final page = _displayedPages[index];
              return ListTile(
                leading: Icon(_iconForType(page.entityTypeKey)),
                title: Text(page.title),
                subtitle: page.tags.isNotEmpty
                    ? Text(page.tags.join(', '))
                    : null,
                trailing: Chip(
                  label: Text(_displayNameForType(page.entityTypeKey)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onTap: () => widget.onPageSelected?.call(page),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'creature' => Icons.pets,
      'spell' => Icons.auto_awesome,
      'item' => Icons.gavel,
      'rule' => Icons.menu_book,
      'location' => Icons.location_on,
      'npc' => Icons.person,
      _ => Icons.article,
    };
  }
}

String _displayNameForType(String type) {
  return switch (type) {
    'creature' => 'Creature',
    'spell' => 'Spell',
    'item' => 'Item',
    'rule' => 'Rule',
    'location' => 'Location',
    'npc' => 'NPC',
    _ => 'Other',
  };
}
