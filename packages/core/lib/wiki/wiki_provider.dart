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
  bool _migrationAttempted = false;
  bool _isDisposed = false;
  bool _isCreating = false;
  String? _pendingEntityKey;

  @override
  List<WikiPage> get pages => List.unmodifiable(_pages);

  @override
  WikiPage? get selectedPage => _selectedPage;

  @override
  bool get isCreating => _isCreating;

  @override
  String? get pendingEntityKey => _pendingEntityKey;

  @override
  @Deprecated('Use pendingEntityKey instead')
  WikiPageType? get pendingType => null;

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
    await runStartupMigration();
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
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> runStartupMigration() async {
    if (_migrationAttempted) return;
    _migrationAttempted = true;
    try {
      final result = await _storage.runStartupMigration();
      if (result.warningCount > 0) {
        debugPrint(
          'Wiki migration warnings: ${result.warningCount} '
          '(migrated: ${result.migratedCount})',
        );
      }
    } catch (error) {
      debugPrint('Wiki migration failed non-blocking: $error');
    }
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
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void onPageCreated(WikiPage page) {
    _pages.add(page);
    _selectedPage = page;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void onCreateComplete() {
    _isCreating = false;
    _pendingEntityKey = null;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
