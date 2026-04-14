import 'package:flutter/material.dart';
import '../models/scenario.dart';

/// 選択肢ボタン
///
/// SAN 値に応じてテキスト表示が変化する:
///   - SAN > 50: 通常テキスト
///   - SAN 30〜50: 抽象的・不安を感じさせるテキスト
///   - SAN < 30: 歪んだ・意味不明なテキスト
///
/// [isLocked] が true の場合は「???」と表示され操作不能になる。
class ChoiceButton extends StatefulWidget {
  final Choice choice;
  final int sanValue;
  final bool isLocked;
  final VoidCallback? onPressed;

  const ChoiceButton({
    super.key,
    required this.choice,
    required this.sanValue,
    required this.isLocked,
    this.onPressed,
  });

  @override
  State<ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Color _borderColor() {
    if (widget.isLocked) return const Color(0xFF1A1020);
    if (widget.onPressed == null) return const Color(0xFF1A1020);
    if (widget.sanValue < 30) return const Color(0xFF6A1020);
    if (widget.sanValue < 50) return const Color(0xFF4A3020);
    return const Color(0xFF3A2060);
  }

  Color _textColor() {
    if (widget.isLocked) return const Color(0xFF3A2A1A);
    if (widget.sanValue < 30) return const Color(0xFFB08070);
    if (widget.sanValue < 50) return const Color(0xFFA09060);
    return const Color(0xFFC0B090);
  }

  Color _bgColor() {
    if (widget.isLocked) return const Color(0xFF080510);
    if (widget.sanValue < 30) {
      return const Color(0xFF150808);
    }
    return const Color(0xFF0A0818);
  }

  String _displayText() {
    if (widget.isLocked) return '??? — 解除条件を満たしていない';
    return widget.choice.displayText(widget.sanValue);
  }

  // SAN 変動を示すヒントカラーとテキスト
  Color _hintColor() {
    final delta = widget.choice.sanChange;
    if (delta < -10) return const Color(0xFFE53935).withValues(alpha: 0.7);
    if (delta < 0) return const Color(0xFFFF9800).withValues(alpha: 0.7);
    return Colors.transparent;
  }

  Widget? _buildHint() {
    if (widget.isLocked || widget.sanValue <= 30) return null;
    final delta = widget.choice.sanChange;
    if (delta == 0) return null;
    final text = delta < 0 ? 'SAN $delta' : 'SAN +$delta';
    return Text(
      text,
      style: TextStyle(fontSize: 10, color: _hintColor()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = !widget.isLocked && widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled
          ? (_) => _pressController.forward()
          : null,
      onTapUp: isEnabled
          ? (_) {
              _pressController.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled
          ? () => _pressController.reverse()
          : null,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (_, child) => Transform.scale(
          scale: _pressAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: _bgColor(),
            border: Border.all(color: _borderColor(), width: 1),
            boxShadow: isEnabled && widget.sanValue < 30
                ? [
                    BoxShadow(
                      color: const Color(0xFF6A0000).withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // 選択肢インジケーター
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  widget.isLocked ? '✕' : '▶',
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isLocked
                        ? const Color(0xFF2A1A0A)
                        : _borderColor(),
                  ),
                ),
              ),

              // 選択肢テキスト
              Expanded(
                child: Text(
                  _displayText(),
                  style: TextStyle(
                    fontSize: 14,
                    color: _textColor(),
                    height: 1.5,
                    letterSpacing: widget.sanValue < 30 ? 0.5 : 0.3,
                  ),
                ),
              ),

              // SAN 変動ヒント（SAN > 30 のときのみ表示）
              Builder(
                builder: (_) {
                  final hint = _buildHint();
                  if (hint == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: hint,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
