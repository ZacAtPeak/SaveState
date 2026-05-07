import 'package:flutter/material.dart';
import 'package:companion_app/widgets/generic_tab_view.dart';

void main() {
  runApp(const CompanionApp());
}

class CompanionApp extends StatelessWidget {
  const CompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveState Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GenericTabView(
        tabs: [
          TabData(
            label: 'Characters',
            icon: const Icon(Icons.people),
            content: const Center(child: Text('Characters Screen')),
          ),
          TabData(
            label: 'Inventory',
            icon: const Icon(Icons.inventory),
            content: const Center(child: Text('Inventory Screen')),
          ),
          TabData(
            label: 'Spells',
            icon: const Icon(Icons.auto_awesome),
            content: const Center(child: Text('Spells Screen')),
          ),
        ],
      ),
    );
  }
}
