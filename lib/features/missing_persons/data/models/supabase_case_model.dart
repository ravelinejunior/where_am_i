import '../../domain/entities/missing_person_entity.dart';
import '../../../../core/enums/enums.dart';

/// Maps a Supabase `cases` table row to/from the domain entity.
///
/// SQL schema (run in Supabase SQL editor):
/// ```sql
/// create table public.cases (
///   id uuid primary key default gen_random_uuid(),
///   name text not null,
///   nationality text,
///   birth_date date,
///   last_seen_date date,
///   last_seen_location text,
///   sex char(1) default 'U',
///   height_cm int,
///   photo_urls text[] default '{}',
///   facts text[] default '{}',
///   contacts jsonb default '[]',
///   source text default 'user',
///   status text default 'pending',
///   reported_by uuid references auth.users(id),
///   created_at timestamptz default now(),
///   updated_at timestamptz default now()
/// );
///
/// -- Enable RLS
/// alter table public.cases enable row level security;
///
/// -- Anyone can read approved cases
/// create policy "Public read approved"
///   on public.cases for select
///   using (status = 'approved');
///
/// -- Authenticated users can insert
/// create policy "Auth insert"
///   on public.cases for insert
///   with check (auth.uid() = reported_by);
///
/// -- Only reporter or admin can update status
/// create policy "Reporter update"
///   on public.cases for update
///   using (auth.uid() = reported_by);
/// ```
class SupabaseCaseModel {
  final String id;
  final String name;
  final String? nationality;
  final DateTime? birthDate;
  final DateTime? lastSeenDate;
  final String? lastSeenLocation;
  final String sex;
  final int? heightCm;
  final List<String> photoUrls;
  final List<String> facts;
  final List<Map<String, dynamic>> contacts;
  final String source;
  final String status;
  final String? reportedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupabaseCaseModel({
    required this.id,
    required this.name,
    this.nationality,
    this.birthDate,
    this.lastSeenDate,
    this.lastSeenLocation,
    this.sex = 'U',
    this.heightCm,
    this.photoUrls = const [],
    this.facts = const [],
    this.contacts = const [],
    this.source = 'user',
    this.status = 'pending',
    this.reportedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory SupabaseCaseModel.fromRow(Map<String, dynamic> row) {
    return SupabaseCaseModel(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'Unknown',
      nationality: row['nationality'] as String?,
      birthDate: row['birth_date'] != null
          ? DateTime.tryParse(row['birth_date'].toString())
          : null,
      lastSeenDate: row['last_seen_date'] != null
          ? DateTime.tryParse(row['last_seen_date'].toString())
          : null,
      lastSeenLocation: row['last_seen_location'] as String?,
      sex: row['sex'] as String? ?? 'U',
      heightCm: (row['height_cm'] as num?)?.toInt(),
      photoUrls: _parseStringList(row['photo_urls']),
      facts: _parseStringList(row['facts']),
      contacts: _parseContactList(row['contacts']),
      source: row['source'] as String? ?? 'user',
      status: row['status'] as String? ?? 'pending',
      reportedBy: row['reported_by'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'].toString())
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.tryParse(row['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toInsert() {
    // sex check: DB only accepts 'M', 'F', 'U'
    final safeSex = ['M', 'F', 'U'].contains(sex) ? sex : 'U';

    // source check: DB only accepts 'user', 'admin'
    final safeSource = ['user', 'admin'].contains(source) ? source : 'user';

    // reported_by: only include if it looks like a UUID (not 'anonymous' or empty)
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    final safeReportedBy =
        (reportedBy != null && uuidRegex.hasMatch(reportedBy!))
            ? reportedBy
            : null;

    return {
      'name': name,
      if (nationality != null) 'nationality': nationality,
      if (birthDate != null)
        'birth_date': birthDate!.toIso8601String().substring(0, 10),
      if (lastSeenDate != null)
        'last_seen_date': lastSeenDate!.toIso8601String().substring(0, 10),
      if (lastSeenLocation != null) 'last_seen_location': lastSeenLocation,
      'sex': safeSex,
      if (heightCm != null) 'height_cm': heightCm,
      'photo_urls': photoUrls,
      'facts': facts,
      'contacts': contacts,
      'source': safeSource,
      'status': status,
      if (safeReportedBy != null) 'reported_by': safeReportedBy,
    };
  }

  MissingPersonEntity toEntity() {
    return MissingPersonEntity(
      id: id,
      firestoreId: id, // reusing firestoreId field as the Supabase row ID
      name: name,
      nationality: nationality,
      birthDate: birthDate,
      lastSeenDate: lastSeenDate,
      lastSeenLocation: lastSeenLocation,
      sex: PersonSex.fromFirestore(sex),
      heightCm: heightCm,
      photoUrls: photoUrls,
      facts: facts,
      contacts: contacts.map(_mapContact).toList(),
      source: MissingPersonSource.firebase,
      status: _parseStatus(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static SupabaseCaseModel fromEntity(
      MissingPersonEntity entity, String userId) {
    return SupabaseCaseModel(
      id: entity.firestoreId ?? '',
      name: entity.name,
      nationality: entity.nationality,
      birthDate: entity.birthDate,
      lastSeenDate: entity.lastSeenDate,
      lastSeenLocation: entity.lastSeenLocation,
      sex: entity.sex.interpolId ?? 'U',
      heightCm: entity.heightCm,
      photoUrls: entity.photoUrls,
      facts: entity.facts,
      contacts: entity.contacts
          .map((c) => {'label': c.label, 'value': c.value, 'type': c.type.name})
          .toList(),
      source: 'user',
      status: 'pending',
      reportedBy: userId,
    );
  }

  static CaseContact _mapContact(Map<String, dynamic> raw) {
    return CaseContact(
      label: raw['label'] as String? ?? '',
      value: raw['value'] as String? ?? '',
      type: ContactType.values.firstWhere(
        (t) => t.name == raw['type'],
        orElse: () => ContactType.other,
      ),
    );
  }

  static CaseStatus _parseStatus(String raw) {
    return switch (raw) {
      'approved' => CaseStatus.approved,
      'resolved' => CaseStatus.resolved,
      'rejected' => CaseStatus.rejected,
      _ => CaseStatus.pending,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static List<Map<String, dynamic>> _parseContactList(dynamic value) {
    if (value is List) return value.whereType<Map<String, dynamic>>().toList();
    return [];
  }
}
