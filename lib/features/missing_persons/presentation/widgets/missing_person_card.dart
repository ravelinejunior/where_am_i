import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:where_am_i/features/missing_persons/domain/entities/missing_person_entity.dart';

import '../../../../../../core/enums/enums.dart';
import '../../../../../../core/theme/theme.dart';

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
                    // Source badge + status
                    Row(
                      children: [
                        _SourceBadge(source: person.source),
                        const Spacer(),
                        if (person.lastSeenDate != null)
                          Text(
                            _formatDate(person.lastSeenDate!),
                            style: AppTextTheme.caption,
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),

                    // Name
                    Text(
                      person.name,
                      style: AppTextTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Meta row: age · sex · nationality
                    _MetaRow(person: person),
                    const SizedBox(height: 7),

                    // Last seen location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            person.locationDisplay,
                            style: AppTextTheme.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Chevron
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
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
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(
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
              errorWidget: (_, __, ___) => const _PhotoPlaceholder(),
            )
          : const _PhotoPlaceholder(),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.person_outline_rounded,
        size: 36,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final MissingPersonEntity person;

  const _MetaRow({required this.person});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (person.estimatedAge != null) parts.add('${person.estimatedAge} yrs');
    if (person.sex != PersonSex.unknown) parts.add(person.sex.label);
    if (person.nationality != null) parts.add(person.nationality!);

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' · '),
      style: AppTextTheme.labelSmall.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
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
      MissingPersonSource.firebase => (
          AppColors.communityBadge,
          AppColors.communityBadgeText,
          'COMMUNITY',
        ),
      MissingPersonSource.merged => (
          AppColors.interpolBadge,
          AppColors.interpolBadgeText,
          'INTERPOL',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextTheme.labelSmall.copyWith(
          color: fg,
          fontSize: 9,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
