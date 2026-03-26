import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_am_i/features/missing_persons/domain/entities/missing_person_entity.dart';

import '../bloc/detail/missing_detail_bloc.dart';
import '../widgets/photo_gallery.dart';
import '../widgets/detail_row.dart';
import '../widgets/empty_state.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../../core/enums/enums.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/constants/app_constants.dart';

class MissingDetailScreen extends StatelessWidget {
  final String id;

  /// Entity passed from the list via GoRouter extra — skips network call.
  final MissingPersonEntity? prefetched;

  const MissingDetailScreen({
    super.key,
    required this.id,
    this.prefetched,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissingDetailBloc(getDetail: sl())
        ..add(MissingDetailLoaded(
          id: id,
          isInterpolCase: prefetched?.source == MissingPersonSource.interpol ||
              (prefetched == null && !id.contains('firestore')),
          prefetched: prefetched,
        )),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MissingDetailBloc, MissingDetailState>(
      builder: (context, state) {
        if (state.isLoading || state.status == MissingDetailStatus.initial) {
          return _LoadingScaffold();
        }

        if (state.isFailure || state.person == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(backgroundColor: AppColors.background),
            body: EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Case unavailable',
              subtitle: 'This case could not be loaded right now.',
              retryLabel: 'Go back',
              onRetry: () => Navigator.of(context).pop(),
            ),
          );
        }

        return _DetailContent(person: state.person!);
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  final MissingPersonEntity person;

  const _DetailContent({required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameHeader(person: person),
                  const SizedBox(height: 24),
                  _buildInfoCard(context),
                  if (person.facts.isNotEmpty) ...[
                    const DetailSectionTitle(title: 'Case details'),
                    _FactsList(facts: person.facts),
                  ],
                  if (person.contacts.isNotEmpty) ...[
                    const DetailSectionTitle(title: 'Contacts'),
                    _ContactsList(contacts: person.contacts),
                  ],
                  const SizedBox(height: 24),
                  _ActionButtons(person: person),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: person.hasPhotos ? 300 : 100,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 18),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined, size: 18),
          ),
          onPressed: () => _share(person),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: person.hasPhotos
            ? PhotoGallery(photoUrls: person.photoUrls)
            : Container(
                color: AppColors.surface,
                child: const Center(
                  child: Icon(Icons.person_outline_rounded,
                      size: 64, color: AppColors.textMuted),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          if (person.estimatedAge != null) ...[
            DetailRow(
              label: 'AGE',
              value: '${person.estimatedAge} years old',
              icon: Icons.cake_outlined,
            ),
            const DetailDivider(),
          ],
          if (person.birthDate != null) ...[
            DetailRow(
              label: 'DATE OF BIRTH',
              value: DateFormat('dd MMM yyyy').format(person.birthDate!),
              icon: Icons.today_outlined,
            ),
            const DetailDivider(),
          ],
          DetailRow(
            label: 'SEX',
            value: person.sex.label,
            icon: Icons.person_outline_rounded,
          ),
          if (person.nationality != null) ...[
            const DetailDivider(),
            DetailRow(
              label: 'NATIONALITY',
              value: person.nationality!,
              icon: Icons.flag_outlined,
            ),
          ],
          if (person.heightCm != null) ...[
            const DetailDivider(),
            DetailRow(
              label: 'HEIGHT',
              value: '${person.heightCm} cm',
              icon: Icons.height_rounded,
            ),
          ],
          if (person.eyeColor != null) ...[
            const DetailDivider(),
            DetailRow(
              label: 'EYE COLOUR',
              value: person.eyeColor!,
              icon: Icons.remove_red_eye_outlined,
            ),
          ],
          if (person.hairColor != null) ...[
            const DetailDivider(),
            DetailRow(
              label: 'HAIR COLOUR',
              value: person.hairColor!,
              icon: Icons.face_outlined,
            ),
          ],
          if (person.lastSeenDate != null) ...[
            const DetailDivider(),
            DetailRow(
              label: 'LAST SEEN',
              value: DateFormat('dd MMM yyyy').format(person.lastSeenDate!),
              icon: Icons.schedule_outlined,
            ),
          ],
          if (person.lastSeenLocation != null) ...[
            const DetailDivider(),
            DetailRow(
              label: 'LOCATION',
              value: person.lastSeenLocation!,
              icon: Icons.location_on_outlined,
            ),
          ],
          const DetailDivider(),
          DetailRow(
            label: 'CASE ID',
            value: person.id,
            icon: Icons.tag_rounded,
            isMonospace: true,
          ),
        ],
      ),
    );
  }

  void _share(MissingPersonEntity person) {
    final age =
        person.estimatedAge != null ? ', ${person.estimatedAge} years old' : '';
    final location = person.lastSeenLocation != null
        ? '\nLast seen: ${person.lastSeenLocation}'
        : '';
    final url = person.externalUrl ?? '';

    Share.share(
      '🔴 MISSING PERSON\n\n'
      '${person.name}$age\n'
      '$location\n\n'
      'If you have any information, please contact the authorities immediately.'
      '${url.isNotEmpty ? '\n\n$url' : ''}',
      subject: 'Missing Person: ${person.name}',
    );
  }
}

