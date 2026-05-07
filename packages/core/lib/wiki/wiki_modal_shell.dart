import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wiki_modal_provider.dart';

class WikiModalShell extends StatefulWidget {
  const WikiModalShell({super.key, this.onClose, required this.provider});
  final VoidCallback? onClose;
  final WikiModalProvider provider;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onClose,
    required WikiModalProvider provider,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WikiModalShell(onClose: onClose, provider: provider),
    );
  }

  @override
  State<WikiModalShell> createState() => _WikiModalShellState();
}

class _WikiModalShellState extends State<WikiModalShell> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTwoPanel = width >= 600;

    return ChangeNotifierProvider.value(
      value: widget.provider,
      child: Consumer<WikiModalProvider>(
        builder: (context, modal, _) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onClose?.call();
                },
              ),
              title: const Text('Wiki'),
            ),
            body: isTwoPanel
                ? Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: _buildListPlaceholder(),
                      ),
                      const Expanded(child: Center(child: Text('WikiPageDetail (coming soon)'))),
                    ],
                  )
                : _buildSinglePanel(modal),
          );
        },
      ),
    );
  }

  Widget _buildSinglePanel(WikiModalProvider modal) {
    return modal.selectedPage == null
        ? _buildListPlaceholder()
        : _buildDetailPlaceholder();
  }

  Widget _buildListPlaceholder() {
    return const Center(child: Text('WikiPageList (coming soon)'));
  }
}

Widget _buildDetailPlaceholder() {
  return Center(child: Text('WikiPageDetail (coming soon)'));
}
