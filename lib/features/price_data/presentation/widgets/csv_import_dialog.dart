import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../application/price_data_notifier.dart';

class CsvImportDialog extends ConsumerStatefulWidget {
  final String instrumentId;
  final String instrumentName;

  const CsvImportDialog({
    super.key,
    required this.instrumentId,
    required this.instrumentName,
  });

  @override
  ConsumerState<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends ConsumerState<CsvImportDialog> {
  bool _loading = false;
  String? _message;

  Future<void> _pickAndImport() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        setState(() {
          _loading = false;
          _message = 'ファイルを読み込めませんでした';
        });
        return;
      }

      final csvContent = String.fromCharCodes(bytes);
      final count = await ref
          .read(priceDataNotifierProvider.notifier)
          .importCsv(widget.instrumentId, csvContent);

      setState(() {
        _loading = false;
        _message = '$count 行をインポートしました';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _message = 'エラー: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('CSVインポート - ${widget.instrumentName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CSV形式: date,open,high,low,close,volume'),
          const Text('日付形式: YYYY-MM-DD'),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_message != null) Text(_message!, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
        FilledButton(
          onPressed: _loading ? null : _pickAndImport,
          child: const Text('ファイルを選択'),
        ),
      ],
    );
  }
}
