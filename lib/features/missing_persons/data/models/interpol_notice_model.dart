import '../../domain/entities/missing_person_entity.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/utils/country_utils.dart';

/// Maps a Yellow Notice JSON from ws-public.interpol.int/notices/v1/yellow/{id}
///
/// Confirmed real JSON shape:
/// ```json
/// {
///   "entity_id": "2026-18615",
///   "name": "DOE",
///   "forename": "JOHN",
///   "date_of_birth": "2010-05-12",
///   "nationalities": ["FR"],
///   "sex_id": "M",
///   "height": 170,           <- INTEGER (cm directly, not metres)
///   "weight": 60,            <- INTEGER (kg)
///   "distinguishing_marks": "Scar on left cheek",
///   "languages_spoken_ids": ["ENG", "FRE"],
///   "place_of_birth": "Paris",
///   "missing_since": "2026-02-01",   <- date field (not date_of_last_known_location)
///   "case": {
///     "summary": "Missing minor",
///     "circumstances": "Last seen near school"
///   },
///   "_links": { "self": {...}, "images": {...} }
/// }
/// ```
class InterpolNoticeModel {
  final String entityId;
  final String? forename;
  final String? surname;
  final String? familyNameAtBirth;
  final String? dateOfBirth;
  final List<String> nationalities;
  final String? sexId;
  final String? placeOfBirth;
  final String? countryOfBirthId;
  final List<String> languagesSpokenIds;
  final String? distinguishingMarks;
  final String? eyeColorsId;
  final String? hairColorsId;

  /// Height in cm — API returns integer directly (e.g. 170)
  final int? heightCm;

  /// Weight in kg — API returns integer directly (e.g. 60)
  final int? weightKg;

  /// Last known location (place)
  final String? placeOfLastKnownLocation;

  /// Multiple possible date field names from the API
  final String? missingDate;

  final List<String> countriesOfVisitIds;
  final String? issuingCountryId;

  /// Case summary (from nested "case" object)
  final String? caseSummary;

  /// Case circumstances (from nested "case" object)
  final String? caseCircumstances;

  final String? selfLink;
  final String? thumbnailUrl;
  final List<String> imageUrls;

  const InterpolNoticeModel({
    required this.entityId,
    this.forename,
    this.surname,
    this.familyNameAtBirth,
    this.dateOfBirth,
    this.nationalities = const [],
    this.sexId,
    this.placeOfBirth,
    this.countryOfBirthId,
    this.languagesSpokenIds = const [],
    this.distinguishingMarks,
    this.eyeColorsId,
    this.hairColorsId,
    this.heightCm,
    this.weightKg,
    this.placeOfLastKnownLocation,
    this.missingDate,
    this.countriesOfVisitIds = const [],
    this.issuingCountryId,
    this.caseSummary,
    this.caseCircumstances,
    this.selfLink,
    this.thumbnailUrl,
    this.imageUrls = const [],
  });

  factory InterpolNoticeModel.fromJson(Map<String, dynamic> json) {
    final links = json['_links'] as Map<String, dynamic>? ?? {};
    final selfHref =
        (links['self'] as Map<String, dynamic>?)?['href'] as String?;
    final thumbnailHref =
        (links['thumbnail'] as Map<String, dynamic>?)?['href'] as String?;

    // Nested "case" object
    final caseObj = json['case'] as Map<String, dynamic>?;

    // Height: API returns integer cm (170) OR string metres ("1.75") OR null
    final heightRaw = json['height'];
    final int? heightCm = _parseHeight(heightRaw);

    // Weight: API returns integer kg (60) OR string OR null
    final int? weightKg = _parseInt(json['weight']);

    // Date of disappearance — try all known field names
    final String? missingDate = _clean(
      json['missing_since'] ??
          json['date_of_last_known_location'] ??
          json['date_of_disappearance'] ??
          json['last_seen_date'],
    );

    // Place — try all known field names
    final String? placeOfLastKnownLocation = _clean(
      json['place_of_last_known_location'] ??
          json['place_of_disappearance'] ??
          json['last_seen_location'],
    );

    return InterpolNoticeModel(
      entityId: _clean(json['entity_id']) ?? '',
      forename: _clean(json['forename']),
      surname: _clean(json['name']),
      familyNameAtBirth:
          _clean(json['family_name_at_birth'] ?? json['name_at_birth']),
      dateOfBirth: _clean(json['date_of_birth']),
      nationalities: _parseStringList(json['nationalities']),
      sexId: _clean(json['sex_id'] ?? json['gender'] ?? json['sex']),
      placeOfBirth: _clean(json['place_of_birth']),
      countryOfBirthId: _clean(json['country_of_birth_id']),
      languagesSpokenIds: _parseStringList(json['languages_spoken_ids']),
      distinguishingMarks: _clean(json['distinguishing_marks']),
      eyeColorsId: _clean(json['eyes_colors_id'] ?? json['eye_color']),
      hairColorsId: _clean(json['hairs_id'] ?? json['hair_color']),
      heightCm: heightCm,
      weightKg: weightKg,
      placeOfLastKnownLocation: placeOfLastKnownLocation,
      missingDate: missingDate,
      countriesOfVisitIds: _parseStringList(json['countries_of_visit_ids']),
      issuingCountryId: _clean(json['issuing_country_id']),
      caseSummary: _clean(caseObj?['summary']),
      caseCircumstances: _clean(caseObj?['circumstances']),
      selfLink: selfHref,
      thumbnailUrl: thumbnailHref,
      imageUrls: const [],
    );
  }

