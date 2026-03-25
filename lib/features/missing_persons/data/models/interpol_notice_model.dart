import '../../domain/entities/missing_person_entity.dart';
import '../../../../core/enums/enums.dart';

/// Maps a Yellow Notice JSON response from the Interpol public API.
///
/// Example response shape:
/// ```json
/// {
///   "entity_id": "2019/12345",
///   "forename": "JOAO",
///   "name": "DA SILVA",
///   "date_of_birth": "1990-05-12",
///   "nationalities": ["BR"],
///   "sex_id": "M",
///   "country_of_birth_id": "BR",
///   "_links": {
///     "self": { "href": "https://ws-public.interpol.int/notices/v1/yellow/2019-12345" },
///     "images": { "href": "..." },
///     "thumbnail": { "href": "..." }
///   }
/// }
/// ```
class InterpolNoticeModel {
  final String entityId;
  final String? forename;
  final String? surname;
  final String? dateOfBirth;
  final List<String> nationalities;
  final String? sexId;
  final String? placeOfBirth;
  final String? countryOfBirth;
  final String? distinguishingMarks;
  final String? eyeColorsId;
  final String? hairColorsId;
  final String? heightM;
  final String? weightKg;
  final String? selfLink;
  final String? thumbnailUrl;
  final List<String> imageUrls;

  // Detail-only fields (from /yellow/{id} endpoint)
  final String? arrestWarrantCountry;
  final List<String> chargeTranslations;

  const InterpolNoticeModel({
    required this.entityId,
    this.forename,
    this.surname,
    this.dateOfBirth,
    this.nationalities = const [],
    this.sexId,
    this.placeOfBirth,
    this.countryOfBirth,
    this.distinguishingMarks,
    this.eyeColorsId,
    this.hairColorsId,
    this.heightM,
    this.weightKg,
    this.selfLink,
    this.thumbnailUrl,
    this.imageUrls = const [],
    this.arrestWarrantCountry,
    this.chargeTranslations = const [],
  });

