import 'package:flutter/material.dart';

import '../../domain/entities/instrument.dart';

class InstrumentListTile extends StatelessWidget {
  final Instrument instrument;
  final int barCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const InstrumentListTile({
    super.key,
    required this.instrument,
    required this.barCount,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _typeIcon(instrument.type),
      title: Text(instrument.symbol),
      subtitle: Text('${instrument.name} · $barCount bars'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }

  Widget _typeIcon(String type) {
    final icons = {
      'stock': Icons.trending_up,
      'fx': Icons.currency_exchange,
      'crypto': Icons.currency_bitcoin,
      'index': Icons.bar_chart,
      'commodity': Icons.oil_barrel,
    };
    return Icon(icons[type] ?? Icons.show_chart);
  }
}
