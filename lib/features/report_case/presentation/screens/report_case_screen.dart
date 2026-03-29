import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/report_bloc.dart';
import '../widgets/photo_picker_grid.dart';
import '../widgets/form_section.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/router/route_names.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../app/app.dart';

class ReportCaseScreen extends StatelessWidget {
  const ReportCaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated) {
          return _AuthWall();
        }
        return BlocProvider(
          create: (_) => ReportBloc(
            reportMissingPerson: sl(),
          ),
          child: const _ReportFormView(),
        );
      },
    );
  }
}

// ── Auth wall ──────────────────────────────────────────────────

class _AuthWall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l.reportCase),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 32, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            Text(l.loginTitle,
                style: AppTextTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              l.loginSubtitle,
              style: AppTextTheme.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(
                RouteNames.loginName,
                queryParameters: {'redirect': RouteNames.reportCase},
              ),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: Text(l.loginSignIn),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form view ──────────────────────────────────────────────────

class _ReportFormView extends StatelessWidget {
  const _ReportFormView();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocListener<ReportBloc, ReportState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.isSuccess) _showSuccessSheet(context);
        if (state.status == ReportStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.goNamed(RouteNames.missingListName),
          ),
          title: Text(l.reportTitle),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pendingBadge,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.reportPendingBadge,
                style: AppTextTheme.labelSmall.copyWith(
                  color: AppColors.pendingBadgeText,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        body: const _FormBody(),
        bottomNavigationBar: const _SubmitBar(),
      ),
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SuccessSheet(
        onDone: () {
          Navigator.pop(context);
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(RouteNames.missingListName);
          }
        },
      ),
    );
  }
}

// ── Form body ──────────────────────────────────────────────────

