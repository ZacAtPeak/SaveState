import 'package:flutter/material.dart';
import 'package:core/data/data.dart';
import 'widgets/creature_detail_view.dart';
import 'widgets/initiative_tracker.dart';
import 'widgets/roll_history_panel.dart';

void main() {
  runApp(const DmApp());
}

class DmApp extends StatelessWidget {
  const DmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveState DM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class _SidebarEntry {
  final CombatantDragData drag;
  final CreatureDetail detail;

  const _SidebarEntry({required this.drag, required this.detail});

  String get id => drag.id;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InitiativeEntry> _entries = const [];
  int _activeIndex = -1;
  bool _sidebarExpanded = true;
  final Set<String> _expandedSections = {'Characters'};

  late final List<_SidebarEntry> _characters = demoPlayerCharacters
      .map((pc) => _SidebarEntry(
            drag: CombatantDragData.fromPlayerCharacter(pc),
            detail: CreatureDetail.fromPlayerCharacter(pc),
          ))
      .toList();

  late final List<_SidebarEntry> _monsters = demoMonsters
      .map((m) => _SidebarEntry(
            drag: CombatantDragData.fromMonster(m),
            detail: CreatureDetail.fromMonster(m),
          ))
      .toList();

  late final List<_SidebarEntry> _npcs = demoNPCs
      .map((n) => _SidebarEntry(
            drag: CombatantDragData.fromNPC(n),
            detail: CreatureDetail.fromNPC(n),
          ))
      .toList();

  late final Map<String, CreatureDetail> _detailById = {
    for (final e in [..._characters, ..._monsters, ..._npcs])
      e.id: e.detail,
  };

  CreatureDetail? _selectedDetail;
  final List<RollHistoryEntry> _rollHistory = [];
  int _unreadRolls = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onEntriesChanged(List<InitiativeEntry> entries) {
    setState(() => _entries = entries);
  }

  void _onActiveIndexChanged(int index) {
    setState(() => _activeIndex = index);
  }

  void _toggleSection(String section) {
    setState(() {
      if (!_expandedSections.remove(section)) {
        _expandedSections.add(section);
      }
    });
  }

  void _onSelect(_SidebarEntry entry) {
    setState(() => _selectedDetail = entry.detail);
  }

  void _onTrackerEntryTap(InitiativeEntry entry) {
    final detail = _detailById[entry.sourceId];
    if (detail != null) {
      setState(() => _selectedDetail = detail);
    }
  }

  void _onRoll(RollHistoryEntry entry) {
    setState(() {
      _rollHistory.add(entry);
      _unreadRolls++;
    });
  }

  void _clearRolls() {
    setState(() => _rollHistory.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: RollHistoryPanel(
        history: _rollHistory,
        onClear: _clearRolls,
      ),
      appBar: AppBar(
        title: const Text('SaveState DM'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _unreadRolls > 0,
              backgroundColor: Colors.red,
              child: const Icon(Icons.casino),
            ),
            tooltip: 'Dice Rolls',
            onPressed: () {
              setState(() => _unreadRolls = 0);
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Wiki',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sidebar(
            expanded: _sidebarExpanded,
            onToggle: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
            expandedSections: _expandedSections,
            onSectionToggle: _toggleSection,
            characters: _characters,
            monsters: _monsters,
            npcs: _npcs,
            assets: const [],
            selectedId: _selectedDetail?.id,
            onSelect: _onSelect,
          ),
          Expanded(
            child: Column(
              children: [
                InitiativeTracker(
                  entries: _entries,
                  onEntriesChanged: _onEntriesChanged,
                  onActiveIndexChanged: _onActiveIndexChanged,
                  onRoll: _onRoll,
                  onEntryTap: _onTrackerEntryTap,
                  activeIndex: _activeIndex,
                ),
                Expanded(
                  child: CreatureDetailView(detail: _selectedDetail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatefulWidget {
  const _Sidebar({
    required this.expanded,
    required this.onToggle,
    required this.expandedSections,
    required this.onSectionToggle,
    required this.characters,
    required this.monsters,
    required this.npcs,
    required this.assets,
    required this.selectedId,
    required this.onSelect,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final Set<String> expandedSections;
  final ValueChanged<String> onSectionToggle;
  final List<_SidebarEntry> characters;
  final List<_SidebarEntry> monsters;
  final List<_SidebarEntry> npcs;
  final List<_SidebarEntry> assets;
  final String? selectedId;
  final ValueChanged<_SidebarEntry> onSelect;

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  bool _fabOpen = false;

  void _toggleFab() => setState(() => _fabOpen = !_fabOpen);
  void _closeFab() => setState(() => _fabOpen = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: widget.expanded ? 240 : 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment:
                widget.expanded ? Alignment.centerRight : Alignment.center,
            child: IconButton(
              icon: Icon(
                  widget.expanded ? Icons.chevron_left : Icons.chevron_right),
              tooltip: widget.expanded ? 'Collapse' : 'Expand',
              onPressed: widget.onToggle,
            ),
          ),
          if (widget.expanded)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SidebarSection(
                    title: 'Characters',
                    icon: Icons.shield_moon,
                    items: widget.characters,
                    expanded: widget.expandedSections.contains('Characters'),
                    onToggle: () => widget.onSectionToggle('Characters'),
                    selectedId: widget.selectedId,
                    onSelect: widget.onSelect,
                  ),
                  _SidebarSection(
                    title: 'Monsters',
                    icon: Icons.pets,
                    items: widget.monsters,
                    expanded: widget.expandedSections.contains('Monsters'),
                    onToggle: () => widget.onSectionToggle('Monsters'),
                    selectedId: widget.selectedId,
                    onSelect: widget.onSelect,
                  ),
                  _SidebarSection(
                    title: 'NPCs',
                    icon: Icons.people,
                    items: widget.npcs,
                    expanded: widget.expandedSections.contains('NPCs'),
                    onToggle: () => widget.onSectionToggle('NPCs'),
                    selectedId: widget.selectedId,
                    onSelect: widget.onSelect,
                  ),
                  _SidebarSection(
                    title: 'Assets',
                    icon: Icons.inventory_2,
                    items: widget.assets,
                    expanded: widget.expandedSections.contains('Assets'),
                    onToggle: () => widget.onSectionToggle('Assets'),
                    selectedId: widget.selectedId,
                    onSelect: widget.onSelect,
                  ),
                ],
              ),
            ),
          if (widget.expanded)
            _SidebarFab(open: _fabOpen, onToggle: _toggleFab, onClose: _closeFab),
        ],
      ),
    );
  }
}

class _SidebarFab extends StatelessWidget {
  const _SidebarFab({
    required this.open,
    required this.onToggle,
    required this.onClose,
  });

  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  static const _actions = [
    (Icons.person, 'Add Character'),
    (Icons.pest_control, 'Add Monster'),
    (Icons.people, 'Add NPC'),
    (Icons.inventory_2, 'Add Asset'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: open
                  ? _actions.map((action) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(20),
                              color: theme.colorScheme.surfaceContainerHigh,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: onClose,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(action.$1,
                                          size: 18,
                                          color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        action.$2,
                                        style: theme.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  : [],
            ),
          ),
          // Main FAB
          FloatingActionButton.small(
            heroTag: 'sidebar_fab',
            onPressed: onToggle,
            tooltip: open ? 'Close' : 'Add',
            child: AnimatedRotation(
              turns: open ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  const _SidebarSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.expanded,
    required this.onToggle,
    required this.selectedId,
    required this.onSelect,
  });

  final String title;
  final IconData icon;
  final List<_SidebarEntry> items;
  final bool expanded;
  final VoidCallback onToggle;
  final String? selectedId;
  final ValueChanged<_SidebarEntry> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title, style: theme.textTheme.titleSmall),
          trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          onTap: onToggle,
          dense: true,
        ),
        if (expanded)
          ...items.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(left: 24),
              child: _DraggableCombatantTile(
                entry: entry,
                selected: entry.id == selectedId,
                onTap: () => onSelect(entry),
              ),
            ),
          ),
      ],
    );
  }
}

class _DraggableCombatantTile extends StatelessWidget {
  const _DraggableCombatantTile({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final _SidebarEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = entry.drag;
    final tile = ListTile(
      title: Text(data.name),
      dense: true,
      visualDensity: VisualDensity.compact,
      selected: selected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
      onTap: onTap,
    );

    return Draggable<CombatantDragData>(
      data: data,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(6),
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            data.name,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: tile),
      child: tile,
    );
  }
}
