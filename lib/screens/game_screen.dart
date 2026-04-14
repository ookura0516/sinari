import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/scenario.dart';
import '../data/scenario_data.dart';
import '../widgets/san_gauge_widget.dart';
import '../widgets/background_widget.dart';
import '../widgets/choice_button.dart';
import 'ending_screen.dart';
import 'history_screen.dart';

/// メインゲーム画面
///
/// SAN ゲージ・シーンテキスト・選択肢を表示し、ゲーム状態を管理する。
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late GameState _gameState;
  late ScenarioData _scenario;
  Scene? _currentScene;

  // シーンテキストのフェードアニメーション
  late AnimationController _textFadeController;
  late Animation<double> _textFadeAnimation;

  // SAN 低下時の画面ゆがみアニメーション
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // SAN < 30 時の赤オーバーレイパルス
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _scenario = defaultScenario;
    _gameState = GameState();
    _currentScene = _scenario.findScene(_gameState.currentSceneId);

    _textFadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _textFadeAnimation = CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeIn,
    );
    _textFadeController.forward();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 0.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _textFadeController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onChoiceSelected(Choice choice) {
    if (_isTransitioning) return;

    setState(() {
      _isTransitioning = true;

      // フラグのセット
      if (choice.setsFlag != null) {
        _gameState.setFlag(choice.setsFlag!);
      }

      // SAN 変動
      _gameState.applySanChange(choice.sanChange);

      // 因果変動
      _gameState.addKarma(choice.karmaChange);

      // 履歴追加
      _gameState.addHistory(choice.historyText);
    });

    // SAN < 30 の場合にゆがみアニメーション再生
    if (_gameState.sanValue < 30) {
      _shakeController.forward(from: 0).then((_) {
        _shakeController.reverse();
      });
    }

    // シーン遷移
    _textFadeController.reverse().then((_) {
      if (!mounted) return;
      if (choice.nextSceneId == '__ending__') {
        _goToEnding();
      } else {
        setState(() {
          _gameState.currentSceneId = choice.nextSceneId;
          _currentScene = _scenario.findScene(choice.nextSceneId);
          _isTransitioning = false;
        });
        _textFadeController.forward();
      }
    });
  }

  void _goToEnding() {
    final endingId = _gameState.determineEnding();
    final ending = _scenario.findEnding(endingId);
    if (ending == null) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => EndingScreen(
          ending: ending,
          finalSan: _gameState.sanValue,
          finalKarma: _gameState.karmaPoints,
          historyCount: _gameState.history.length,
        ),
        transitionDuration: const Duration(milliseconds: 1200),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryScreen(history: List.unmodifiable(_gameState.history)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentScene == null) {
      return const Scaffold(
        body: Center(child: Text('シーンが見つかりません')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 背景レイヤー
          BackgroundWidget(
            sanValue: _gameState.sanValue,
            backgroundLevel: _currentScene!.backgroundLevel,
          ),

          // SAN < 30 の赤パルスオーバーレイ
          if (_gameState.sanValue < 30)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Container(
                color: Colors.red.withValues(alpha: _pulseAnimation.value),
              ),
            ),

          // メインコンテンツ（ゆがみエフェクト付き）
          SafeArea(
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (_, child) => Transform.translate(
                offset: _gameState.sanValue < 30
                    ? Offset(_shakeAnimation.value, 0)
                    : Offset.zero,
                child: child,
              ),
              child: Column(
                children: [
                  // SAN ゲージ
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SanGaugeWidget(sanValue: _gameState.sanValue),
                        ),
                        const SizedBox(width: 8),
                        // 因果ポイント表示
                        _KarmaDisplay(karmaPoints: _gameState.karmaPoints),
                        const SizedBox(width: 8),
                        // 履歴ボタン
                        IconButton(
                          onPressed: _openHistory,
                          icon: const Icon(Icons.history),
                          color: const Color(0xFF8B7D6B),
                          tooltip: '行動履歴',
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  const Divider(color: Color(0xFF2A1040), thickness: 0.5),

                  // シーンテキスト
                  Expanded(
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                        child: _SceneText(
                          text: _currentScene!.text,
                          sanValue: _gameState.sanValue,
                        ),
                      ),
                    ),
                  ),

                  // 選択肢
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(
                            color: Color(0xFF2A1040),
                            thickness: 0.5,
                          ),
                          const SizedBox(height: 8),
                          ..._currentScene!.choices.map((choice) {
                            final locked = choice.requiredFlag != null &&
                                !_gameState.hasFlag(choice.requiredFlag!);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ChoiceButton(
                                choice: choice,
                                sanValue: _gameState.sanValue,
                                isLocked: locked,
                                onPressed: _isTransitioning
                                    ? null
                                    : () => _onChoiceSelected(choice),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------
// 因果ポイント表示ウィジェット
// ----------------------------------------------------------------
class _KarmaDisplay extends StatelessWidget {
  final int karmaPoints;
  const _KarmaDisplay({required this.karmaPoints});

  @override
  Widget build(BuildContext context) {
    final color = karmaPoints >= 8
        ? const Color(0xFFFF6F00)
        : karmaPoints >= 4
            ? const Color(0xFFFFB74D)
            : const Color(0xFF6A5A4A);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '因果',
          style: TextStyle(
            fontSize: 9,
            color: color,
            letterSpacing: 1,
          ),
        ),
        Text(
          '$karmaPoints',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------
// シーンテキストウィジェット（SAN 値による色変化あり）
// ----------------------------------------------------------------
class _SceneText extends StatelessWidget {
  final String text;
  final int sanValue;
  const _SceneText({required this.text, required this.sanValue});

  @override
  Widget build(BuildContext context) {
    final textColor = sanValue > 50
        ? const Color(0xFFD4C5A9)
        : sanValue >= 30
            ? const Color(0xFFB8A090)
            : const Color(0xFF9A7060);

    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: textColor,
        height: 1.9,
        letterSpacing: 0.5,
      ),
    );
  }
}
