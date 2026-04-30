import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/strategy.dart';

class StrategyListTile extends StatelessWidget {
  final Strategy strategy;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const StrategyListTile({
    super.key,
    required this.strategy,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy/MM/dd').format(strategy.createdAt);
    return ListTile(
      title: Text(strategy.name),
      subtitle: Text('${_entryLabel(strategy.entryCondition)} · $dateStr'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }

  String _entryLabel(EntryCondition c) {
    final typeNames = {
      ConditionType.percentDrop: '下落',
      ConditionType.percentRise: '上昇',
      ConditionType.crossAbove: '上抜け',
      ConditionType.crossBelow: '下抜け',
    };
    return '${typeNames[c.type]} ${c.value}%';
  }
}
