import 'package:flutter/material.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/models.dart';

class SidebarWidget extends StatefulWidget {
  final Function(Entity)? onEntitySelected;

  const SidebarWidget({super.key, this.onEntitySelected});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  List<Entity> _bookmarkedEntities = [];
  List<Entity> _recentEntities = [];
  List<Entity> _allEntities = [];

  @override
  void initState() {
    super.initState();
    appSettings.addListener(_onSettingsChanged);
    _loadSidebarEntities();
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    _loadSidebarEntities();
  }

  Future<void> _loadSidebarEntities() async {
    final selectedSystem = appSettings.selectedGameSystem;
    if (selectedSystem == null) {
      setState(() {
        _bookmarkedEntities = [];
        _recentEntities = [];
        _allEntities = [];
      });
      return;
    }

    final systemId = selectedSystem.id!;

    final allBookmarked = await DatabaseHelper.instance.getBookmarkedEntities();
    final allRecent = await DatabaseHelper.instance.getRecentEntities(limit: 10);
    final allSystemEntities = await DatabaseHelper.instance.getEntitiesByGameSystem(systemId);

    setState(() {
      _bookmarkedEntities = allBookmarked.where((e) => e.gameSystemId == systemId).toList();
      _recentEntities = allRecent.where((e) => e.gameSystemId == systemId).toList();
      _allEntities = allSystemEntities;
    });
  }

  Future<void> _toggleBookmark(Entity entity) async {
    await DatabaseHelper.instance.toggleBookmark(entity.id!);
    await _loadSidebarEntities();
  }

  void _openEntity(Entity entity) async {
    await DatabaseHelper.instance.markEntityViewed(entity.id!);
    widget.onEntitySelected?.call(entity);
    await _loadSidebarEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Bookmarked',
                    icon: Icons.bookmark,
                    count: _bookmarkedEntities.length,
                  ),
                  if (_bookmarkedEntities.isEmpty)
                    const _EmptySectionMessage(
                      message: 'No bookmarked entities',
                    )
                  else
                    ..._bookmarkedEntities.map(
                      (entity) => _EntityListItem(
                        entity: entity,
                        onTap: () => _openEntity(entity),
                        onBookmarkTap: () => _toggleBookmark(entity),
                        isBookmarked: true,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Recent',
                    icon: Icons.history,
                    count: _recentEntities.length,
                  ),
                  if (_recentEntities.isEmpty)
                    const _EmptySectionMessage(
                      message: 'No recently viewed',
                    )
                  else
                    ..._recentEntities.map(
                      (entity) => _EntityListItem(
                        entity: entity,
                        onTap: () => _openEntity(entity),
                        onBookmarkTap: () => _toggleBookmark(entity),
                        isBookmarked: entity.isBookmarked,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'All Entities',
                    icon: Icons.list,
                    count: _allEntities.length,
                  ),
                  if (_allEntities.isEmpty)
                    const _EmptySectionMessage(
                      message: 'No entities',
                    )
                  else
                    ..._allEntities.map(
                      (entity) => _EntityListItem(
                        entity: entity,
                        onTap: () => _openEntity(entity),
                        onBookmarkTap: () => _toggleBookmark(entity),
                        isBookmarked: entity.isBookmarked,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  final String message;

  const _EmptySectionMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}

class _EntityListItem extends StatelessWidget {
  final Entity entity;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final bool isBookmarked;

  const _EntityListItem({
    required this.entity,
    required this.onTap,
    required this.onBookmarkTap,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  entity.name.isNotEmpty ? entity.name[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'HP: ${entity.hp}/${entity.maxHp}  AC: ${entity.ac}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onBookmarkTap,
              child: Icon(
                isBookmarked ? Icons.star : Icons.star_border,
                size: 20,
                color: isBookmarked
                    ? Colors.amber
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}