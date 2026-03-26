import 'package:flutter/material.dart';
import '../../../../../../core/theme/theme.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool isMonospace;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.textMuted),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextTheme.labelSmall.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isMonospace
                  ? AppTextTheme.caseId.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    )
                  : AppTextTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailDivider extends StatelessWidget {
  const DetailDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}

class DetailSectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const DetailSectionTitle({
    super.key,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextTheme.overline,
      ),
    );
  }
}
