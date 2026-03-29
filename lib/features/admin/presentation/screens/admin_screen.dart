import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_am_i/features/auth/presentation/bloc/auth_bloc.dart';

import '../bloc/admin_bloc.dart';
import '../widgets/admin_case_card.dart';
import '../../../missing_persons/presentation/widgets/empty_state.dart';
import '../../../missing_persons/presentation/widgets/missing_person_card_shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic admin guard — only show to authenticated users
    // In production you'd check a Firestore admin claim
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, auth) {
        if (!auth.isAuthenticated) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              title: const Text('Admin'),
            ),
            body: const Center(
              child: Text('Admin access required.',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          );
        }

        return BlocProvider(
          create: (_) => AdminBloc(
            getPendingCases: sl(),
            updateCaseStatus: sl(),
          )..add(const AdminPendingCasesLoaded()),
          child: const _AdminView(),
        );
      },
    );
  }
}

class _AdminView extends StatelessWidget {
  const _AdminView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listenWhen: (p, c) =>
          c.lastActionMessage != null &&
          p.lastActionMessage != c.lastActionMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(state.lastActionMessage!),
          backgroundColor: AppColors.surface,
        ));
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Admin — Pending cases'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => context
                  .read<AdminBloc>()
                  .add(const AdminPendingCasesLoaded()),
            ),
          ],
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state.isLoading) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const MissingPersonCardShimmer(),
              );
            }

            if (state.status == AdminStatus.failure) {
              return EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Could not load cases',
                subtitle: state.errorMessage ?? 'Try again.',
                retryLabel: 'Retry',
                onRetry: () => context
                    .read<AdminBloc>()
                    .add(const AdminPendingCasesLoaded()),
              );
            }

            if (state.isEmpty) {
              return const EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'All caught up',
                subtitle: 'No pending cases to review.',
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                context.read<AdminBloc>().add(const AdminPendingCasesLoaded());
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.cases.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final person = state.cases[i];
                  final id = person.firestoreId ?? person.id;
                  return AdminCaseCard(
                    person: person,
                    isProcessing: state.isProcessing(id),
                    onApprove: () =>
                        context.read<AdminBloc>().add(AdminCaseApproved(id)),
                    onReject: () => _confirmReject(context, id, person.name),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmReject(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject case?', style: AppTextTheme.headlineSmall),
        content: Text(
          'This will reject the report for "$name". The submitter will not be notified.',
          style: AppTextTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextTheme.labelLarge
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(AdminCaseRejected(id));
            },
            child: Text('Reject',
                style:
                    AppTextTheme.labelLarge.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
