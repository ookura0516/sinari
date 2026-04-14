import 'package:flutter/material.dart';
import 'game_screen.dart';

/// タイトル画面
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
            colors: [
              Color(0xFF050510),
              Color(0xFF0A0520),
              Color(0xFF100A30),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // 装飾ライン
                  _buildDivider(),
                  const SizedBox(height: 24),
                  // タイトル
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Opacity(
                      opacity: _pulseAnimation.value,
                      child: child,
                    ),
                    child: Text(
                      '深淵の図書館',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4C5A9),
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF6A0DAD).withValues(alpha: 0.8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'クトゥルフ神話TRPG',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF8B7D6B),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'インタラクティブシナリオ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF6A5A4A),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const Spacer(flex: 3),
                  // 開始ボタン
                  _StartButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const GameScreen(),
                          transitionDuration: const Duration(milliseconds: 800),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                        ),
                      );
                    },
                  ),
                  const Spacer(flex: 2),
                  // 警告テキスト
                  Text(
                    'このゲームには恐怖・狂気を題材とした描写が含まれます',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF4A3A2A),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFF4A3060), thickness: 0.5),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '✦',
            style: TextStyle(color: Color(0xFF6A0DAD), fontSize: 12),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFF4A3060), thickness: 0.5),
        ),
      ],
    );
  }
}

class _StartButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _StartButton({required this.onPressed});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _glowAnimation;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => GestureDetector(
        onTapDown: (_) {
          setState(() => _hovering = true);
          _hoverController.forward();
        },
        onTapUp: (_) {
          setState(() => _hovering = false);
          _hoverController.reverse();
          widget.onPressed();
        },
        onTapCancel: () {
          setState(() => _hovering = false);
          _hoverController.reverse();
        },
        child: Container(
          width: 220,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.lerp(
                const Color(0xFF4A3060),
                const Color(0xFF9B30D0),
                _glowAnimation.value,
              )!,
              width: 1.5,
            ),
            color: Color.lerp(
              Colors.transparent,
              const Color(0xFF2A1040),
              _glowAnimation.value,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A0DAD)
                    .withValues(alpha: 0.3 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'ゲームを始める',
              style: TextStyle(
                color: Color(0xFFD4C5A9),
                fontSize: 16,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
