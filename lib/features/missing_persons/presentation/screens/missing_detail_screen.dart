import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:where_am_i/features/missing_persons/domain/entities/missing_person_entity.dart';

import '../bloc/detail/missing_detail_bloc.dart';
import '../widgets/photo_gallery.dart';
import '../widgets/detail_row.dart';
import '../widgets/empty_state.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_launcher_util.dart';
import '../../../../core/utils/country_utils.dart';
import '../../../../app/app.dart';

class MissingDetailScreen extends StatelessWidget {
  final String id;
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
              title: context.l10n.caseUnavailable,
              subtitle: context.l10n.caseUnavailableSubtitle,
              retryLabel: context.l10n.goBack,
              onRetry: () => Navigator.of(context).pop(),
            ),
          );
        }
        return _DetailContent(person: state.person!);
      },
    );
  }
}

// ── Main content ───────────────────────────────────────────────

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
                  _InfoCard(person: person),
                  if (person.facts.isNotEmpty) ...[
                    const DetailSectionTitle(title: 'Detalhes do caso'),
                    _FactsList(
                        facts: person.facts
                            .where(
                                (f) => !f.startsWith('Family name at birth:'))
                            .toList()),
                  ],
                  if (person.contacts.isNotEmpty) ...[
                    const DetailSectionTitle(title: 'Contatos'),
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

  void _share(MissingPersonEntity person) {
    final age =
        person.estimatedAge != null ? ', ${person.estimatedAge} yrs' : '';
    final loc = person.lastSeenLocation != null
        ? '\nPlace of disappearance: ${person.lastSeenLocation}'
        : '';
    final url = person.externalUrl ?? '';
    Share.share(
      '🔴 MISSING PERSON\n\n${person.name}$age\n$loc\n\n'
      'If you have any information, please contact the authorities.'
      '${url.isNotEmpty ? '\n\n$url' : ''}',
      subject: 'Missing Person: ${person.name}',
    );
  }
}

