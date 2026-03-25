import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

/// Placeholder — full implementation in commit #12
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Text(
          'Settings — coming in commit #12',
          style: AppTextTheme.bodyMedium,
        ),
      ),
    );
  }
}
