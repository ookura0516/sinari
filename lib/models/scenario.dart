import 'package:flutter/material.dart';

/// 1つの選択肢を表す
class Choice {
  final String id;

  /// SAN値 > 50 のとき表示される通常テキスト
  final String normalText;

  /// SAN値 30〜50 のとき表示される抽象的テキスト
  final String abstractText;

  /// SAN値 < 30 のとき表示される歪んだテキスト
  final String garbledText;

  /// 選択時の SAN 変動量（負 = 減少）
  final int sanChange;

  /// 選択時の因果ポイント変動量
  final int karmaChange;

  /// この選択後に移動するシーン ID。'__ending__' の場合はエンディング判定へ
  final String nextSceneId;

  /// このフラグが立っていない場合、選択肢はロック状態になる
  final String? requiredFlag;

  /// 選択時にセットするフラグ
  final String? setsFlag;

  /// 行動履歴に記録するテキスト
  final String historyText;

  const Choice({
    required this.id,
    required this.normalText,
    required this.abstractText,
    required this.garbledText,
    required this.sanChange,
    required this.karmaChange,
    required this.nextSceneId,
    this.requiredFlag,
    this.setsFlag,
    required this.historyText,
  });

  /// 現在の SAN 値に応じた表示テキストを返す
  String displayText(int sanValue) {
    if (sanValue > 50) return normalText;
    if (sanValue >= 30) return abstractText;
    return garbledText;
  }
}

/// 1つのシーンを表す
class Scene {
  final String id;

  /// シーンのナレーションテキスト
  final String text;

  /// 背景の不気味さレベル (0=通常, 1=薄暗い, 2=暗い, 3=歪み)
  final int backgroundLevel;

  final List<Choice> choices;

  const Scene({
    required this.id,
    required this.text,
    required this.backgroundLevel,
    required this.choices,
  });
}

/// エンディングデータ
class EndingData {
  final String id;
  final String title;
  final String text;
  final Color titleColor;

  const EndingData({
    required this.id,
    required this.title,
    required this.text,
    required this.titleColor,
  });
}

/// シナリオ全体のデータ（差し替え可能）
class ScenarioData {
  final String title;
  final String subtitle;
  final List<Scene> scenes;
  final List<EndingData> endings;

  const ScenarioData({
    required this.title,
    required this.subtitle,
    required this.scenes,
    required this.endings,
  });

  Scene? findScene(String id) {
    try {
      return scenes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  EndingData? findEnding(String id) {
    try {
      return endings.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