  factory InterpolNoticeModel.fromDetailJson(
    Map<String, dynamic> json,
    List<String> fetchedImageUrls,
  ) {
    final base = InterpolNoticeModel.fromJson(json);
    return InterpolNoticeModel(
      entityId: base.entityId,
      forename: base.forename,
      surname: base.surname,
      familyNameAtBirth: base.familyNameAtBirth,
      dateOfBirth: base.dateOfBirth,
      nationalities: base.nationalities,
      sexId: base.sexId,
      placeOfBirth: base.placeOfBirth,
      countryOfBirthId: base.countryOfBirthId,
      languagesSpokenIds: base.languagesSpokenIds,
      distinguishingMarks: base.distinguishingMarks,
      eyeColorsId: base.eyeColorsId,
      hairColorsId: base.hairColorsId,
      heightCm: base.heightCm,
      weightKg: base.weightKg,
      placeOfLastKnownLocation: base.placeOfLastKnownLocation,
      missingDate: base.missingDate,
      countriesOfVisitIds: base.countriesOfVisitIds,
      issuingCountryId: base.issuingCountryId,
      caseSummary: base.caseSummary,
      caseCircumstances: base.caseCircumstances,
      selfLink: base.selfLink,
      thumbnailUrl: base.thumbnailUrl,
      imageUrls: fetchedImageUrls,
    );
  }

  /// Public Interpol notice URL with anchor fragment.
  /// entity_id "2026-18615" → #2026-18615
  String get publicInterpolUrl {
    final anchor = _normaliseId(entityId);
    return 'https://www.interpol.int/en/How-we-work/Notices/'
        'Yellow-Notices/View-Yellow-Notices#$anchor';
  }

  MissingPersonEntity toEntity() {
    return MissingPersonEntity(
      id: _normaliseId(entityId),
      name: _buildDisplayName(),
      forename: forename,
      surname: surname,
      nationality: nationalities.isNotEmpty ? nationalities.first : null,
      birthDate: _parseDate(dateOfBirth),
      lastSeenDate: _parseDate(missingDate),
      lastSeenLocation: placeOfLastKnownLocation != null
          ? _titleCase(placeOfLastKnownLocation!)
          : null,
      sex: PersonSex.fromInterpolId(sexId),
      heightCm: heightCm,
      weightKg: weightKg,
      eyeColor: _humaniseId(eyeColorsId),
      hairColor: _humaniseId(hairColorsId),
      facts: _buildFacts(),
      contacts: _buildContacts(),
      photoUrls: imageUrls.isNotEmpty
          ? imageUrls
          : (thumbnailUrl != null ? [thumbnailUrl!] : []),
      source: MissingPersonSource.interpol,
      status: CaseStatus.approved,
      externalUrl: publicInterpolUrl,
    );
  }

  // ── Private helpers ────────────────────────────────────────────

  String _buildDisplayName() {
    final parts = <String>[];
    if (surname?.isNotEmpty == true) parts.add(surname!.toUpperCase());
    if (forename?.isNotEmpty == true) parts.add(_titleCase(forename!));
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown';
  }

  List<String> _buildFacts() {
    final facts = <String>[];

    // Case narrative (from nested "case" object)
    if (caseSummary?.isNotEmpty == true) {
      facts.add('Summary: $caseSummary');
    }
    if (caseCircumstances?.isNotEmpty == true) {
      facts.add('Circumstances: $caseCircumstances');
    }

    // Identity details
    if (familyNameAtBirth?.isNotEmpty == true && familyNameAtBirth != surname) {
      facts.add('Family name at birth: ${familyNameAtBirth!.toUpperCase()}');
    }
    if (placeOfBirth?.isNotEmpty == true) {
      facts.add('Place of birth: ${_titleCase(placeOfBirth!)}');
    }
    if (countryOfBirthId?.isNotEmpty == true) {
      facts.add(
          'Country of birth: ${CountryUtils.nameFromAlpha3(countryOfBirthId)}');
    }
    if (languagesSpokenIds.isNotEmpty) {
      final langs =
          languagesSpokenIds.map(CountryUtils.languageFromCode).join(', ');
      facts.add('Languages spoken: $langs');
    }
    if (countriesOfVisitIds.isNotEmpty) {
      final countries =
          countriesOfVisitIds.map(CountryUtils.nameFromAlpha3).join(', ');
      facts.add('Countries likely visited: $countries');
    }
    if (issuingCountryId?.isNotEmpty == true) {
      facts.add(
          'Issuing country: ${CountryUtils.nameFromAlpha3(issuingCountryId)}');
    }
    if (distinguishingMarks?.isNotEmpty == true) {
      facts.add('Distinguishing marks: $distinguishingMarks');
    }

    return facts;
  }

