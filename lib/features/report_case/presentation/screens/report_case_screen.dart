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

class ReportCaseScreen extends StatelessWidget {
  const ReportCaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auth guard — redirect to login if not signed in
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated) {
          return _AuthWall();
        }

        return BlocProvider(
          create: (_) => ReportBloc(
            reportMissingPerson: sl(),
            userId: authState.user!.uid,
          ),
          child: const _ReportFormView(),
        );
      },
    );
  }
}

// ── Auth wall (shown when not logged in) ──────────────────────

class _AuthWall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Report a case'),
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
            Text('Sign in to report',
                style: AppTextTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'You need an account to submit a missing person report.',
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
              label: const Text('Sign in'),
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
    return BlocListener<ReportBloc, ReportState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.isSuccess) {
          _showSuccessSheet(context);
        }
        if (state.status == ReportStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.surface,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const _FormBody(),
        bottomNavigationBar: const _SubmitBar(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(RouteNames.missingListName);
          }
        },
      ),
      title: const Text('Report a missing person'),
      actions: [
        // Pending notice badge
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.pendingBadge,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Pending review',
            style: AppTextTheme.labelSmall.copyWith(
              color: AppColors.pendingBadgeText,
              fontSize: 10,
            ),
          ),
        ),
      ],
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
          Navigator.pop(context); // close sheet
          if (context.canPop()) {
            context.pop(); // go back to list
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
  final _factsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nationalityCtrl.dispose();
    _locationCtrl.dispose();
    _heightCtrl.dispose();
    _factsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info notice
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
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.pendingBadgeText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your report will be reviewed before it appears publicly. Only share verified information.',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.pendingBadgeText,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Name ───────────────────────────────────────
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (p, c) =>
                p.showErrors != c.showErrors || p.nameValid != c.nameValid,
            builder: (context, state) => FormSection(
              title: 'Full name *',
              child: TextFormField(
                controller: _nameCtrl,
                onChanged: (v) =>
                    context.read<ReportBloc>().add(ReportNameChanged(v)),
                style: AppTextTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'e.g. Maria da Silva',
                  errorText: state.showErrors && !state.nameValid
                      ? 'Name must be at least 2 characters'
                      : null,
                ),
              ),
            ),
          ),

          // ── Nationality ────────────────────────────────
          FormSection(
            title: 'Nationality',
            subtitle: 'ISO code, e.g. BR, PT, AO',
            child: TextFormField(
              controller: _nationalityCtrl,
              onChanged: (v) =>
                  context.read<ReportBloc>().add(ReportNationalityChanged(v)),
              style: AppTextTheme.bodyMedium,
              inputFormatters: [
                LengthLimitingTextInputFormatter(2),
                UpperCaseTextFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: 'BR',
                counterText: '',
              ),
            ),
          ),

          // ── Sex ────────────────────────────────────────
          FormSection(
            title: 'Sex',
            child: BlocBuilder<ReportBloc, ReportState>(
              buildWhen: (p, c) => p.sex != c.sex,
              builder: (context, state) => SexSelector(
                selected: state.sex,
                onChanged: (sex) =>
                    context.read<ReportBloc>().add(ReportSexChanged(sex)),
              ),
            ),
          ),

          // ── Date of birth ──────────────────────────────
          FormSection(
            title: 'Date of birth',
            child: BlocBuilder<ReportBloc, ReportState>(
              buildWhen: (p, c) => p.birthDate != c.birthDate,
              builder: (context, state) => DatePickerField(
                label: 'Date of birth',
                value: state.birthDate,
                lastDate: DateTime.now(),
                onChanged: (d) =>
                    context.read<ReportBloc>().add(ReportBirthDateChanged(d)),
              ),
            ),
          ),

          // ── Last seen date ─────────────────────────────
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (p, c) =>
                p.lastSeenDate != c.lastSeenDate ||
                p.showErrors != c.showErrors,
            builder: (context, state) => FormSection(
              title: 'Last seen date *',
              child: DatePickerField(
                label: 'Last seen date',
                value: state.lastSeenDate,
                lastDate: DateTime.now(),
                errorText: state.showErrors && !state.lastSeenDateValid
                    ? 'Please select the last seen date'
                    : null,
                onChanged: (d) => context
                    .read<ReportBloc>()
                    .add(ReportLastSeenDateChanged(d)),
              ),
            ),
          ),

          // ── Last seen location ─────────────────────────
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (p, c) =>
                p.showErrors != c.showErrors ||
                p.lastSeenLocationValid != c.lastSeenLocationValid,
            builder: (context, state) => FormSection(
              title: 'Last seen location *',
              child: TextFormField(
                controller: _locationCtrl,
                onChanged: (v) => context
                    .read<ReportBloc>()
                    .add(ReportLastLocationChanged(v)),
                style: AppTextTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'e.g. Lisbon, Portugal',
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.textMuted),
                  errorText: state.showErrors && !state.lastSeenLocationValid
                      ? 'Please enter a location'
                      : null,
                ),
              ),
            ),
          ),

          // ── Height ─────────────────────────────────────
          FormSection(
            title: 'Height (cm)',
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
              decoration: const InputDecoration(
                hintText: '170',
                suffixText: 'cm',
              ),
            ),
          ),

          // ── Photos ─────────────────────────────────────
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (p, c) => p.localPhotoPaths != c.localPhotoPaths,
            builder: (context, state) => FormSection(
              title: 'Photos',
              subtitle: 'Up to 5 photos (tap to add)',
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

          // ── Additional details ─────────────────────────
          FormSection(
            title: 'Additional details',
            subtitle: 'One detail per line',
            child: TextFormField(
              controller: _factsCtrl,
              onChanged: (v) =>
                  context.read<ReportBloc>().add(ReportFactsChanged(v)),
              maxLines: 5,
              style: AppTextTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Was wearing a red jacket\nHas a scar on left hand',
                alignLabelWithHint: true,
              ),
            ),
          ),

          // Required fields note
          Text(
            '* Required fields',
            style: AppTextTheme.caption,
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: BlocBuilder<ReportBloc, ReportState>(
          buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
          builder: (context, state) => ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.read<ReportBloc>().add(const ReportSubmitted()),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.textOnRed,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Submit report'),
          ),
        ),
      ),
    );
  }
}

// ── Success bottom sheet ───────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  final VoidCallback onDone;

  const _SuccessSheet({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 32, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 20),
          Text('Report submitted',
              style: AppTextTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Thank you. Your report is under review and will appear publicly once approved.',
            style: AppTextTheme.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onDone,
            child: const Text('Back to cases'),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────

/// Forces input to uppercase (for nationality field).
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue updated) {
    return updated.copyWith(text: updated.text.toUpperCase());
  }
}
