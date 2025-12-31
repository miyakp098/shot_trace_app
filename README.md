# shot_trace_app

スマートフォンでオーバーレイに合わせてシュートの動画を撮影します。撮影した動画をバスケ解析APIに送信し、解析結果をアプリ画面に表示します。

**ディレクトリ構成**

- **`lib/`**: Dart ソースコード

```
lib/
├── main.dart
├── screens/
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── home_viewmodel.dart
│   │   └── widgets/
│   │       └── home_appbar.dart
│   ├── camera/
│   │   ├── camera_screen.dart
│   │   ├── camera_viewmodel.dart
│   │   └── widgets/
│   │       └── camera_preview.dart
│   └── setting/
│       ├── setting_screen.dart
│       └── setting_viewmodel.dart
└── widgets/
    └── common_button.dart
```

- **`android/`**: Android ネイティブプロジェクト（Gradle）
- **`ios/`**: iOS ネイティブプロジェクト（Xcode）
- **`test/`**: Dart/Flutter のテスト

**ディレクトリ構成思想：Screen-first**

アプリケーションの各画面（スクリーン）をトップレベルのディレクトリとして、その配下に画面固有のコード（UI、ViewModel／Model、画面用ウィジェットなど）をまとめる構成です。画面ごとに関連コードがまとまり、画面単位での開発・レビュー・テストがしやすくなるため、小〜中規模アプリで特に有効です。

ただし、共通コンポーネントやユーティリティを横断的に変更する必要がある場合、複数のスクリーンディレクトリを変更しなければならず、大規模なコードベースでは管理が煩雑になる可能性があります。

**Run on Chrome (Web) — Chrome で画面を素早く確認する**

開発中にローカルの Chrome ブラウザで素早く画面を確認したい場合の手順です（macOS）。

1. 必要な設定（初回のみ）:

```bash
flutter config --enable-web
```

2. 依存関係を取得:

```bash
flutter pub get
```

3. 利用可能なデバイスを確認（Chrome が一覧にあることを確認）:

```bash
flutter devices
```

4. Chrome で起動:

```bash
flutter run -d chrome
```

**実機テスト (iOS / Android)**

プロジェクトルートで以下を実行して接続済みのデバイスを検出し、取得したデバイスIDを使って実機でアプリを起動します。`flutter` は環境の PATH にあるコマンドを使用してください（絶対パスは不要です）。

- 1) デバイス一覧を JSON 形式で確認（`--machine`）:

```zsh
# プロジェクトルートで実行
flutter devices --machine
```
出力された JSON の中の `id` がデバイス識別子です。手動でコピーして利用してください（例: `00000000-0001111CCCCEEEEE`）

- 2) 手動で実行する例:

```zsh
# 例: 上のコマンドで得たデバイスIDを使う
flutter run -d 00000000-0001111CCCCEEEEE -v
```

リリースビルド

```zsh
flutter run --release
```


注意事項:
- iOS 実機で実行する場合は、デバイスの画面ロックを解除し、信頼設定が済んでいることを確認してください。
- 初回は Xcode のコマンドラインツールと初期設定（`xcode-select` や `xcodebuild -runFirstLaunch`）が必要になる場合があります。
- `flutter` コマンドが PATH に無い場合は PATH 設定を行ってください（README 内では絶対パスを直接書かないことを推奨します）。

**iOS: CocoaPods のインストール（必要な場合）**

```zsh
cd ios
pod install --repo-update
```