/// プレイヤーの行動履歴の1エントリ
class HistoryEntry {
  final String text;
  final int sanAtTime;
  final int karmaAtTime;

  const HistoryEntry({
    required this.text,
    required this.sanAtTime,
    required this.karmaAtTime,
  });
}

/// ゲーム全体の状態を管理するクラス
class GameState {
  int sanValue;
  int karmaPoints;
  final List<HistoryEntry> history;
  String currentSceneId;
  final Map<String, bool> flags;

  GameState({
    this.sanValue = 100,
    this.karmaPoints = 0,
    List<HistoryEntry>? history,
    this.currentSceneId = 'start',
    Map<String, bool>? flags,
  })  : history = history ?? [],
        flags = flags ?? {};

  /// SAN値を変動させる（0〜100 にクランプ）
  void applySanChange(int delta) {
    sanValue = (sanValue + delta).clamp(0, 100);
  }

  /// 因果ポイントを加算する
  void addKarma(int points) {
    karmaPoints += points;
  }

  /// 行動履歴にエントリを追加する
  void addHistory(String text) {
    history.add(HistoryEntry(
      text: text,
      sanAtTime: sanValue,
      karmaAtTime: karmaPoints,
    ));
  }

  /// フラグをセットする
  void setFlag(String flag) {
    flags[flag] = true;
  }

  /// フラグが立っているか確認する
  bool hasFlag(String flag) => flags[flag] ?? false;

  /// 現在の状態からエンディング ID を決定する
  ///
  /// 優先順位: 隠しエンド > 因果エンド > 狂気エンド > 生還エンド
  String determineEnding() {
    if (hasFlag('found_secret') && hasFlag('read_deep') && sanValue >= 20) {
      return 'ending_secret';
    }
    if (karmaPoints >= 8 || hasFlag('complete_ritual')) {
      return 'ending_karma';
    }
    if (sanValue < 25) {
      return 'ending_mad';
    }
    return 'ending_sane';
  }
}