// ── Name header ────────────────────────────────────────────────

class _NameHeader extends StatelessWidget {
  final MissingPersonEntity person;
  const _NameHeader({required this.person});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source badge
        _SourceBadge(source: person.source),
        const SizedBox(height: 10),

        // Name
        Text(
          person.name,
          style: AppTextTheme.displaySmall,
        ),

        // Short meta
        const SizedBox(height: 8),
        Row(
          children: [
            if (person.estimatedAge != null) ...[
              const Icon(Icons.cake_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${person.estimatedAge} yrs', style: AppTextTheme.bodySmall),
              const SizedBox(width: 12),
            ],
            if (person.nationality != null) ...[
              const Icon(Icons.flag_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(person.nationality!, style: AppTextTheme.bodySmall),
            ],
          ],
        ),

        // Last seen chip
        if (person.lastSeenDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 13, color: AppColors.primaryLight),
                const SizedBox(width: 6),
                Text(
                  'Last seen ${DateFormat('dd MMM yyyy').format(person.lastSeenDate!)}',
                  style: AppTextTheme.labelMedium.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Source badge ───────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  final MissingPersonSource source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (source) {
      MissingPersonSource.interpol => (
          AppColors.interpolBadge,
          AppColors.interpolBadgeText,
          'INTERPOL'
        ),
      _ => (
          AppColors.communityBadge,
          AppColors.communityBadgeText,
          'COMMUNITY'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextTheme.labelSmall.copyWith(color: fg, fontSize: 10),
      ),
    );
  }
}

// ── Facts list ─────────────────────────────────────────────────

class _FactsList extends StatelessWidget {
  final List<String> facts;
  const _FactsList({required this.facts});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: facts.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 7),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(facts[i], style: AppTextTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contacts list ──────────────────────────────────────────────

class _ContactsList extends StatelessWidget {
  final List<CaseContact> contacts;
  const _ContactsList({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: contacts.map((c) => _ContactTile(contact: c)).toList(),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final CaseContact contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final icon = switch (contact.type) {
      ContactType.phone => Icons.call_outlined,
      ContactType.email => Icons.mail_outlined,
      ContactType.website => Icons.language_outlined,
      ContactType.other => Icons.info_outline_rounded,
    };

    return GestureDetector(
      onTap: () => _launch(contact),
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: contact.value));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to clipboard')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.label,
                      style: AppTextTheme.labelMedium
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    contact.value,
                    style: AppTextTheme.bodyMedium.copyWith(
                      color: contact.type.isLaunchable
                          ? AppColors.primaryLight
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (contact.type.isCallable || contact.type.isLaunchable)
              const Icon(Icons.arrow_outward_rounded,
                  size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(CaseContact contact) async {
    final raw = contact.type.uriScheme + contact.value;
    final uri = Uri.tryParse(raw.isNotEmpty ? raw : contact.value);
    if (uri != null && await canLaunchUrl(uri)) launchUrl(uri);
  }
}

// ── Action buttons ─────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final MissingPersonEntity person;
  const _ActionButtons({required this.person});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SOS
        ElevatedButton.icon(
          onPressed: () async {
            final uri = Uri.parse(AppConstants.emergencyNumber);
            if (await canLaunchUrl(uri)) launchUrl(uri);
          },
          icon: const Icon(Icons.sos_rounded, size: 18),
          label: const Text('Emergency — Call 112'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnRed,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        const SizedBox(height: 12),

        // Share
        OutlinedButton.icon(
          onPressed: () => _share(context, person),
          icon: const Icon(Icons.share_outlined, size: 16),
          label: const Text('Share this case'),
        ),

        // Interpol link
        if (person.externalUrl != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri.parse(person.externalUrl!);
              if (await canLaunchUrl(uri)) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('View on INTERPOL'),
          ),
        ],
      ],
    );
  }

  void _share(BuildContext context, MissingPersonEntity person) {
    final age =
        person.estimatedAge != null ? ', ${person.estimatedAge} yrs' : '';
    final location = person.lastSeenLocation != null
        ? '\nLast seen: ${person.lastSeenLocation}'
        : '';
    final url = person.externalUrl ?? '';

    Share.share(
      '🔴 MISSING PERSON\n\n'
      '${person.name}$age\n'
      '$location\n\n'
      'If you have any information, please contact the authorities.'
      '${url.isNotEmpty ? '\n\n$url' : ''}',
      subject: 'Missing Person: ${person.name}',
    );
  }
}

// ── Loading scaffold ───────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
