import 'package:flutter/material.dart';
import '../models/scenario.dart';

// ============================================================
// シナリオデータ: 「深淵の図書館」
//
// このファイルを書き換えることでシナリオ全体を差し替えられます。
// - ScenarioData の title / subtitle を変更してタイトル画面を更新
// - scenes リストのシーンを追加・削除・編集
// - endings リストのエンディングを変更
//
// 各 Choice の nextSceneId に '__ending__' を指定すると
// ゲーム状態に応じたエンディングへ遷移します。
// ============================================================

final ScenarioData defaultScenario = ScenarioData(
  title: '深淵の図書館',
  subtitle: 'クトゥルフ神話TRPG — インタラクティブシナリオ',
  scenes: [
    // ----------------------------------------------------------------
    // シーン: start
    // ----------------------------------------------------------------
    Scene(
      id: 'start',
      backgroundLevel: 0,
      text:
          'あなたは研究者として、とある古い図書館に招かれた。\n\n'
          '依頼主はすでに行方不明となっており、館内に取り残されたあなたは、'
          '出口がいつの間にか消えていることに気づく。\n\n'
          '不気味な静寂の中、埃まみれの机の上に、一冊の古い本が置かれている。',
      choices: [
        Choice(
          id: 'start_book',
          normalText: '本を手に取って調べる',
          abstractText: '本に近づく……',
          garbledText: '██を手に取る',
          sanChange: -5,
          karmaChange: 1,
          nextSceneId: 'found_book',
          historyText: '古い本を手に取った（+1因果）',
        ),
        Choice(
          id: 'start_exit',
          normalText: '出口を探して館内を歩き回る',
          abstractText: '歩き回る……',
          garbledText: '出口を……探す',
          sanChange: 0,
          karmaChange: 0,
          nextSceneId: 'search_exit',
          historyText: '出口を求めて館内を探し始めた',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: found_book
    // ----------------------------------------------------------------
    Scene(
      id: 'found_book',
      backgroundLevel: 1,
      text:
          '本の表紙には見慣れない文字が刻まれている。\n\n'
          '触れた瞬間、指先に異様な冷たさを感じた。恐る恐るページを開くと、'
          '複雑な図形と記号の連なりが目を刺す。これは普通の本ではない。',
      choices: [
        Choice(
          id: 'book_read',
          normalText: 'さらに読み進める',
          abstractText: '読み続ける……',
          garbledText: '█████を読む',
          sanChange: -10,
          karmaChange: 2,
          nextSceneId: 'read_book',
          historyText: '禁断の書を読み始めた（+2因果）',
        ),
        Choice(
          id: 'book_return',
          normalText: '本を棚に戻して別の方法を探す',
          abstractText: '棚に戻す……',
          garbledText: '戻す',
          sanChange: -3,
          karmaChange: 0,
          nextSceneId: 'search_exit',
          historyText: '不気味な本を棚に戻した',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: read_book
    // ----------------------------------------------------------------
    Scene(
      id: 'read_book',
      backgroundLevel: 2,
      text:
          '本の内容は人間の理解を超えていた。\n\n'
          '星の配置、古代の儀式、次元の歪み——読むにつれて、現実の輪郭が'
          '溶け始める感覚がする。しかし何かが引き留めている。知識への渇望か、恐怖か。',
      choices: [
        Choice(
          id: 'read_deep',
          normalText: 'さらに深く読み込む',
          abstractText: '深みへ……',
          garbledText: '██████読む',
          sanChange: -15,
          karmaChange: 3,
          nextSceneId: 'book_revelation',
          setsFlag: 'read_deep',
          historyText: '禁断の知識に飲み込まれた（+3因果）',
        ),
        Choice(
          id: 'read_stop',
          normalText: '正気を保ち、本を閉じる',
          abstractText: '閉じる……',
          garbledText: '逃げる',
          sanChange: -5,
          karmaChange: 0,
          nextSceneId: 'library_depths',
          historyText: '正気を保って本を閉じた',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: search_exit
    // ----------------------------------------------------------------
    Scene(
      id: 'search_exit',
      backgroundLevel: 1,
      text:
          '廊下を進むと、書棚の間から奇妙な声が聞こえてくる。\n\n'
          '低く、リズミカルな呟き。人間の声ではない。'
          '引き返す道と、声の源を確認する選択がある。',
      choices: [
        Choice(
          id: 'go_sound',
          normalText: '声の方向へ慎重に向かう',
          abstractText: '声へ……',
          garbledText: '█████へ',
          sanChange: -8,
          karmaChange: 1,
          nextSceneId: 'sound_source',
          historyText: '不気味な声の方向へ進んだ（+1因果）',
        ),
        Choice(
          id: 'avoid_sound',
          normalText: '引き返して別のルートを探す',
          abstractText: '引き返す……',
          garbledText: '逃げる',
          sanChange: -3,
          karmaChange: 0,
          nextSceneId: 'library_depths',
          historyText: '危険を感じて別ルートを探した',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: sound_source
    // ----------------------------------------------------------------
    Scene(
      id: 'sound_source',
      backgroundLevel: 2,
      text:
          '書棚の奥に人影を見つけた。\n\n'
          'それはかつての司書だった——しかし、もはや人間とは呼べないものに'
          '変わり果てていた。目が合った瞬間、全身を凍りつかせる恐怖が走る。',
      choices: [
        Choice(
          id: 'help_lib',
          normalText: '変貌した司書を助けようとする',
          abstractText: '近づく……',
          garbledText: '██に近づく',
          sanChange: -12,
          karmaChange: 0,
          nextSceneId: 'help_librarian',
          setsFlag: 'tried_help',
          historyText: '変貌した司書を助けようとした',
        ),
        Choice(
          id: 'flee_lib',
          normalText: '恐怖に駆られて逃げる',
          abstractText: '逃げる……',
          garbledText: '逃げる',
          sanChange: -10,
          karmaChange: 0,
          nextSceneId: 'library_depths',
          historyText: '恐怖に駆られて逃げ出した',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: help_librarian
    // ----------------------------------------------------------------
    Scene(
      id: 'help_librarian',
      backgroundLevel: 2,
      text:
          '司書に近づくと、彼女は涙を流した。\n\n'
          '「止めて……儀式を……」\n\n'
          'かろうじて聞き取れる言葉。館の奥で何かが行われている。',
      choices: [
        Choice(
          id: 'goto_ritual',
          normalText: '儀式の間を探して止めに行く',
          abstractText: '奥へ……',
          garbledText: '█████へ向かう',
          sanChange: -8,
          karmaChange: 2,
          nextSceneId: 'ritual_room',
          historyText: '儀式を止めるべく奥へ向かった（+2因果）',
        ),
        Choice(
          id: 'escape_with',
          normalText: '司書と共に脱出を試みる',
          abstractText: '連れて逃げる……',
          garbledText: '逃げる',
          sanChange: -5,
          karmaChange: 0,
          nextSceneId: 'escape_attempt',
          historyText: '司書を連れて脱出を試みた',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: book_revelation
    // ----------------------------------------------------------------
    Scene(
      id: 'book_revelation',
      backgroundLevel: 3,
      text:
          '本の最後のページに書かれていたのは、この図書館の真実だった。\n\n'
          '建物自体が一つの巨大な儀式装置であり、あなたはすでにその一部となっている。'
          'しかし今、すべてを知った者だけが見える抜け道が浮かび上がった。',
      choices: [
        Choice(
          id: 'take_secret_path',
          normalText: '禁断の知識が示す抜け道へ進む',
          abstractText: '抜け道へ……',
          garbledText: '████へ進む',
          sanChange: -5,
          karmaChange: 0,
          nextSceneId: 'secret_path',
          setsFlag: 'found_secret',
          historyText: '禁断の知識で秘密の道を見つけた',
        ),
        Choice(
          id: 'stop_ritual_from_book',
          normalText: '儀式の真実を知り、止めに向かう',
          abstractText: '止めに行く……',
          garbledText: '█████を止める',
          sanChange: -10,
          karmaChange: 3,
          nextSceneId: 'ritual_room',
          setsFlag: 'know_ritual',
          historyText: '儀式の真実を知り、止めに向かった（+3因果）',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: library_depths
    // ----------------------------------------------------------------
    Scene(
      id: 'library_depths',
      backgroundLevel: 2,
      text:
          '図書館の奥へと進む。\n\n'
          '書棚の本が独りでに落ち始め、天井から見えない何かの囁きが降り注ぐ。'
          '中央の広間に出ると、巨大な扉が目の前に現れた。'
          '扉の向こうから、低い振動音が伝わってくる。',
      choices: [
        Choice(
          id: 'open_door',
          normalText: '扉を開けて奥に進む',
          abstractText: '扉を開く……',
          garbledText: '████を開く',
          sanChange: -10,
          karmaChange: 2,
          nextSceneId: 'ritual_room',
          historyText: '謎の扉を開けた（+2因果）',
        ),
        Choice(
          id: 'find_escape',
          normalText: '扉を避け、別の出口を探す',
          abstractText: '別の道を……',
          garbledText: '逃げ道を……',
          sanChange: -3,
          karmaChange: 0,
          nextSceneId: 'escape_attempt',
          historyText: '別の脱出路を探した',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: ritual_room
    // ----------------------------------------------------------------
    Scene(
      id: 'ritual_room',
      backgroundLevel: 3,
      text:
          '扉の先には、古代の記号で埋め尽くされた円形の部屋があった。\n\n'
          '中央に輝く魔法陣。儀式は今まさに完成しようとしている。'
          'あなたには選択の時間が残されていない。',
      choices: [
        Choice(
          id: 'stop_ritual',
          normalText: '命がけで儀式を阻止する',
          abstractText: '止める……',
          garbledText: '█████阻止する',
          sanChange: -15,
          karmaChange: 1,
          nextSceneId: 'final_choice',
          setsFlag: 'stop_ritual',
          historyText: '絶望的な状況で儀式を阻止しようとした（+1因果）',
        ),
        Choice(
          id: 'complete_ritual',
          normalText: '儀式を完成させ、世界の理を変える',
          abstractText: '完成させる……',
          garbledText: '██████させる',
          sanChange: -20,
          karmaChange: 5,
          nextSceneId: 'final_choice',
          setsFlag: 'complete_ritual',
          historyText: '世界を変える儀式を完成させた（+5因果）',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: escape_attempt
    // ----------------------------------------------------------------
    Scene(
      id: 'escape_attempt',
      backgroundLevel: 2,
      text:
          '脱出口を見つけた。\n\n'
          'しかし外の景色は歪んでいる。現実の亀裂の向こうに見えるのは、'
          '本来の世界か、それとも夢か。',
      choices: [
        Choice(
          id: 'jump_through',
          normalText: '亀裂に飛び込む',
          abstractText: '飛び込む……',
          garbledText: '████に飛び込む',
          sanChange: -10,
          karmaChange: 0,
          nextSceneId: 'final_choice',
          historyText: '現実の亀裂に飛び込んだ',
        ),
        Choice(
          id: 'face_all',
          normalText: '逃げずに全てと向き合う覚悟をする',
          abstractText: '向き合う……',
          garbledText: '全てを……',
          sanChange: -5,
          karmaChange: 1,
          nextSceneId: 'ritual_room',
          historyText: '逃げずに全てと向き合う覚悟をした（+1因果）',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: secret_path
    // ----------------------------------------------------------------
    Scene(
      id: 'secret_path',
      backgroundLevel: 3,
      text:
          '禁断の知識が導いた道は、図書館の構造を貫く見えない廊下だった。\n\n'
          'すべてを知ったあなたの目には、真実の形が見える。'
          '最後の扉の前に立つ。これを開けば、元凶と対峙する。',
      choices: [
        Choice(
          id: 'open_final',
          normalText: '扉を開け、全てに決着をつける',
          abstractText: '扉を開く……',
          garbledText: '████を開く',
          sanChange: -10,
          karmaChange: 0,
          nextSceneId: 'final_choice',
          setsFlag: 'secret_end_flag',
          historyText: '全てを知った者として最後の扉を開いた',
        ),
      ],
    ),

    // ----------------------------------------------------------------
    // シーン: final_choice  （全パスが収束する）
    // ----------------------------------------------------------------
    Scene(
      id: 'final_choice',
      backgroundLevel: 3,
      text:
          'すべての出来事が収束する瞬間。\n\n'
          'あなたの選択と行動が、今ここで結実する。',
      choices: [
        Choice(
          id: 'accept_fate',
          normalText: '全てを受け入れる',
          abstractText: '受け入れる……',
          garbledText: '█████を受け入れる',
          sanChange: 0,
          karmaChange: 0,
          nextSceneId: '__ending__',
          historyText: 'エンディングへ向かった',
        ),
      ],
    ),
  ],

  // ----------------------------------------------------------------
  // エンディング
  // ----------------------------------------------------------------
  endings: [
    EndingData(
      id: 'ending_sane',
      title: '生還 ——— 正気の代償',
      text:
          'あなたは辛うじて正気を保ち、図書館から脱出することに成功した。\n\n'
          '外の世界は変わらず続いている。しかし、あの夜に見たものは'
          '生涯消えることなくあなたの心の奥に刻まれているだろう。\n\n'
          '秘密は、今日も静かに眠り続ける。',
      titleColor: Color(0xFF4FC3F7),
    ),
    EndingData(
      id: 'ending_mad',
      title: '狂気 ——— 目覚めぬ夢',
      text:
          'あなたの正気は完全に崩れ去った。\n\n'
          '現実と幻想の境界は消え、もはやどちらが真実かも分からない。'
          '外から見れば、あなたはただ虚空を見つめて微笑んでいるだけだ。\n\n'
          '深淵はあなたを受け入れた。永遠に。',
      titleColor: Color(0xFFE53935),
    ),
    EndingData(
      id: 'ending_karma',
      title: '因果 ——— 世界への刻印',
      text:
          'あなたの積み重ねた行動が世界に影を落とした。\n\n'
          '儀式の完成、知識の乱用、恐怖と向き合わない選択——'
          'それらは全て連鎖し、現実の根底をわずかに、しかし確実に歪ませた。\n\n'
          'あなたは生きている。しかし、世界はもう少しだけ暗くなった。',
      titleColor: Color(0xFFFF6F00),
    ),
    EndingData(
      id: 'ending_secret',
      title: '真実 ——— 深淵の滅却',
      text:
          '禁断の知識と、正気の残骸を代償に払い、あなたは元凶を滅ぼした。\n\n'
          '誰も知らない。誰も信じない。しかし、確かにこの世界の何かが'
          '救われた。それはあなただけが知る真実だ。\n\n'
          '図書館は静寂に返り、再び本は棚に並んでいる。\n\n'
          '——— 隠しエンディング達成 ———',
      titleColor: Color(0xFF7B1FA2),
    ),
  ],
);