  factory InterpolNoticeModel.fromJson(Map<String, dynamic> json) {
    final links = json['_links'] as Map<String, dynamic>? ?? {};
    final selfHref = (links['self'] as Map<String, dynamic>?)?['href'] as String?;
    final thumbnailHref =
        (links['thumbnail'] as Map<String, dynamic>?)?['href'] as String?;

    return InterpolNoticeModel(
      entityId: json['entity_id'] as String? ?? '',
      forename: json['forename'] as String?,
      surname: json['name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      nationalities: _parseStringList(json['nationalities']),
      sexId: json['sex_id'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      countryOfBirth: json['country_of_birth_id'] as String?,
      distinguishingMarks: json['distinguishing_marks'] as String?,
      eyeColorsId: json['eyes_colors_id'] as String?,
      hairColorsId: json['hairs_id'] as String?,
      heightM: json['height'] as String?,
      weightKg: json['weight'] as String?,
      selfLink: selfHref,
      thumbnailUrl: thumbnailHref,
      imageUrls: const [],
      chargeTranslations: _parseTranslations(json['charges_translation']),
    );
  }

  /// Builds a model from the detail endpoint response (richer data).
  factory InterpolNoticeModel.fromDetailJson(
    Map<String, dynamic> json,
    List<String> fetchedImageUrls,
  ) {
    final base = InterpolNoticeModel.fromJson(json);
    return InterpolNoticeModel(
      entityId: base.entityId,
      forename: base.forename,
      surname: base.surname,
      dateOfBirth: base.dateOfBirth,
      nationalities: base.nationalities,
      sexId: base.sexId,
      placeOfBirth: base.placeOfBirth,
      countryOfBirth: base.countryOfBirth,
      distinguishingMarks: base.distinguishingMarks,
      eyeColorsId: base.eyeColorsId,
      hairColorsId: base.hairColorsId,
      heightM: base.heightM,
      weightKg: base.weightKg,
      selfLink: base.selfLink,
      thumbnailUrl: base.thumbnailUrl,
      imageUrls: fetchedImageUrls,
      chargeTranslations: base.chargeTranslations,
    );
  }

  /// Converts to the unified domain entity.
  MissingPersonEntity toEntity() {
    final displayName = _buildDisplayName();
    final nationality = nationalities.isNotEmpty ? nationalities.first : null;

    return MissingPersonEntity(
      id: _normaliseId(entityId),
      name: displayName,
      forename: forename,
      surname: surname,
      nationality: nationality,
      birthDate: _parseDate(dateOfBirth),
      sex: PersonSex.fromInterpolId(sexId),
      heightCm: _parseHeightToCm(heightM),
      weightKg: _parseWeightToInt(weightKg),
      eyeColor: eyeColorsId,
      hairColor: hairColorsId,
      facts: _buildFacts(),
      contacts: _buildContacts(),
      photoUrls: imageUrls.isNotEmpty
          ? imageUrls
          : (thumbnailUrl != null ? [thumbnailUrl!] : []),
      source: MissingPersonSource.interpol,
      status: CaseStatus.approved,
      externalUrl: selfLink?.replaceFirst(
        'ws-public.interpol.int/notices/v1',
        'www.interpol.int/en/How-we-work/Notices/Yellow-Notices/View-Yellow-Notices',
      ),
    );
  }

  // --- Private helpers ---

  String _buildDisplayName() {
    final parts = <String>[];
    if (surname != null && surname!.isNotEmpty) parts.add(surname!.toUpperCase());
    if (forename != null && forename!.isNotEmpty) {
      parts.add(_titleCase(forename!));
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown';
  }

  List<String> _buildFacts() {
    final facts = <String>[];
    if (placeOfBirth != null) facts.add('Place of birth: $placeOfBirth');
    if (countryOfBirth != null) facts.add('Country of birth: $countryOfBirth');
    if (distinguishingMarks != null && distinguishingMarks!.isNotEmpty) {
      facts.add('Distinguishing marks: $distinguishingMarks');
    }
    for (final charge in chargeTranslations) {
      if (charge.isNotEmpty) facts.add(charge);
    }
    return facts;
  }

  List<CaseContact> _buildContacts() {
    return [
      const CaseContact(
        label: 'INTERPOL',
        value: 'https://www.interpol.int/en/What-you-can-do/Help-us-find',
        type: ContactType.website,
      ),
    ];
  }

  static String _normaliseId(String id) => id.replaceAll('/', '-');

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  static int? _parseHeightToCm(String? heightStr) {
    if (heightStr == null) return null;
    final val = double.tryParse(heightStr);
    if (val == null) return null;
    // Interpol returns metres (e.g. "1.75"), convert to cm
    return val > 10 ? val.round() : (val * 100).round();
  }

  static int? _parseWeightToInt(String? weightStr) {
    if (weightStr == null) return null;
    return int.tryParse(weightStr);
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static List<String> _parseTranslations(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((e) => e['value']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  static String _titleCase(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

/// Maps the Interpol list response envelope.
class InterpolNoticeListResponse {
  final List<InterpolNoticeModel> notices;
  final int total;
  final int page;
  final int? nextPage;

  const InterpolNoticeListResponse({
    required this.notices,
    required this.total,
    required this.page,
    this.nextPage,
  });

  factory InterpolNoticeListResponse.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'] as Map<String, dynamic>? ?? {};
    final rawNotices = embedded['notices'] as List<dynamic>? ?? [];

    final notices = rawNotices
        .whereType<Map<String, dynamic>>()
        .map(InterpolNoticeModel.fromJson)
        .toList();

    final query = json['query'] as Map<String, dynamic>? ?? {};
    final total = (json['total'] as num?)?.toInt() ?? notices.length;
    final page = (query['page'] as num?)?.toInt() ?? 1;

    return InterpolNoticeListResponse(
      notices: notices,
      total: total,
      page: page,
    );
  }
}
