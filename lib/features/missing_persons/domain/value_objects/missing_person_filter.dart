import 'package:equatable/equatable.dart';
import 'package:where_am_i/core/enums/enums.dart';

/// Encapsulates all filter parameters for the missing persons list.
/// Immutable value object — use [copyWith] to derive new instances.
class MissingPersonFilter extends Equatable {
  final String? searchQuery;

  /// ISO-3166 alpha-2 nationality codes to include (empty = all)
  final List<String> nationalities;

  final PersonSex? sex;

  final int? minAge;
  final int? maxAge;

  final int? minBirthYear;
  final int? maxBirthYear;

  /// Only show cases where lastSeenDate is after this date
  final DateTime? lastSeenAfter;

  /// Only show cases where lastSeenDate is before this date
  final DateTime? lastSeenBefore;

  final List<MissingPersonSource> sources;

  final SortOrder sortOrder;

  final int page;
  final int pageSize;

  const MissingPersonFilter({
    this.searchQuery,
    this.nationalities = const [],
    this.sex,
    this.minAge,
    this.maxAge,
    this.minBirthYear,
    this.maxBirthYear,
    this.lastSeenAfter,
    this.lastSeenBefore,
    this.sources = const [
      MissingPersonSource.interpol,
      MissingPersonSource.firebase,
    ],
    this.sortOrder = SortOrder.newestFirst,
    this.page = 1,
    this.pageSize = 20,
  });

  /// Default filter — show all sources, newest first, page 1.
  factory MissingPersonFilter.initial() => const MissingPersonFilter();

  bool get hasActiveFilters =>
      searchQuery != null && searchQuery!.isNotEmpty ||
      nationalities.isNotEmpty ||
      sex != null ||
      minAge != null ||
      maxAge != null ||
      minBirthYear != null ||
      maxBirthYear != null ||
      lastSeenAfter != null ||
      lastSeenBefore != null;

  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (nationalities.isNotEmpty) count++;
    if (sex != null) count++;
    if (minAge != null || maxAge != null) count++;
    if (minBirthYear != null || maxBirthYear != null) count++;
    if (lastSeenAfter != null || lastSeenBefore != null) count++;
    return count;
  }

  MissingPersonFilter copyWith({
    String? searchQuery,
    List<String>? nationalities,
    PersonSex? sex,
    int? minAge,
    int? maxAge,
    int? minBirthYear,
    int? maxBirthYear,
    DateTime? lastSeenAfter,
    DateTime? lastSeenBefore,
    List<MissingPersonSource>? sources,
    SortOrder? sortOrder,
    int? page,
    int? pageSize,
    bool clearSearch = false,
    bool clearSex = false,
    bool clearAgeRange = false,
    bool clearBirthYear = false,
    bool clearLastSeen = false,
  }) {
    return MissingPersonFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      nationalities: nationalities ?? this.nationalities,
      sex: clearSex ? null : (sex ?? this.sex),
      minAge: clearAgeRange ? null : (minAge ?? this.minAge),
      maxAge: clearAgeRange ? null : (maxAge ?? this.maxAge),
      minBirthYear: clearBirthYear ? null : (minBirthYear ?? this.minBirthYear),
      maxBirthYear: clearBirthYear ? null : (maxBirthYear ?? this.maxBirthYear),
      lastSeenAfter:
          clearLastSeen ? null : (lastSeenAfter ?? this.lastSeenAfter),
      lastSeenBefore:
          clearLastSeen ? null : (lastSeenBefore ?? this.lastSeenBefore),
      sources: sources ?? this.sources,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Returns a fresh copy reset to page 1 (used when filters change).
  MissingPersonFilter resetPage() => copyWith(page: 1);

  /// Returns a completely cleared filter.
  MissingPersonFilter cleared() => const MissingPersonFilter();

  @override
  List<Object?> get props => [
        searchQuery,
        nationalities,
        sex,
        minAge,
        maxAge,
        minBirthYear,
        maxBirthYear,
        lastSeenAfter,
        lastSeenBefore,
        sources,
        sortOrder,
        page,
        pageSize,
      ];
}
