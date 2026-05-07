import 'package:flutter/material.dart';

class TabData {
  final String label;
  final Widget icon;
  final Widget content;

  const TabData({
    required this.label,
    required this.icon,
    required this.content,
  });
}

class GenericTabView extends StatefulWidget {
  final List<TabData> tabs;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;

  const GenericTabView({
    super.key,
    required this.tabs,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.initialIndex = 0,
    this.onTabChanged,
  });

  @override
  State<GenericTabView> createState() => _GenericTabViewState();
}

class _GenericTabViewState extends State<GenericTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && widget.onTabChanged != null) {
      widget.onTabChanged!(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Material(
          color: theme.colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: widget.tabs.map((tab) {
              return Tab(
                icon: tab.icon,
                text: tab.label,
              );
            }).toList(),
            indicatorColor: widget.indicatorColor ?? theme.colorScheme.primary,
            labelColor: widget.labelColor ?? theme.colorScheme.onSurface,
            unselectedLabelColor:
                widget.unselectedLabelColor ?? theme.colorScheme.onSurfaceVariant,
            labelStyle: widget.labelStyle,
            unselectedLabelStyle: widget.unselectedLabelStyle,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs.map((tab) => tab.content).toList(),
          ),
        ),
      ],
    );
  }
}
