import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wiki_modal_provider.dart';
import 'wiki_page_list.dart';
import 'wiki_page_detail.dart';
import 'package:core/models/models.dart';

class WikiModalShell extends StatefulWidget {
  const WikiModalShell({super.key, this.onClose, required this.provider, required this.pages});
  final VoidCallback? onClose;
  final WikiModalProvider provider;
  final List<WikiPage> pages;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onClose,
    required WikiModalProvider provider,
    required List<WikiPage> pages,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WikiModalShell(onClose: onClose, provider: provider, pages: pages),
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
                        child: WikiPageList(
                          pages: widget.pages,
                          onPageSelected: (page) {
                            widget.provider.selectPage(page);
                          },
                        ),
                      ),
                      Expanded(
                        child: modal.selectedPage != null
                            ? WikiPageDetail(page: modal.selectedPage!)
                            : const Center(child: Text('Select a page to view details')),
                      ),
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
        ? WikiPageList(
            pages: widget.pages,
            onPageSelected: (page) {
              widget.provider.selectPage(page);
            },
          )
        : WikiPageDetail(page: modal.selectedPage!);
  }
}
