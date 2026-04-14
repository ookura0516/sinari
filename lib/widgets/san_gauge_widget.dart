import 'package:flutter/material.dart';

/// SAN 値（正気度）を視覚化するゲージウィジェット
///
/// - SAN > 50: 青系
/// - SAN 30〜50: オレンジ系
/// - SAN < 30: 赤系
/// - 変化時にアニメーションで滑らかに遷移する
class SanGaugeWidget extends StatelessWidget {
  final int sanValue;

  const SanGaugeWidget({super.key, required this.sanValue});

  /// SAN 値に応じたゲージの色を返す
  Color _gaugeColor(int san) {
    if (san > 70) return const Color(0xFF1E88E5);
    if (san > 50) return const Color(0xFF42A5F5);
    if (san > 40) return const Color(0xFFFFB300);
    if (san > 30) return const Color(0xFFF57C00);
    if (san > 15) return const Color(0xFFE53935);
    return const Color(0xFFB71C1C);
  }

  @override
  Widget build(BuildContext context) {
    final double fraction = sanValue / 100.0;
    final Color gaugeColor = _gaugeColor(sanValue);
    final String sanLabel = sanValue > 50
        ? '正気度'
        : sanValue >= 30
            ? '不安定'
            : '危険';

    return Row(
      children: [
        // ラベル
        SizedBox(
          width: 42,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sanLabel,
                style: TextStyle(
                  fontSize: 9,
                  color: gaugeColor.withValues(alpha: 0.8),
                  letterSpacing: 1,
                ),
              ),
              Text(
                'SAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: gaugeColor,
                ),
              ),
            ],
          ),
        ),

        // ゲージバー
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // パーセンテージ表示
              Text(
                '$sanValue%',
                style: TextStyle(
                  fontSize: 11,
                  color: gaugeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              // バー本体
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: fraction),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (_, value, __) {
                  return Stack(
                    children: [
                      // 背景トラック
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A0A2E),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // フォアグラウンドバー
                      FractionallySizedBox(
                        widthFactor: value.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: gaugeColor,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: gaugeColor.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
