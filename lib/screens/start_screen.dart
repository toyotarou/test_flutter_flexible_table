import 'package:flutter/material.dart';
import 'home_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController _indexController = TextEditingController(text: '0');

  @override
  void dispose() {
    _indexController.dispose();
    super.dispose();
  }

  void _openDialog() {
    final int idx = int.tryParse(_indexController.text.trim()) ?? 0;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: SizedBox(width: 900, height: 600, child: HomeScreen(initialRowIndex: idx)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('自動スクロールしたい行インデックス（0始まり）'),
            const SizedBox(height: 8),
            SizedBox(
              width: 240,
              child: TextField(
                controller: _indexController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '例: 25'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _openDialog, child: const Text('ダイアログで HomeScreen を開く')),
          ],
        ),
      ),
    );
  }
}
