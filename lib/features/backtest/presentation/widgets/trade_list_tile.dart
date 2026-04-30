import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trade.dart';
import '../../../../core/utils/number_formatter.dart';

class TradeListTile extends StatelessWidget {
  final Trade trade;
  final int index;

  const TradeListTile({super.key, required this.trade, required this.index});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy/MM/dd');
    final entryDate = dateFmt.format(trade.entryDate);
    final exitDate = trade.exitDate != null ? dateFmt.format(trade.exitDate!) : '-';
    final pl = trade.profitLoss;
    final plPct = trade.profitLossPercent;

    Color resultColor = Colors.grey;
    if (trade.result == TradeResult.win) resultColor = Colors.green;
    if (trade.result == TradeResult.loss) resultColor = Colors.red;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: resultColor.withOpacity(0.2),
        child: Text('${index + 1}', style: TextStyle(color: resultColor, fontSize: 12)),
      ),
      title: Text('エントリー: $entryDate @ ${NumberFormatter.currency(trade.entryPrice)}'),
      subtitle: Text('イグジット: $exitDate @ ${trade.exitPrice != null ? NumberFormatter.currency(trade.exitPrice!) : '-'}'),
      trailing: pl != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(NumberFormatter.currency(pl),
                    style: TextStyle(color: resultColor, fontWeight: FontWeight.bold)),
                if (plPct != null)
                  Text(NumberFormatter.percent(plPct),
                      style: TextStyle(color: resultColor, fontSize: 12)),
              ],
            )
          : null,
    );
  }
}