  List<CaseContact> _buildContacts() {
    return [
      CaseContact(
        label: 'View on INTERPOL',
        value: publicInterpolUrl,
        type: ContactType.website,
      ),
    ];
  }

  // ── Static helpers ─────────────────────────────────────────────

  static String _normaliseId(String id) => id.replaceAll('/', '-');

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Handles height as integer cm (170), double metres (1.75), or string.
  static int? _parseHeight(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) {
      // Already in cm if > 10, otherwise assume metres
      return raw > 10 ? raw : raw * 100;
    }
    if (raw is double) {
      return raw > 10 ? raw.round() : (raw * 100).round();
    }
    final s = raw.toString().trim();
    final d = double.tryParse(s);
    if (d == null) return null;
    return d > 10 ? d.round() : (d * 100).round();
  }

  /// Handles weight as integer kg, double, or string.
  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is double) return raw.round();
    return int.tryParse(raw.toString().trim());
  }

  static List<String> _parseStringList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  static String? _clean(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Converts Interpol color codes to human-readable labels.
  /// Handles both short codes (BRO, BLU) and long codes (AUBURN_OR_RED, DARK_BROWN).
  static String? _humaniseId(String? id) {
    if (id == null || id.isEmpty) return null;
    final upper = id.toUpperCase().trim();

    // ── Short 3-letter codes (used in most Yellow Notice responses) ──
    const shortCodes = {
      // Hair
      '[BLA]': 'Black',
      '[BLO]': 'Blonde',
      '[BRO]': 'Brown',
      '[GRY]': 'Grey',
      '[GRA]': 'Grey',
      '[RED]': 'Red',
      '[WHI]': 'White',
      '[BAL]': 'Bald',
      '[OTH]': 'Other',
      // Eyes
      '[BLU]': 'Blue',
      '[GRN]': 'Green',
      '[HAZ]': 'Hazel',
      '[AMB]': 'Amber',
      '[BROH]': 'Brown',
      '[GRYH]': 'Grey',
      '[OTHL]': 'Other',
      // Languages (also used via this helper)
      'ENG': 'English',
      'FRE': 'French',
      'SPA': 'Spanish',
      'POR': 'Portuguese',
      'GER': 'German',
      'ITA': 'Italian',
      'RUS': 'Russian',
      'ARA': 'Arabic',
      'CHI': 'Chinese',
      'JPN': 'Japanese',
    };

    if (shortCodes.containsKey(upper)) return shortCodes[upper]!;

    // ── Long underscore codes (e.g. AUBURN_OR_RED, DARK_BROWN) ──
    const longCodes = {
      'AUBURN_OR_RED': 'Auburn / Red',
      'DARK_BROWN': 'Dark brown',
      'LIGHT_BROWN': 'Light brown',
      'DARK_BLONDE': 'Dark blonde',
      'LIGHT_BLONDE': 'Light blonde',
      'SALT_AND_PEPPER': 'Salt and pepper',
      'DARK_GREY': 'Dark grey',
      'LIGHT_GREY': 'Light grey',
      'BLUE_GREY': 'Blue-grey',
      'GREEN_GREY': 'Green-grey',
      'DARK_GREEN': 'Dark green',
      'LIGHT_GREEN': 'Light green',
      'DARK_BLUE': 'Dark blue',
      'LIGHT_BLUE': 'Light blue',
      'HAZEL_GREEN': 'Hazel green',
      'HAZEL_BROWN': 'Hazel brown',
      'BLUE_GREEN': 'Blue-green',
      'NOT_AVAILABLE': null,
    };

    if (longCodes.containsKey(upper)) return longCodes[upper];

    // ── Fallback: convert underscores to spaces, title-case ──
    return upper
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static String _titleCase(String s) {
    return s.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}

class InterpolNoticeListResponse {
  final List<InterpolNoticeModel> notices;
  final int total;
  final int page;

  const InterpolNoticeListResponse({
    required this.notices,
    required this.total,
    required this.page,
  });

  factory InterpolNoticeListResponse.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'] as Map<String, dynamic>? ?? {};
    final rawNotices = embedded['notices'] as List<dynamic>? ?? [];
    final notices = rawNotices
        .whereType<Map<String, dynamic>>()
        .map(InterpolNoticeModel.fromJson)
        .toList();
    final total = (json['total'] as num?)?.toInt() ?? notices.length;
    final query = json['query'] as Map<String, dynamic>? ?? {};
    final page = (query['page'] as num?)?.toInt() ?? 1;
    return InterpolNoticeListResponse(
        notices: notices, total: total, page: page);
  }
}
