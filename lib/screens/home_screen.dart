import 'package:flutter/material.dart';
import '../widget/flexible_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialRowIndex = 0});

  /// ダイアログオープン時に自動スクロールする行（0始まり）
  final int initialRowIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 可変カラム：ここを書き換えれば列増減OK
  static const List<FlexibleColumn> headerContents = <FlexibleColumn>[
    FlexibleColumn(title: 'A', width: 60),
    FlexibleColumn(title: 'B', width: 140),
    FlexibleColumn(title: 'C', width: 60),
    FlexibleColumn(title: 'D', width: 140),
    FlexibleColumn(title: 'E', width: 60),
    FlexibleColumn(title: 'F', width: 140),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen (Flexible Table)')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FlexibleTable(
            rowCount: 100,
            headerContents: headerContents,
            leftHeader: FlexibleTable.headerCell(text: 'NUMBER', width: 120, height: 30),
            // ← 初期自動スクロール（0始まり）
            initialScrollToRow: widget.initialRowIndex,
            autoScrollDuration: const Duration(milliseconds: 450),

            // 左固定セル（行番号表示）
            buildLeftCell: (BuildContext context, int row) {
              return FlexibleTable.bodyCell(text: row.toString(), width: 120, height: 50);
            },

            // 右側セル（row, colIndex で内容を組み立て）
            buildCell: (BuildContext context, int row, int colIndex) {
              final String text = 'r$row c$colIndex';
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Colors.black54))),
                child: Text(text, style: const TextStyle(fontSize: 12)),
              );
            },
          ),
        ),
      ),
    );
  }
}
