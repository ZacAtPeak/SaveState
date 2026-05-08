import 'package:core/data/data.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';
import 'package:flutter/foundation.dart';

class WikiProvider extends ChangeNotifier implements WikiCreateTarget {
  WikiProvider({required WikiStorageService storage}) : _storage = storage;

  final WikiStorageService _storage;
  final List<WikiPage> _pages = [];
  WikiPage? _selectedPage;
  bool _isLoaded = false;
  bool _isCreating = false;
  WikiPageType? _pendingType;

  @override
  List<WikiPage> get pages => List.unmodifiable(_pages);

  @override
  WikiPage? get selectedPage => _selectedPage;

  @override
  bool get isCreating => _isCreating;

  @override
  WikiPageType? get pendingType => _pendingType;

  bool get isLoaded => _isLoaded;

  GameModel? _activeGameModel;
  GameModel? get activeGameModel => _activeGameModel;

  void updateGameModel(GameModel? model) {
    if (_activeGameModel == model) return;
    _activeGameModel = model;
    // Do NOT call notifyListeners() here — the ChangeNotifierProxyProvider
    // handles notification. WikiProvider's own listeners are notified by
    // the proxy provider's update callback.
  }

  Future<void> loadAll() async {
    if (_isLoaded) return;
    final loaded = await _storage.loadAllPages();
    if (loaded.isEmpty) {
      for (final page in demoWikiPages) {
        await _storage.savePage(page);
      }
      _pages.addAll(demoWikiPages);
    } else {
      _pages.addAll(loaded);
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<WikiPage> addPageFromSubmission({
    required WikiPageType selectedType,
    required WikiCreateSubmission draft,
  }) async {
    final flow = WikiCreateSubmitFlow(storage: _storage, target: this);
    return flow.submit(selectedType: selectedType, draft: draft);
  }

  void selectPage(WikiPage? page) {
    _selectedPage = page;
    notifyListeners();
  }

  @override
  void onPageCreated(WikiPage page) {
    _pages.add(page);
    _selectedPage = page;
    notifyListeners();
  }

  @override
  void onCreateComplete() {
    _isCreating = false;
    _pendingType = null;
    notifyListeners();
  }
}
