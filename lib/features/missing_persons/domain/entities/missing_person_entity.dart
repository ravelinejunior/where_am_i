import 'package:equatable/equatable.dart';
import 'package:where_am_i/core/enums/enums.dart';

/// Unified domain model representing a missing person.
/// Normalises data from both Interpol Yellow Notices and Firestore community reports.
class MissingPersonEntity extends Equatable {
  final String id;

  /// Display name — "SURNAME, Forename" from Interpol or full name from Firestore
  final String name;

  final String? forename;
  final String? surname;

  /// Nationality ISO-3166 alpha-2 code (e.g. "BR", "PT")
  final String? nationality;

  final DateTime? birthDate;

  /// Date person was last seen / notice issued
  final DateTime? lastSeenDate;

  final String? lastSeenLocation;

  final PersonSex sex;

  /// Height in centimetres
  final int? heightCm;

  /// Weight in kilograms
  final int? weightKg;

  final String? eyeColor;
  final String? hairColor;

  /// List of distinct facts / details about the case
  final List<String> facts;

  /// Contact points (e.g. police number, NGO, family)
  final List<CaseContact> contacts;

  /// Ordered list of photo URLs
  final List<String> photoUrls;

  final MissingPersonSource source;
  final CaseStatus status;

  /// External URL to the Interpol notice page (if source == interpol)
  final String? externalUrl;

  /// Firestore document ID (if source == firebase)
  final String? firestoreId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MissingPersonEntity({
    required this.id,
    required this.name,
    this.forename,
    this.surname,
    this.nationality,
    this.birthDate,
    this.lastSeenDate,
    this.lastSeenLocation,
    this.sex = PersonSex.unknown,
    this.heightCm,
    this.weightKg,
    this.eyeColor,
    this.hairColor,
    this.facts = const [],
    this.contacts = const [],
    this.photoUrls = const [],
    required this.source,
    this.status = CaseStatus.approved,
    this.externalUrl,
    this.firestoreId,
    this.createdAt,
    this.updatedAt,
  });

  /// Estimated age in years from birthDate, or null if unknown.
  int? get estimatedAge {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Whether this entity has any photos to display.
  bool get hasPhotos => photoUrls.isNotEmpty;

  /// First photo URL or null.
  String? get primaryPhotoUrl => photoUrls.isNotEmpty ? photoUrls.first : null;

  /// Display-friendly location string.
  String get locationDisplay => lastSeenLocation ?? 'Unknown location';

  /// Short display label for the source badge.
  String get sourceLabel => source.label;

  MissingPersonEntity copyWith({
    String? id,
    String? name,
    String? forename,
    String? surname,
    String? nationality,
    DateTime? birthDate,
    DateTime? lastSeenDate,
    String? lastSeenLocation,
    PersonSex? sex,
    int? heightCm,
    int? weightKg,
    String? eyeColor,
    String? hairColor,
    List<String>? facts,
    List<CaseContact>? contacts,
    List<String>? photoUrls,
    MissingPersonSource? source,
    CaseStatus? status,
    String? externalUrl,
    String? firestoreId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MissingPersonEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      forename: forename ?? this.forename,
      surname: surname ?? this.surname,
      nationality: nationality ?? this.nationality,
      birthDate: birthDate ?? this.birthDate,
      lastSeenDate: lastSeenDate ?? this.lastSeenDate,
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
      facts: facts ?? this.facts,
      contacts: contacts ?? this.contacts,
      photoUrls: photoUrls ?? this.photoUrls,
      source: source ?? this.source,
      status: status ?? this.status,
      externalUrl: externalUrl ?? this.externalUrl,
      firestoreId: firestoreId ?? this.firestoreId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        forename,
        surname,
        nationality,
        birthDate,
        lastSeenDate,
        lastSeenLocation,
        sex,
        heightCm,
        weightKg,
        eyeColor,
        hairColor,
        facts,
        contacts,
        photoUrls,
        source,
        status,
        externalUrl,
        firestoreId,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'MissingPersonEntity(id: $id, name: $name, source: $source)';
}

/// A contact entry on a case (e.g. police line, NGO hotline, family email)
class CaseContact extends Equatable {
  final String label;
  final String value;
  final ContactType type;

  const CaseContact({
    required this.label,
    required this.value,
    this.type = ContactType.other,
  });

  @override
  List<Object?> get props => [label, value, type];
}

enum ContactType {
  phone,
  email,
  website,
  other;

  bool get isCallable => this == ContactType.phone;
  bool get isLaunchable =>
      this == ContactType.website || this == ContactType.email;

  String get uriScheme {
    switch (this) {
      case ContactType.phone:
        return 'tel:';
      case ContactType.email:
        return 'mailto:';
      case ContactType.website:
        return '';
      case ContactType.other:
        return '';
    }
  }
}
