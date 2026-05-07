import 'package:flutter/foundation.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';

class WikiModalProvider extends ChangeNotifier implements WikiCreateTarget {
  WikiPage? _selectedPage;
  bool _isTwoPanel = false;
  bool _isCreating = false;
  WikiPageType? _pendingType;
  final List<WikiPage> _pages = [];

  WikiPage? get selectedPage => _selectedPage;
  bool get isTwoPanel => _isTwoPanel;
  bool get isCreating => _isCreating;
  WikiPageType? get pendingType => _pendingType;
  List<WikiPage> get pages => List.unmodifiable(_pages);

  void setPages(List<WikiPage> pages) {
    if (_pages.length == pages.length &&
        _pages.asMap().entries.every((entry) => entry.value.id == pages[entry.key].id)) {
      return;
    }
    _pages
      ..clear()
      ..addAll(pages);
    notifyListeners();
  }

  void addPage(WikiPage page) {
    _pages.add(page);
    _selectedPage = page;
    notifyListeners();
  }

  @override
  void onPageCreated(WikiPage page) => addPage(page);

  @override
  void onCreateComplete() => cancelCreate();

  void selectPage(WikiPage? page) {
    _selectedPage = page;
    notifyListeners();
  }

  void setLayoutMode(bool isTwoPanel) {
    if (_isTwoPanel == isTwoPanel) return;
    _isTwoPanel = isTwoPanel;
    notifyListeners();
  }

  void startCreate() {
    _isCreating = true;
    _pendingType = null;
    notifyListeners();
  }

  void selectCreateType(WikiPageType type) {
    _pendingType = type;
    notifyListeners();
  }

  void cancelCreate() {
    _isCreating = false;
    _pendingType = null;
    notifyListeners();
  }

  void reset() {
    _selectedPage = null;
    _isCreating = false;
    _pendingType = null;
    notifyListeners();
  }
}
