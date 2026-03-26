import 'package:flutter/material.dart';
import 'package:where_am_i/core/constants/app_constants.dart';
import 'package:where_am_i/core/enums/enums.dart';
import '../../../../../../core/theme/theme.dart';

/// Labelled section wrapper used throughout the report form.
class FormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets? padding;

  const FormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextTheme.overline,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTextTheme.caption),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Tappable date field that opens a date picker.
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? errorText;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: errorText != null ? AppColors.danger : AppColors.border,
            width: errorText != null ? 1 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextTheme.labelSmall.copyWith(
                color:
                    errorText != null ? AppColors.danger : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: value != null
                      ? AppColors.textSecondary
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  value != null
                      ? '${value!.day.toString().padLeft(2, '0')} / '
                          '${value!.month.toString().padLeft(2, '0')} / '
                          '${value!.year}'
                      : 'Select date',
                  style: AppTextTheme.bodyMedium.copyWith(
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                if (value != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textMuted),
                  ),
              ],
            ),
            if (errorText != null) ...[
              const SizedBox(height: 6),
              Text(
                errorText!,
                style: AppTextTheme.caption.copyWith(color: AppColors.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: firstDate ?? DateTime(1920),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }
}

/// Sex selector chips row.
class SexSelector extends StatelessWidget {
  final PersonSex selected;
  final ValueChanged<PersonSex> onChanged;

  const SexSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PersonSex.values.map((sex) {
        final isSelected = sex == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(sex),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              margin:
                  EdgeInsets.only(right: sex != PersonSex.values.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  sex.label,
                  style: AppTextTheme.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textOnRed
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
