import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:where_am_i/core/constants/app_constants.dart';

import '../../../missing_persons/domain/entities/missing_person_entity.dart';
import '../../../../core/theme/theme.dart';

class AdminCaseCard extends StatelessWidget {
  final MissingPersonEntity person;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const AdminCaseCard({
    super.key,
    required this.person,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isProcessing ? 0.5 : 1.0,
      duration: AppConstants.animNormal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo thumbnail
                  Container(
                    width: 52,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: person.primaryPhotoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: person.primaryPhotoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textMuted,
                            ),
                          )
                        : const Icon(Icons.person_outline_rounded,
                            color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pending badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.pendingBadge,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PENDING REVIEW',
                            style: AppTextTheme.labelSmall.copyWith(
                              color: AppColors.pendingBadgeText,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Name
                        Text(
                          person.name,
                          style: AppTextTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Meta
                        Text(
                          [
                            if (person.estimatedAge != null)
                              '${person.estimatedAge} yrs',
                            if (person.nationality != null) person.nationality!,
                            person.sex.label,
                          ].join(' · '),
                          style: AppTextTheme.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Details strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: AppColors.divider, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      person.locationDisplay,
                      style: AppTextTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (person.lastSeenDate != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule_outlined,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(person.lastSeenDate!),
                      style: AppTextTheme.caption,
                    ),
                  ],
                ],
              ),
            ),

            // Facts preview
            if (person.facts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Text(
                  person.facts.take(2).join(' · '),
                  style: AppTextTheme.bodySmall
                      .copyWith(color: AppColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Submitted at
            if (person.createdAt != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Text(
                  'Submitted ${DateFormat('dd MMM yyyy, HH:mm').format(person.createdAt!)}',
                  style:
                      AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                ),
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(12),
              child: isProcessing
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        // Reject
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onReject,
                            icon: const Icon(Icons.close_rounded, size: 15),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              minimumSize: const Size(0, 42),
                              side: const BorderSide(
                                  color: AppColors.border, width: 0.5),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Approve
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            icon: const Icon(Icons.check_rounded, size: 15),
                            label: const Text('Approve & publish'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 42),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
