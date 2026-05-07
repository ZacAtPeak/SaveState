import 'dart:async';

import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';

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
  Timer? _debounceTimer;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchService = WikiSearchService();
    _searchService.index(widget.pages);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    widget.onQueryChanged?.call(query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      setState(() => _currentQuery = query);
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
                leading: Icon(_iconForType(page.pageType)),
                title: Text(page.title),
                subtitle: page.tags.isNotEmpty
                    ? Text(page.tags.join(', '))
                    : null,
                trailing: Chip(
                  label: Text(page.pageType.displayName),
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

  IconData _iconForType(WikiPageType type) {
    switch (type) {
      case WikiPageType.creature:
        return Icons.pets;
      case WikiPageType.spell:
        return Icons.auto_awesome;
      case WikiPageType.item:
        return Icons.gavel;
      case WikiPageType.rule:
        return Icons.menu_book;
      case WikiPageType.location:
        return Icons.location_on;
      case WikiPageType.npc:
        return Icons.person;
      case WikiPageType.other:
        return Icons.article;
    }
  }
}
