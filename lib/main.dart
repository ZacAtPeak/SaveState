import 'package:flutter/material.dart';
import 'data/app_settings.dart';
import 'data/database.dart';
import 'data/uts_db_loader.dart';
import 'ui/layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize app settings
  await appSettings.initialize();

  // Load demo data on first launch
  await UtsDbLoader.loadDemoData();

  runApp(const DMApp());
}

class DMApp extends StatelessWidget {
  const DMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DM Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}
