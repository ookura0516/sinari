import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/strategy_notifier.dart';
import '../domain/entities/strategy.dart';

class StrategyFormScreen extends ConsumerStatefulWidget {
  static const routeName = '/strategy/form';

  final Strategy? strategy;

  const StrategyFormScreen({super.key, this.strategy});

  @override
  ConsumerState<StrategyFormScreen> createState() => _StrategyFormScreenState();
}

class _StrategyFormScreenState extends ConsumerState<StrategyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _entryValueCtrl;
  late final TextEditingController _tpValueCtrl;
  late final TextEditingController _slValueCtrl;
  late final TextEditingController _capitalCtrl;
  late final TextEditingController _positionSizeCtrl;

  late ConditionType _entryType;
  late ExitType _tpType;
  late ExitType _slType;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.strategy;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _entryType = s?.entryCondition.type ?? ConditionType.percentDrop;
    _entryValueCtrl = TextEditingController(text: s?.entryCondition.value.toString() ?? '5.0');
    _tpType = s?.takeProfitCondition.type ?? ExitType.percentGain;
    _tpValueCtrl = TextEditingController(text: s?.takeProfitCondition.value.toString() ?? '10.0');
    _slType = s?.stopLossCondition.type ?? ExitType.percentLoss;
    _slValueCtrl = TextEditingController(text: s?.stopLossCondition.value.toString() ?? '5.0');
    _capitalCtrl = TextEditingController(text: s?.initialCapital.toString() ?? '1000000');
    _positionSizeCtrl = TextEditingController(text: s?.positionSizePercent.toString() ?? '10.0');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _entryValueCtrl.dispose();
    _tpValueCtrl.dispose();
    _slValueCtrl.dispose();
    _capitalCtrl.dispose();
    _positionSizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(strategyNotifierProvider.notifier).save(
            id: widget.strategy?.id,
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            entryCondition: EntryCondition(
              type: _entryType,
              value: double.parse(_entryValueCtrl.text),
            ),
            takeProfitCondition: ExitCondition(
              type: _tpType,
              value: double.parse(_tpValueCtrl.text),
            ),
            stopLossCondition: ExitCondition(
              type: _slType,
              value: double.parse(_slValueCtrl.text),
            ),
            initialCapital: double.parse(_capitalCtrl.text),
            positionSizePercent: double.parse(_positionSizeCtrl.text),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.strategy != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '戦略を編集' : '新しい戦略')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: '戦略名'),
              validator: (v) => v == null || v.trim().isEmpty ? '戦略名を入力してください' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: '説明'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            _sectionHeader('エントリー条件'),
            Row(children: [
              Expanded(child: _conditionTypeDropdown()),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _entryValueCtrl,
                  decoration: const InputDecoration(labelText: '値'),
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _sectionHeader('利確条件'),
            Row(children: [
              Expanded(child: _exitTypeDropdown(_tpType, (v) => setState(() => _tpType = v!))),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _tpValueCtrl,
                  decoration: const InputDecoration(labelText: '値'),
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _sectionHeader('損切り条件'),
            Row(children: [
              Expanded(child: _exitTypeDropdown(_slType, (v) => setState(() => _slType = v!))),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _slValueCtrl,
                  decoration: const InputDecoration(labelText: '値'),
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _sectionHeader('資金管理'),
            TextFormField(
              controller: _capitalCtrl,
              decoration: const InputDecoration(labelText: '初期資金', suffixText: '円'),
              keyboardType: TextInputType.number,
              validator: _numberValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _positionSizeCtrl,
              decoration: const InputDecoration(labelText: 'ポジションサイズ', suffixText: '%'),
              keyboardType: TextInputType.number,
              validator: _numberValidator,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? '更新' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );

  Widget _conditionTypeDropdown() => DropdownButtonFormField<ConditionType>(
        value: _entryType,
        decoration: const InputDecoration(labelText: '条件タイプ'),
        items: ConditionType.values
            .map((t) => DropdownMenuItem(value: t, child: Text(_conditionTypeName(t))))
            .toList(),
        onChanged: (v) => setState(() => _entryType = v!),
      );

  Widget _exitTypeDropdown(ExitType value, void Function(ExitType?) onChanged) =>
      DropdownButtonFormField<ExitType>(
        value: value,
        decoration: const InputDecoration(labelText: '条件タイプ'),
        items: ExitType.values
            .map((t) => DropdownMenuItem(value: t, child: Text(_exitTypeName(t))))
            .toList(),
        onChanged: onChanged,
      );

  String _conditionTypeName(ConditionType t) {
    switch (t) {
      case ConditionType.percentDrop:
        return '下落%';
      case ConditionType.percentRise:
        return '上昇%';
      case ConditionType.crossAbove:
        return '上抜け';
      case ConditionType.crossBelow:
        return '下抜け';
    }
  }

  String _exitTypeName(ExitType t) {
    switch (t) {
      case ExitType.percentGain:
        return '利益%';
      case ExitType.percentLoss:
        return '損失%';
      case ExitType.holdingDays:
        return '保有日数';
    }
  }

  String? _numberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '値を入力してください';
    if (double.tryParse(v.trim()) == null) return '数値を入力してください';
    return null;
  }
}
