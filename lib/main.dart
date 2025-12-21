import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // ここではアプリのテーマを定義しています。
        //
        // 試してみてください: ターミナルで `flutter run` を実行すると
        // アプリが起動してツールバーが表示されます。アプリを終了せずに
        // 下の colorScheme の `seedColor` を `Colors.green` に変更して、
        // ホットリロードを行ってください（保存するか、Flutter 対応の
        // IDE のホットリロードボタン、またはコマンドラインで開始した場
        // 合は `r` を押します）。
        //
        // カウンタがゼロに戻っていないことに注意してください — ホット
        // リロードではアプリの状態は保持されます。状態をリセットしたい
        // 場合はホットリスタートを使ってください。
        //
        // この仕組みは値の変更だけでなくコード変更にも有効です: ほとんど
        // のコード変更はホットリロードだけで動作確認できます。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