// ── Info card ──────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final MissingPersonEntity person;
  const _InfoCard({required this.person});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = <Widget>[];
    bool first = true;

    void add(String label, String value, IconData icon) {
      if (!first) rows.add(const DetailDivider());
      rows.add(DetailRow(label: label, value: value, icon: icon));
      first = false;
    }

    // Mirror interpol.int "Identity particulars" order
    if (person.surname?.isNotEmpty == true) {
      add(l.detailFamilyName.toUpperCase(), person.surname!.toUpperCase(),
          Icons.person_outline_rounded);
    }
    if (person.forename?.isNotEmpty == true) {
      add(l.detailForename.toUpperCase(), _tc(person.forename!),
          Icons.badge_outlined);
    }
    // Family name at birth — shown only if different from family name
    // (comes from facts list for Interpol cases)
    final familyAtBirth = person.facts
        .where((f) => f.startsWith('Family name at birth:'))
        .map((f) => f.replaceFirst('Family name at birth: ', ''))
        .firstOrNull;
    if (familyAtBirth != null) {
      add(l.detailFamilyNameAtBirth.toUpperCase(), familyAtBirth,
          Icons.history_edu_outlined);
    }
    // Only show gender row if we have a value (detail fetch may not have arrived yet)
    if (person.sex != PersonSex.unknown) {
      add('SEXO', person.sex.label, Icons.wc_outlined);
    }
    if (person.birthDate != null) {
      final age = person.estimatedAge;
      add(
        'DATA DE NASC.',
        '${DateFormat('dd/MM/yyyy').format(person.birthDate!)}'
            '${age != null ? ' ($age years old)' : ''}',
        Icons.today_outlined,
      );
    }
    if (person.nationality?.isNotEmpty == true) {
      add(
        'NACIONALIDADE',
        CountryUtils.nameFromAlpha3(person.nationality!),
        Icons.flag_outlined,
      );
    }
    if (person.lastSeenLocation?.isNotEmpty == true) {
      add(l.detailPlaceDisapp.toUpperCase(), person.lastSeenLocation!,
          Icons.location_on_outlined);
    }
    if (person.lastSeenDate != null) {
      final ageAt = _ageAt(person.birthDate, person.lastSeenDate!);
      add(
        'DATA DO DESAP.',
        '${DateFormat('dd/MM/yyyy').format(person.lastSeenDate!)}'
            '${ageAt != null ? ' (When $ageAt years old)' : ''}',
        Icons.schedule_outlined,
      );
    }
    if (person.heightCm != null) {
      add(l.detailHeight.toUpperCase(), '${person.heightCm} cm',
          Icons.height_rounded);
    }
    if (person.weightKg != null) {
      add(l.detailWeight.toUpperCase(), '${person.weightKg} kg',
          Icons.monitor_weight_outlined);
    }
    if (person.eyeColor?.isNotEmpty == true) {
      add(l.detailEyeColour.toUpperCase(), person.eyeColor!,
          Icons.remove_red_eye_outlined);
    }
    if (person.hairColor?.isNotEmpty == true) {
      add(l.detailHairColour.toUpperCase(), person.hairColor!,
          Icons.face_outlined);
    }
    add(l.caseIdLabel.toUpperCase(), person.id, Icons.tag_rounded);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(children: rows),
    );
  }

  static String _tc(String s) => s
      .split(' ')
      .map((w) =>
          w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  static int? _ageAt(DateTime? birth, DateTime at) {
    if (birth == null) return null;
    int a = at.year - birth.year;
    if (at.month < birth.month ||
        (at.month == birth.month && at.day < birth.day)) {
      a--;
    }
    return a;
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
        _SourceBadge(source: person.source),
        const SizedBox(height: 10),
        Text(person.name, style: AppTextTheme.displaySmall),
        const SizedBox(height: 8),
        Row(children: [
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
            Flexible(
              child: Text(
                CountryUtils.nameFromAlpha3(person.nationality!),
                style: AppTextTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ]),
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
                  'Disappeared ${DateFormat('dd/MM/yyyy').format(person.lastSeenDate!)}',
                  style: AppTextTheme.labelMedium
                      .copyWith(color: AppColors.primaryLight),
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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: AppTextTheme.labelSmall.copyWith(color: fg, fontSize: 10)),
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
              Expanded(child: Text(facts[i], style: AppTextTheme.bodyMedium)),
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
        children: contacts.map((c) => _ContactTile(contact: c)).toList());
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
      onTap: () => launchSafely(
        contact.type.uriScheme.isNotEmpty
            ? contact.type.uriScheme + contact.value
            : contact.value,
      ),
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: contact.value));
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Copiado')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (contact.type.isCallable || contact.type.isLaunchable)
            const Icon(Icons.arrow_outward_rounded,
                size: 14, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}

// ── Action buttons ─────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final MissingPersonEntity person;
  const _ActionButtons({required this.person});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ElevatedButton.icon(
        onPressed: () => launchSafely(AppConstants.emergencyNumber),
        icon: const Icon(Icons.sos_rounded, size: 18),
        label: Text(context.l10n.sosCallEurope),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnRed,
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => _share(person),
        icon: const Icon(Icons.share_outlined, size: 16),
        label: Text(context.l10n.shareCase),
      ),
      if (person.externalUrl != null) ...[
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => launchSafely(person.externalUrl!),
          icon: const Icon(Icons.open_in_new_rounded, size: 16),
          label: const Text('Ver na INTERPOL'),
        ),
      ],
    ]);
  }

  void _share(MissingPersonEntity person) {
    final age =
        person.estimatedAge != null ? ', ${person.estimatedAge} yrs' : '';
    final loc = person.lastSeenLocation != null
        ? '\nPlace of disappearance: ${person.lastSeenLocation}'
        : '';
    final url = person.externalUrl ?? '';
    Share.share(
      '🔴 MISSING PERSON\n\n${person.name}$age\n$loc\n\n'
      'Se tiver informações, contacte as autoridades.'
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
          child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
