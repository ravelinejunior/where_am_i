import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:where_am_i/features/missing_persons/domain/value_objects/missing_person_filter.dart';

import '../../../../../../core/enums/enums.dart';
import '../../../../../../core/theme/theme.dart';

class FilterBottomSheet extends StatefulWidget {
  final MissingPersonFilter currentFilter;

  const FilterBottomSheet({super.key, required this.currentFilter});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late MissingPersonFilter _filter;

  // Common nationalities for the target audience
  static const _nationalities = [
    ('BR', '🇧🇷 Brazil'),
    ('PT', '🇵🇹 Portugal'),
    ('AO', '🇦🇴 Angola'),
    ('MZ', '🇲🇿 Mozambique'),
    ('CV', '🇨🇻 Cape Verde'),
    ('CO', '🇨🇴 Colombia'),
    ('VE', '🇻🇪 Venezuela'),
    ('PE', '🇵🇪 Peru'),
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text('Filters', style: AppTextTheme.headlineSmall),
                  const Spacer(),
                  if (_filter.hasActiveFilters)
                    TextButton(
                      onPressed: () => setState(
                        () => _filter = MissingPersonFilter.initial(),
                      ),
                      child: Text(
                        'Clear all',
                        style: AppTextTheme.labelLarge.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: controller,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _Section(
                    title: 'SEX',
                    child: _SexFilter(
                      selected: _filter.sex,
                      onChanged: (sex) => setState(() => _filter =
                          _filter.copyWith(sex: sex, clearSex: sex == null)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'NATIONALITY',
                    child: _NationalityFilter(
                      selected: _filter.nationalities,
                      nationalities: _nationalities,
                      onChanged: (list) => setState(() =>
                          _filter = _filter.copyWith(nationalities: list)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'AGE RANGE',
                    child: _AgeRangeFilter(
                      minAge: _filter.minAge,
                      maxAge: _filter.maxAge,
                      onChanged: (min, max) => setState(
                        () => _filter =
                            _filter.copyWith(minAge: min, maxAge: max),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'LAST SEEN AFTER',
                    child: _DateFilter(
                      date: _filter.lastSeenAfter,
                      onChanged: (date) => setState(
                        () => _filter = _filter.copyWith(
                          lastSeenAfter: date,
                          clearLastSeen: date == null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'SOURCE',
                    child: _SourceFilter(
                      selected: _filter.sources,
                      onChanged: (sources) => setState(
                          () => _filter = _filter.copyWith(sources: sources)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Apply button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_filter),
                  child: const Text('Apply filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section wrapper ────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextTheme.overline),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ── Sex filter ─────────────────────────────────────────────────

class _SexFilter extends StatelessWidget {
  final PersonSex? selected;
  final ValueChanged<PersonSex?> onChanged;

  const _SexFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _FilterChip(
          label: 'All',
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
        ...PersonSex.values.map(
          (s) => _FilterChip(
            label: s.label,
            selected: selected == s,
            onTap: () => onChanged(s == selected ? null : s),
          ),
        ),
      ],
    );
  }
}

// ── Nationality filter ─────────────────────────────────────────

class _NationalityFilter extends StatelessWidget {
  final List<String> selected;
  final List<(String, String)> nationalities;
  final ValueChanged<List<String>> onChanged;

  const _NationalityFilter({
    required this.selected,
    required this.nationalities,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: nationalities.map((entry) {
        final (code, label) = entry;
        final isSelected = selected.contains(code);
        return _FilterChip(
          label: label,
          selected: isSelected,
          onTap: () {
            final updated = isSelected
                ? selected.where((c) => c != code).toList()
                : [...selected, code];
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}

// ── Age range filter ───────────────────────────────────────────

class _AgeRangeFilter extends StatefulWidget {
  final int? minAge;
  final int? maxAge;
  final void Function(int?, int?) onChanged;

  const _AgeRangeFilter({
    required this.minAge,
    required this.maxAge,
    required this.onChanged,
  });

  @override
  State<_AgeRangeFilter> createState() => _AgeRangeFilterState();
}

class _AgeRangeFilterState extends State<_AgeRangeFilter> {
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _range = RangeValues(
      (widget.minAge ?? 0).toDouble(),
      (widget.maxAge ?? 100).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDefault = _range.start == 0 && _range.end == 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isDefault
                  ? 'Any age'
                  : '${_range.start.round()} – ${_range.end.round()} years',
              style: AppTextTheme.bodySmall,
            ),
            if (!isDefault)
              GestureDetector(
                onTap: () {
                  setState(() => _range = const RangeValues(0, 100));
                  widget.onChanged(null, null);
                },
                child: Text(
                  'Reset',
                  style: AppTextTheme.labelSmall.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            thumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceVariant,
            overlayColor: AppColors.primary.withValues(alpha: 0.15),
            trackHeight: 3,
          ),
          child: RangeSlider(
            values: _range,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (val) {
              setState(() => _range = val);
              widget.onChanged(
                val.start.round() == 0 ? null : val.start.round(),
                val.end.round() == 100 ? null : val.end.round(),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Date filter ────────────────────────────────────────────────

class _DateFilter extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  const _DateFilter({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    date ?? DateTime.now().subtract(const Duration(days: 365)),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: AppColors.primary,
                        ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    date != null
                        ? DateFormat('dd MMM yyyy').format(date!)
                        : 'Any date',
                    style: AppTextTheme.bodyMedium.copyWith(
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (date != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onChanged(null),
            child: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

// ── Source filter ──────────────────────────────────────────────

class _SourceFilter extends StatelessWidget {
  final List<MissingPersonSource> selected;
  final ValueChanged<List<MissingPersonSource>> onChanged;

  const _SourceFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: MissingPersonSource.values
          .where((s) => s != MissingPersonSource.merged)
          .map((source) {
        final isSelected = selected.contains(source);
        return _FilterChip(
          label: source.label,
          selected: isSelected,
          onTap: () {
            if (isSelected && selected.length == 1) return; // keep at least one
            final updated = isSelected
                ? selected.where((s) => s != source).toList()
                : [...selected, source];
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}

// ── Reusable chip ──────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextTheme.labelMedium.copyWith(
            color: selected ? AppColors.textOnRed : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
