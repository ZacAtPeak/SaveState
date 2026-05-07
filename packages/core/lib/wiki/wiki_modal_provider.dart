import 'package:flutter/foundation.dart';
import 'package:core/models/wiki_page.dart';

class WikiModalProvider extends ChangeNotifier {
  WikiPage? _selectedPage;
  bool _isTwoPanel = false;

  WikiPage? get selectedPage => _selectedPage;
  bool get isTwoPanel => _isTwoPanel;

  void selectPage(WikiPage? page) {
    _selectedPage = page;
    notifyListeners();
  }

  void setLayoutMode(bool isTwoPanel) {
    _isTwoPanel = isTwoPanel;
    notifyListeners();
  }

  void reset() {
    _selectedPage = null;
    notifyListeners();
  }
}
