import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/list/missing_list_bloc.dart';
import '../widgets/missing_person_card.dart';
import '../widgets/missing_person_card_shimmer.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/empty_state.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/enums/enums.dart';
import '../../../../../../core/router/route_names.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/constants/app_constants.dart';

class MissingListScreen extends StatelessWidget {
  const MissingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissingListBloc(getMissingPersons: sl())
        ..add(const MissingListFetched()),
      child: const _MissingListView(),
    );
  }
}

class _MissingListView extends StatefulWidget {
  const _MissingListView();

  @override
  State<_MissingListView> createState() => _MissingListViewState();
}

class _MissingListViewState extends State<_MissingListView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MissingListBloc>().add(const MissingListNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    return current >= maxScroll - 300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, innerBoxIsScrolled),
        ],
        body: BlocBuilder<MissingListBloc, MissingListState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                context.read<MissingListBloc>().add(const MissingListFetched());
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: _buildBody(context, state),
            );
          },
        ),
      ),
      floatingActionButton: const _SosButton(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      expandedHeight: 120,
      collapsedHeight: 60,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: AppColors.textOnRed,
                size: 13,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Where Am I?',
              style: AppTextTheme.headlineMedium.copyWith(fontSize: 17),
            ),
          ],
        ),
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: BlocBuilder<MissingListBloc, MissingListState>(
              buildWhen: (p, c) => p.persons.length != c.persons.length,
              builder: (_, state) => Text(
                state.isSuccess
                    ? '${state.persons.length} cases found'
                    : 'Missing persons registry',
                style: AppTextTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
      actions: [
        BlocBuilder<MissingListBloc, MissingListState>(
          buildWhen: (p, c) => p.filter.sortOrder != c.filter.sortOrder,
          builder: (context, state) => _SortButton(
            current: state.filter.sortOrder,
            onSelected: (order) => context
                .read<MissingListBloc>()
                .add(MissingListSortChanged(order)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.pushNamed(RouteNames.settingsName),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _SearchBar(
          controller: _searchController,
          onChanged: (q) => context
              .read<MissingListBloc>()
              .add(MissingListSearchChanged(q)),
          onFilterTap: () => _openFilterSheet(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MissingListState state) {
    if (state.isLoading) return _ShimmerList();

    if (state.isFailure && state.persons.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load cases',
        subtitle: state.errorMessage ?? 'Check your connection and try again.',
        retryLabel: 'Retry',
        onRetry: () =>
            context.read<MissingListBloc>().add(const MissingListFetched()),
      );
    }

    if (state.isEmpty) {
      return EmptyState(
        title: 'No cases found',
        subtitle: state.filter.hasActiveFilters
            ? 'Try adjusting your filters.'
            : 'No missing persons found for the selected criteria.',
        retryLabel:
            state.filter.hasActiveFilters ? 'Clear filters' : null,
        onRetry: state.filter.hasActiveFilters
            ? () => context
                .read<MissingListBloc>()
                .add(const MissingListFilterCleared())
            : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: state.persons.length + (state.isLoadingMore ? 3 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= state.persons.length) {
          return const MissingPersonCardShimmer();
        }
        final person = state.persons[index];
        return MissingPersonCard(
          person: person,
          onTap: () => context.pushNamed(
            RouteNames.missingDetailName,
            pathParameters: {'id': person.id},
            extra: person,
          ),
        );
      },
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final bloc = context.read<MissingListBloc>();
    final currentFilter = bloc.state.filter;

    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(currentFilter: currentFilter),
    );

    if (result != null) {
      bloc.add(MissingListFilterChanged(result));
    }
  }
}

// ── Search bar ─────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTextTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search by name or location...',
                  hintStyle: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (_, value, __) => value.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () { controller.clear(); onChanged(''); },
                            child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          BlocBuilder<MissingListBloc, MissingListState>(
            buildWhen: (p, c) => p.filter.activeFilterCount != c.filter.activeFilterCount,
            builder: (_, state) => _FilterButton(
              activeCount: state.filter.activeFilterCount,
              onTap: onFilterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasFilters = activeCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: hasFilters ? AppColors.primaryDark : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasFilters ? AppColors.primary : AppColors.border,
            width: hasFilters ? 1 : 0.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.tune_rounded, size: 18,
              color: hasFilters ? AppColors.textOnRed : AppColors.textSecondary),
            if (hasFilters)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryDark, width: 1.5),
                  ),
                  child: Center(
                    child: Text('$activeCount',
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textOnRed)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Sort button ────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final SortOrder current;
  final ValueChanged<SortOrder> onSelected;

  const _SortButton({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOrder>(
      icon: const Icon(Icons.sort_rounded, size: 20),
      color: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
      itemBuilder: (_) => SortOrder.values.map((order) => PopupMenuItem(
        value: order,
        child: Row(children: [
          if (current == order)
            const Icon(Icons.check_rounded, size: 16, color: AppColors.primary)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(order.label, style: AppTextTheme.bodyMedium),
        ]),
      )).toList(),
    );
  }
}

// ── Shimmer list ───────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const MissingPersonCardShimmer(),
    );
  }
}

// ── SOS FAB ────────────────────────────────────────────────────

class _SosButton extends StatelessWidget {
  const _SosButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showSosDialog(context),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnRed,
      elevation: 4,
      icon: const Icon(Icons.sos_rounded, size: 20),
      label: Text('SOS', style: AppTextTheme.labelLarge.copyWith(color: AppColors.textOnRed)),
    );
  }

  void _showSosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.sos_rounded, color: AppColors.textOnRed, size: 18),
          ),
          const SizedBox(width: 12),
          Text('Emergency', style: AppTextTheme.headlineSmall),
        ]),
        content: Text(
          'If you have information about a missing person or are in danger, call emergency services immediately.',
          style: AppTextTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextTheme.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(AppConstants.emergencyNumber);
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            icon: const Icon(Icons.call_rounded, size: 16),
            label: const Text('Call 112'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
          ),
        ],
      ),
    );
  }
}