class _FormBody extends StatefulWidget {
  const _FormBody();
  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final _nameCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _eyeColorCtrl = TextEditingController();
  final _hairColorCtrl = TextEditingController();
  final _factsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nationalityCtrl.dispose();
    _locationCtrl.dispose();
    _heightCtrl.dispose();
    _eyeColorCtrl.dispose();
    _hairColorCtrl.dispose();
    _factsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notice
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.pendingBadge,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.pendingBadgeText.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.pendingBadgeText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.reportPendingNotice,
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.pendingBadgeText,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Nome completo ──────────────────────────────
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (p, c) =>
                p.showErrors != c.showErrors || p.nameValid != c.nameValid,
            builder: (context, state) => FormSection(
              title: l.reportName,
              child: TextFormField(
                controller: _nameCtrl,
                onChanged: (v) =>
                    context.read<ReportBloc>().add(ReportNameChanged(v)),
                style: AppTextTheme.bodyMedium,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: l.reportNameHint,
                  errorText: state.showErrors && !state.nameValid
                      ? l.reportNameError
                      : null,
                ),
              ),
            ),
          ),

          // ── Nacionalidade ──────────────────────────────
          FormSection(
            title: l.reportNationality,
            subtitle: l.reportNationalitySubtitle,
            child: TextFormField(
              controller: _nationalityCtrl,
              onChanged: (v) =>
                  context.read<ReportBloc>().add(ReportNationalityChanged(v)),
              style: AppTextTheme.bodyMedium,
              inputFormatters: [
                LengthLimitingTextInputFormatter(2),
                UpperCaseTextFormatter(),
              ],
              decoration: InputDecoration(
                hintText: l.reportNationalityHint,
                counterText: '',
              ),
            ),
          ),

          // ── Sexo ──────────────────────────────────────
          FormSection(
            title: l.reportSex,
            child: BlocBuilder<ReportBloc, ReportState>(
              buildWhen: (p, c) => p.sex != c.sex,
              builder: (context, state) => SexSelector(
                selected: state.sex,
                onChanged: (sex) =>
                    context.read<ReportBloc>().add(ReportSexChanged(sex)),
              ),
            ),
          ),

          // ── Data de nascimento ─────────────────────────
          FormSection(
            title: l.reportDOB,
            child: BlocBuilder<ReportBloc, ReportState>(
              buildWhen: (p, c) => p.birthDate != c.birthDate,
              builder: (context, state) => DatePickerField(
                label: l.reportDOB,
                value: state.birthDate,
                lastDate: DateTime.now(),
                onChanged: (d) =>
                    context.read<ReportBloc>().add(ReportBirthDateChanged(d)),
              ),
            ),
          ),

          // ── Data do desaparecimento ────────────────────
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (p, c) =>
                p.lastSeenDate != c.lastSeenDate ||
                p.showErrors != c.showErrors,
            builder: (context, state) => FormSection(
              title: l.reportLastSeen,
              child: DatePickerField(
                label: l.reportLastSeen,
                value: state.lastSeenDate,
                lastDate: DateTime.now(),
                errorText: state.showErrors && !state.lastSeenDateValid
                    ? l.reportLastSeenError
                    : null,
                onChanged: (d) => context
                    .read<ReportBloc>()
                    .add(ReportLastSeenDateChanged(d)),
              ),
            ),
          ),

          // ── Local do desaparecimento ───────────────────
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (p, c) =>
                p.showErrors != c.showErrors ||
                p.lastSeenLocationValid != c.lastSeenLocationValid,
            builder: (context, state) => FormSection(
              title: l.reportLastLocation,
              child: TextFormField(
                controller: _locationCtrl,
                onChanged: (v) => context
                    .read<ReportBloc>()
                    .add(ReportLastLocationChanged(v)),
                style: AppTextTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: l.reportLastLocationHint,
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.textMuted),
                  errorText: state.showErrors && !state.lastSeenLocationValid
                      ? l.reportLastLocationError
                      : null,
                ),
              ),
            ),
          ),

          // ── Altura ────────────────────────────────────
          FormSection(
            title: l.reportHeight,
            child: TextFormField(
              controller: _heightCtrl,
              onChanged: (v) =>
                  context.read<ReportBloc>().add(ReportHeightChanged(v)),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: AppTextTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l.reportHeightHint,
                suffixText: 'cm',
              ),
            ),
          ),

          // ── Cor dos olhos ──────────────────────────────
          FormSection(
            title: l.reportEyeColor,
            child: TextFormField(
              controller: _eyeColorCtrl,
              onChanged: (v) =>
                  context.read<ReportBloc>().add(ReportEyeColorChanged(v)),
              style: AppTextTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l.reportEyeColorHint,
                prefixIcon: const Icon(Icons.remove_red_eye_outlined,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
          ),

          // ── Cor do cabelo ──────────────────────────────
          FormSection(
            title: l.reportHairColor,
            child: TextFormField(
              controller: _hairColorCtrl,
              onChanged: (v) =>
                  context.read<ReportBloc>().add(ReportHairColorChanged(v)),
              style: AppTextTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l.reportHairColorHint,
                prefixIcon: const Icon(Icons.face_outlined,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
          ),

          // ── Fotos ──────────────────────────────────────
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (p, c) => p.localPhotoPaths != c.localPhotoPaths,
            builder: (context, state) => FormSection(
              title: l.reportPhotos,
              subtitle: l.reportPhotosSubtitle,
              child: PhotoPickerGrid(
                paths: state.localPhotoPaths,
                onAdd: () async {
                  final path = await pickPhoto(context);
                  if (path != null && context.mounted) {
                    context.read<ReportBloc>().add(ReportPhotoAdded(path));
                  }
                },
                onRemove: (i) =>
                    context.read<ReportBloc>().add(ReportPhotoRemoved(i)),
              ),
            ),
          ),

          // ── Detalhes adicionais ────────────────────────
          FormSection(
            title: l.reportFacts,
            child: TextFormField(
              controller: _factsCtrl,
              onChanged: (v) =>
                  context.read<ReportBloc>().add(ReportFactsChanged(v)),
              maxLines: 4,
              style: AppTextTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l.reportFactsHint,
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submit bar ─────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  const _SubmitBar();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: BlocBuilder<ReportBloc, ReportState>(
          buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
          builder: (context, state) => ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.read<ReportBloc>().add(const ReportSubmitted()),
            child: state.isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: AppColors.textOnRed, strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(l.reportSubmitting),
                    ],
                  )
                : Text(l.reportSubmit),
          ),
        ),
      ),
    );
  }
}

// ── Success sheet ──────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessSheet({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.communityBadge,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 32, color: AppColors.communityBadgeText),
          ),
          const SizedBox(height: 20),
          Text(l.reportSuccess, style: AppTextTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            l.reportSuccessBody,
            style: AppTextTheme.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: onDone,
            child: Text(l.reportBackToCases),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    return newVal.copyWith(text: newVal.text.toUpperCase());
  }
}
