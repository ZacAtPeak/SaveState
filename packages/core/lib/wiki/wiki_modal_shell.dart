import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wiki_modal_provider.dart';
import 'wiki_page_list.dart';
import 'wiki_page_detail.dart';
import 'wiki_type_picker.dart';
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
          modal.setLayoutMode(isTwoPanel);
          if (modal.pages.isEmpty && widget.pages.isNotEmpty) {
            modal.setPages(widget.pages);
          }
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Create page',
                  onPressed: () {
                    if (isTwoPanel) {
                      widget.provider.startCreate();
                    } else {
                      _openSinglePanelCreateFlow(context);
                    }
                  },
                ),
              ],
            ),
            body: isTwoPanel
                ? Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: WikiPageList(
                          pages: modal.pages,
                          onPageSelected: (page) {
                            widget.provider.selectPage(page);
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildTwoPanelRight(modal),
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
            pages: modal.pages,
            onPageSelected: (page) {
              widget.provider.selectPage(page);
            },
          )
        : WikiPageDetail(page: modal.selectedPage!);
  }

  Widget _buildTwoPanelRight(WikiModalProvider modal) {
    if (modal.isCreating && modal.pendingType == null) {
      return WikiTypePicker(
        onTypeSelected: widget.provider.selectCreateType,
        onCancel: widget.provider.cancelCreate,
      );
    }
    if (modal.isCreating && modal.pendingType != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selected type: ${modal.pendingType!.displayName}'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: widget.provider.cancelCreate, child: const Text('Cancel')),
          ],
        ),
      );
    }
    return modal.selectedPage != null
        ? WikiPageDetail(page: modal.selectedPage!)
        : const Center(child: Text('Select a page to view details'));
  }

  Future<void> _openSinglePanelCreateFlow(BuildContext context) async {
    widget.provider.startCreate();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Create page')),
          body: Consumer<WikiModalProvider>(
            builder: (context, modal, _) {
              if (modal.pendingType == null) {
                return WikiTypePicker(
                  onTypeSelected: widget.provider.selectCreateType,
                  onCancel: () {
                    widget.provider.cancelCreate();
                    Navigator.of(context).pop();
                  },
                );
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Selected type: ${modal.pendingType!.displayName}'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        widget.provider.cancelCreate();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
