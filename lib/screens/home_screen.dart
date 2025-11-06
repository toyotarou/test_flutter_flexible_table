import 'package:flutter/material.dart';

import '../widget/flexible_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // static const List<FlexibleColumn> headerContents4 = <FlexibleColumn>[
  //   FlexibleColumn(title: 'AAA', width: 60),
  //   FlexibleColumn(title: 'BBB', width: 140),
  //   FlexibleColumn(title: 'CCC', width: 60),
  //   FlexibleColumn(title: 'DDD', width: 140),
  // ];
  //
  //
  //

  static const List<FlexibleColumn> headerContents6 = <FlexibleColumn>[
    FlexibleColumn(title: 'A', width: 60),
    FlexibleColumn(title: 'B', width: 140),
    FlexibleColumn(title: 'C', width: 60),
    FlexibleColumn(title: 'D', width: 140),
    FlexibleColumn(title: 'E', width: 60),
    FlexibleColumn(title: 'F', width: 140),
  ];

  ///
  @override
  Widget build(BuildContext context) {
    const List<FlexibleColumn> headerContents = headerContents6;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          //----------------------
          child: FlexibleTable(
            rowCount: 100,

            ///
            headerContents: headerContents,

            ///
            leftHeader: FlexibleTable.headerCell(text: 'NUMBER', width: 120, height: 30),

            ///
            buildLeftCell: (BuildContext context, int row) {
              return FlexibleTable.bodyCell(text: row.toString(), width: 120, height: 50);
            },

            ///
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

          //----------------------
        ),
      ),
    );
  }
}
