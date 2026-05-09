import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveState',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _entities = [];
  bool _isLoading = true;

  Future<void> _loadEntities() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = '${appDir.path}/MainDatabase.db';

    final db = await openDatabase(dbPath);
    final result = await db.rawQuery('SELECT name FROM entities');

    setState(() {
      _entities = result.map((row) => row['name'] as String).toList();
      _isLoading = false;
    });

    await db.close();
  }

  Future<void> _factoryReset() async {
    final appDir = await getApplicationDocumentsDirectory();
    final mainDb = File('${appDir.path}/MainDatabase.db');

    if (await mainDb.exists()) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            'MainDatabase.db already exists. This will delete the existing database and replace it with a fresh copy. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await mainDb.delete();
    }

    final dbData =
        await DefaultAssetBundle.of(context).load('assets/demo-UTS.db');
    await mainDb.writeAsBytes(dbData.buffer.asUint8List());

    await _loadEntities();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Factory reset complete')),
      );
    }
  }

  void _showWikiModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8 * (1 / 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Entities',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _entities.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(_entities[index]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Center(
                  child: Text(
                    'Detail Here',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('SaveState'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _factoryReset,
            tooltip: 'Factory Reset',
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () => _showWikiModal(context),
            tooltip: 'Wiki',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _entities.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_entities[index]),
              ),
            ),
    );
  }
}