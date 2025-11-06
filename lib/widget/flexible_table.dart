import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlexibleColumn {
  const FlexibleColumn({required this.title, required this.width});

  final String title;
  final double width;
}

class FlexibleTable extends StatefulWidget {
  const FlexibleTable({
    super.key,
    required this.rowCount,
    required this.headerContents,
    required this.buildLeftCell,
    required this.buildCell,
    this.leftColumnWidth = 120,
    this.leftHeader,
    this.headerHeight = 30,
    this.rowHeight = 50,
    this.headerDecoration = const BoxDecoration(
      color: Color(0xFFF7F7F7),
      border: Border.fromBorderSide(BorderSide(color: Colors.black54)),
    ),
    this.bodyCellDecoration = const BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Colors.black54))),
    this.initialScrollToRow,
    this.autoScrollDuration = const Duration(milliseconds: 400),
  });

  /// 行数
  final int rowCount;

  /// 列定義（可変）
  final List<FlexibleColumn> headerContents;

  /// 左固定列の幅
  final double leftColumnWidth;

  /// 左上ヘッダーのカスタム（null の場合は空枠）
  final Widget? leftHeader;

  /// ヘッダーの高さ
  final double headerHeight;

  /// 行の高さ
  final double rowHeight;

  /// ヘッダーセルのデコレーション
  final BoxDecoration headerDecoration;

  /// ボディセルのデコレーション
  final BoxDecoration bodyCellDecoration;

  /// 左固定列のセル
  final Widget Function(BuildContext context, int rowIndex) buildLeftCell;

  /// 右側の1セル（row, colIndex）
  final Widget Function(BuildContext context, int rowIndex, int colIndex) buildCell;

  /// 初期スクロール対象の行（0始まり）。null の場合はスクロールしない
  final int? initialScrollToRow;

  /// 自動スクロールのアニメ時間
  final Duration autoScrollDuration;

  @override
  State<FlexibleTable> createState() => _FlexibleTableState();

  // ヘッダー/ボディの簡易セル
  static Widget headerCell({
    required String text,
    required double width,
    required double height,
    BoxDecoration decoration = const BoxDecoration(
      color: Color(0xFFF7F7F7),
      border: Border.fromBorderSide(BorderSide(color: Colors.black54)),
    ),
    TextStyle textStyle = const TextStyle(fontWeight: FontWeight.w700),
    Alignment alignment = Alignment.centerLeft,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 10),
  }) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: decoration,
      child: Text(text, style: textStyle),
    );
  }

  static Widget bodyCell({
    required String text,
    required double width,
    required double height,
    BoxDecoration decoration = const BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Colors.black54))),
    Alignment alignment = Alignment.centerLeft,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    TextStyle? textStyle,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: decoration,
      child: Text(text, style: textStyle),
    );
  }
}

class _FlexibleTableState extends State<FlexibleTable> {
  late final ScrollController _verticalScrollController;
  late final ScrollController _headerHorizontalScrollController;
  late final ScrollController _bodyHorizontalScrollController;

  bool _syncing = false;
  bool _didAutoScroll = false;

  late final VoidCallback _fromHeaderListener;
  late final VoidCallback _fromBodyListener;

  double get _rightMinWidth => widget.headerContents.fold<double>(0, (double acc, FlexibleColumn c) => acc + c.width);

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _headerHorizontalScrollController = ScrollController();
    _bodyHorizontalScrollController = ScrollController();

    _fromHeaderListener = () {
      if (_syncing) {
        return;
      }
      _syncing = true;
      if (_bodyHorizontalScrollController.hasClients) {
        _bodyHorizontalScrollController.jumpTo(_headerHorizontalScrollController.offset);
      }
      _syncing = false;
    };

    _fromBodyListener = () {
      if (_syncing) {
        return;
      }
      _syncing = true;
      if (_headerHorizontalScrollController.hasClients) {
        _headerHorizontalScrollController.jumpTo(_bodyHorizontalScrollController.offset);
      }
      _syncing = false;
    };

    _headerHorizontalScrollController.addListener(_fromHeaderListener);
    _bodyHorizontalScrollController.addListener(_fromBodyListener);
  }

  @override
  void dispose() {
    _headerHorizontalScrollController.removeListener(_fromHeaderListener);
    _bodyHorizontalScrollController.removeListener(_fromBodyListener);
    _verticalScrollController.dispose();
    _headerHorizontalScrollController.dispose();
    _bodyHorizontalScrollController.dispose();
    super.dispose();
  }

  void _scheduleInitialScrollIfNeeded() {
    if (_didAutoScroll) {
      return;
    }
    final int? targetRow = widget.initialScrollToRow;
    if (targetRow == null) {
      return;
    }
    if (!_verticalScrollController.hasClients) {
      return;
    }

    final double rawOffset = widget.rowHeight * targetRow.toDouble();
    final double max = _verticalScrollController.position.maxScrollExtent;
    final double target = rawOffset.clamp(0.0, max);

    _didAutoScroll = true;
    _verticalScrollController.animateTo(target, duration: widget.autoScrollDuration, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double rightContentWidth = math.max(_rightMinWidth, constraints.maxWidth - widget.leftColumnWidth - 2);

        final Material header = Material(
          elevation: 2,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: widget.leftColumnWidth,
                height: widget.headerHeight,
                child:
                    widget.leftHeader ??
                    Container(
                      decoration: widget.headerDecoration,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: SingleChildScrollView(
                  controller: _headerHorizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: rightContentWidth),
                    child: SizedBox(
                      height: widget.headerHeight,
                      child: Row(
                        // ignore: always_specify_types
                        children: List.generate(widget.headerContents.length, (int i) {
                          final FlexibleColumn col = widget.headerContents[i];
                          return FlexibleTable.headerCell(
                            text: col.title,
                            width: col.width,
                            height: widget.headerHeight,
                            decoration: widget.headerDecoration,
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        final SingleChildScrollView body = SingleChildScrollView(
          controller: _verticalScrollController,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                // ignore: always_specify_types
                children: List.generate(widget.rowCount, (int row) {
                  return SizedBox(
                    width: widget.leftColumnWidth,
                    height: widget.rowHeight,
                    child: widget.buildLeftCell(context, row),
                  );
                }),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: SingleChildScrollView(
                  controller: _bodyHorizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: rightContentWidth),
                    child: Column(
                      // ignore: always_specify_types
                      children: List.generate(widget.rowCount, (int row) {
                        return Row(
                          // ignore: always_specify_types
                          children: List.generate(widget.headerContents.length, (int colIdx) {
                            return SizedBox(
                              width: widget.headerContents[colIdx].width,
                              height: widget.rowHeight,
                              child: widget.buildCell(context, row, colIdx),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        // 初期スクロール（ビルド完了後に実行）
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scheduleInitialScrollIfNeeded();
        });

        return Column(
          children: <Widget>[
            header,
            const SizedBox(height: 2),
            Expanded(
              child: Scrollbar(controller: _verticalScrollController, thumbVisibility: true, child: body),
            ),
          ],
        );
      },
    );
  }
}
