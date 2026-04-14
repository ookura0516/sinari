import 'package:flutter/material.dart';
import '../models/scenario.dart';
import 'title_screen.dart';

/// エンディング画面
class EndingScreen extends StatefulWidget {
  final EndingData ending;
  final int finalSan;
  final int finalKarma;
  final int historyCount;

  const EndingScreen({
    super.key,
    required this.ending,
    required this.finalSan,
    required this.finalKarma,
    required this.historyCount,
  });

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF030308), Color(0xFF08050F)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),

                  // エンディングタイトル
                  Text(
                    widget.ending.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.ending.titleColor,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: widget.ending.titleColor.withValues(alpha: 0.6),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 区切り線
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: widget.ending.titleColor.withValues(alpha: 0.3),
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // エンディングテキスト
                  Text(
                    widget.ending.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB8A898),
                      height: 2.0,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 最終スタッツ
                  _StatsPanel(
                    finalSan: widget.finalSan,
                    finalKarma: widget.finalKarma,
                    historyCount: widget.historyCount,
                  ),

                  const Spacer(flex: 2),

                  // もう一度ボタン
                  _RetryButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const TitleScreen(),
                          transitionDuration: const Duration(milliseconds: 800),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                        ),
                        (_) => false,
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------
// 最終スタッツ表示パネル
// ----------------------------------------------------------------
class _StatsPanel extends StatelessWidget {
  final int finalSan;
  final int finalKarma;
  final int historyCount;

  const _StatsPanel({
    required this.finalSan,
    required this.finalKarma,
    required this.historyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2A1A40), width: 0.5),
        color: const Color(0xFF0A0515),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: '最終 SAN',
            value: '$finalSan',
            color: finalSan >= 40
                ? const Color(0xFF4FC3F7)
                : finalSan >= 25
                    ? const Color(0xFFFF9800)
                    : const Color(0xFFE53935),
          ),
          _StatDivider(),
          _StatItem(
            label: '因果ポイント',
            value: '$finalKarma',
            color: finalKarma >= 8
                ? const Color(0xFFFF6F00)
                : const Color(0xFF8B7D6B),
          ),
          _StatDivider(),
          _StatItem(
            label: '行動数',
            value: '$historyCount',
            color: const Color(0xFF6A5A7A),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6A5A4A),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      child: VerticalDivider(color: Color(0xFF2A1A40), width: 1),
    );
  }
}

// ----------------------------------------------------------------
// もう一度ボタン
// ----------------------------------------------------------------
class _RetryButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RetryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF4A3060),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            'もう一度プレイする',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9A8A7A),
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
