import 'dart:math' as math;
import 'package:flutter/material.dart';

/// SAN 値と背景レベルに応じて動的に変化する背景ウィジェット
///
/// SAN 値による変化:
///   - SAN > 50: 暗い青系グラデーション（通常）
///   - SAN 30〜50: 暗く、薄暗い茶色/紫系
///   - SAN < 30: ほぼ漆黒、アニメーション付きで歪んだ影が漂う
///
/// backgroundLevel による追加演出:
///   - 0〜1: 変化なし
///   - 2〜3: 画面端にヴィネットを追加
class BackgroundWidget extends StatefulWidget {
  final int sanValue;
  final int backgroundLevel;

  const BackgroundWidget({
    super.key,
    required this.sanValue,
    required this.backgroundLevel,
  });

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _driftController;
  late Animation<double> _driftAnimation;

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _driftAnimation = CurvedAnimation(
      parent: _driftController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  List<Color> _gradientColors() {
    if (widget.sanValue > 50) {
      return const [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF080518)];
    } else if (widget.sanValue >= 30) {
      return const [Color(0xFF080508), Color(0xFF120808), Color(0xFF0A0510)];
    } else {
      return const [Color(0xFF030303), Color(0xFF0A0303), Color(0xFF050206)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors();
    final showShadows =
        widget.sanValue < 30 || widget.backgroundLevel >= 2;
    final showVignette = widget.backgroundLevel >= 2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          // ヴィネット（画面端の暗化）
          if (showVignette)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),

          // SAN < 30: 漂う不気味な影
          if (showShadows)
            AnimatedBuilder(
              animation: _driftAnimation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ShadowPainter(
                    progress: _driftAnimation.value,
                    sanValue: widget.sanValue,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// SAN が低いときに漂う不気味な影を描画する CustomPainter
class _ShadowPainter extends CustomPainter {
  final double progress;
  final int sanValue;

  _ShadowPainter({required this.progress, required this.sanValue});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = sanValue < 30 ? 0.25 : 0.10;
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    // 複数の影をサイン波で揺らして配置
    final positions = [
      Offset(
        size.width * (0.1 + 0.2 * math.sin(progress * 2 * math.pi)),
        size.height * (0.1 + 0.15 * math.cos(progress * 2 * math.pi)),
      ),
      Offset(
        size.width * (0.8 - 0.15 * math.sin(progress * 2 * math.pi + 1.0)),
        size.height * (0.7 + 0.1 * math.cos(progress * 2 * math.pi + 0.5)),
      ),
      Offset(
        size.width * (0.5 + 0.25 * math.sin(progress * 2 * math.pi + 2.0)),
        size.height * (0.4 - 0.2 * math.cos(progress * 2 * math.pi + 1.5)),
      ),
    ];

    for (final pos in positions) {
      canvas.drawCircle(pos, 60, paint);
    }
  }

  @override
  bool shouldRepaint(_ShadowPainter old) =>
      old.progress != progress || old.sanValue != sanValue;
}
