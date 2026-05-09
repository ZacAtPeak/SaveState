import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSidebarEntities();
  }

  Future<void> _loadSidebarEntities() async {
    final bookmarked = await DatabaseHelper.instance.getBookmarkedEntities();
    final recent = await DatabaseHelper.instance.getRecentEntities(limit: 10);
    setState(() {
      _bookmarkedEntities = bookmarked;
      _recentEntities = recent;
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
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.shield,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'DM Screen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Bookmarked section
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
                  // Recent section
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
            // Entity icon
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
            // Entity info
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
            // Bookmark button
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
