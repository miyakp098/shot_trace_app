# shot_trace_app

A new Flutter project.


**Project Structure**

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

**Screen-first の Flutter ディレクトリ構成**

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