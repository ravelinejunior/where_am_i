import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

/// Placeholder — full implementation in commit #7 (MissingListBloc + Screen)
class MissingListScreen extends StatelessWidget {
  const MissingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Where Am I?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search_rounded, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Missing persons list',
              style: AppTextTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Full implementation in commit #7',
              style: AppTextTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnRed,
        icon: const Icon(Icons.sos_rounded),
        label: const Text('SOS 112'),
      ),
    );
  }
}
