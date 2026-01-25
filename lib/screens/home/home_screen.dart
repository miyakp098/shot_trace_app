import 'package:flutter/material.dart';
import '../camera/camera_screen.dart';
import '../setting/setting_screen.dart';
import '../analysis/analysis_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HomeMenuButton(
              icon: Icons.camera_alt,
              label: 'カメラ',
              description: 'シュート動画を撮影',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CameraScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            _HomeMenuButton(
              icon: Icons.movie,
              label: '動画分析',
              description: '動画を分析する',
              onTap: () {
                // TODO: 動画分析画面への遷移を実装
                // 推移後内容: 写真ライブラリにある動画を選択して、APIに送信する
                // 送信については非同期で行いたい
              },
            ),
            const SizedBox(height: 32),
            _HomeMenuButton(
              icon: Icons.analytics,
              label: '分析結果',
              description: 'シュート動画の分析結果を表示',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnalysisResultScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            _HomeMenuButton(
              icon: Icons.settings,
              label: '設定',
              description: 'アプリの各種設定',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ホーム画面のメニューボタン用ウィジェット
class _HomeMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _HomeMenuButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
