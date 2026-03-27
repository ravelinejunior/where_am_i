import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:where_am_i/features/missing_persons/domain/entities/missing_person_entity.dart';

import '../../../../../../core/enums/enums.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/utils/country_utils.dart';

class MissingPersonCard extends StatelessWidget {
  final MissingPersonEntity person;
  final VoidCallback onTap;

  const MissingPersonCard({
    super.key,
    required this.person,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Photo
            _PhotoSlot(person: person),

            // Info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row
                    Row(children: [
                      _SourceBadge(source: person.source),
                      const Spacer(),
                      // Date of disappearance (right-aligned)
                      if (person.lastSeenDate != null)
                        Text(
                          DateFormat('dd MMM yyyy')
                              .format(person.lastSeenDate!),
                          style: AppTextTheme.caption,
                        ),
                    ]),
                    const SizedBox(height: 7),

                    // Name
                    Text(
                      person.name,
                      style: AppTextTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Meta: age · sex · country (full name)
                    _MetaRow(person: person),
                    const SizedBox(height: 7),

                    // Last seen location
                    if (person.lastSeenLocation?.isNotEmpty == true)
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            person.lastSeenLocation!,
                            style: AppTextTheme.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ])
                    else
                      Row(children: [
                        const Icon(Icons.location_off_outlined,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('Location unknown',
                            style: AppTextTheme.caption
                                .copyWith(color: AppColors.textMuted)),
                      ]),
                  ],
                ),
              ),
            ),

            // Chevron
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final MissingPersonEntity person;
  const _PhotoSlot({required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: person.primaryPhotoUrl != null
          ? CachedNetworkImage(
              imageUrl: person.primaryPhotoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const _PhotoPlaceholder(),
              errorWidget: (_, __, ___) => _PhotoPlaceholder(sex: person.sex),
            )
          : _PhotoPlaceholder(sex: person.sex),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final PersonSex sex;
  const _PhotoPlaceholder({this.sex = PersonSex.unknown});

  @override
  Widget build(BuildContext context) {
    final icon = switch (sex) {
      PersonSex.male => Icons.person_outline_rounded,
      PersonSex.female => Icons.person_outline_rounded,
      PersonSex.unknown => Icons.person_outline_rounded,
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: AppColors.textMuted),
          if (sex != PersonSex.unknown) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: sex == PersonSex.male
                    ? AppColors.interpolBadge
                    : const Color(0xFF4A1B2E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                sex.label,
                style: AppTextTheme.labelSmall.copyWith(
                  fontSize: 9,
                  color: sex == PersonSex.male
                      ? AppColors.interpolBadgeText
                      : const Color(0xFFF4C0D1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final MissingPersonEntity person;
  const _MetaRow({required this.person});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (person.estimatedAge != null)
          _MetaChip(
            label: '${person.estimatedAge} yrs',
            color: AppColors.surfaceHighlight,
            textColor: AppColors.textSecondary,
          ),
        if (person.sex != PersonSex.unknown)
          _MetaChip(
            label: person.sex.label,
            color: person.sex == PersonSex.male
                ? AppColors.interpolBadge
                : const Color(0xFF3D1020),
            textColor: person.sex == PersonSex.male
                ? AppColors.interpolBadgeText
                : const Color(0xFFF4C0D1),
          ),
        if (person.nationality != null)
          _MetaChip(
            label: CountryUtils.nameFromAlpha3(person.nationality!),
            color: AppColors.surfaceHighlight,
            textColor: AppColors.textSecondary,
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _MetaChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextTheme.labelSmall.copyWith(
          fontSize: 10,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final MissingPersonSource source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (source) {
      MissingPersonSource.interpol => (
          AppColors.interpolBadge,
          AppColors.interpolBadgeText,
          'INTERPOL',
        ),
      _ => (
          AppColors.communityBadge,
          AppColors.communityBadgeText,
          'COMMUNITY',
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: AppTextTheme.labelSmall
            .copyWith(color: fg, fontSize: 9, letterSpacing: 0.8),
      ),
    );
  }
}
