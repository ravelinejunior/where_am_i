import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/missing_person_entity.dart';
import '../../../../core/enums/enums.dart';

/// Maps a Firestore `/cases/{id}` document to and from the domain entity.
class FirestoreCaseModel {
  final String id;
  final String name;
  final String? nationality;
  final Timestamp? birthDate;
  final Timestamp? lastSeenDate;
  final String? lastSeenLocation;
  final String sexId;
  final int? heightCm;
  final List<String> photoUrls;
  final List<String> facts;
  final List<Map<String, dynamic>> contacts;
  final String source;
  final String status;
  final String? reportedBy;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const FirestoreCaseModel({
    required this.id,
    required this.name,
    this.nationality,
    this.birthDate,
    this.lastSeenDate,
    this.lastSeenLocation,
    this.sexId = 'U',
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

  factory FirestoreCaseModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FirestoreCaseModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      nationality: data['nationality'] as String?,
      birthDate: data['birthDate'] as Timestamp?,
      lastSeenDate: data['lastSeenDate'] as Timestamp?,
      lastSeenLocation: data['lastSeenLocation'] as String?,
      sexId: data['sex'] as String? ?? 'U',
      heightCm: (data['heightCm'] as num?)?.toInt(),
      photoUrls: _parseStringList(data['photoUrls']),
      facts: _parseStringList(data['facts']),
      contacts: _parseContactList(data['contacts']),
      source: data['source'] as String? ?? 'user',
      status: data['status'] as String? ?? 'pending',
      reportedBy: data['reportedBy'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (nationality != null) 'nationality': nationality,
      if (birthDate != null) 'birthDate': birthDate,
      if (lastSeenDate != null) 'lastSeenDate': lastSeenDate,
      if (lastSeenLocation != null) 'lastSeenLocation': lastSeenLocation,
      'sex': sexId,
      if (heightCm != null) 'heightCm': heightCm,
      'photoUrls': photoUrls,
      'facts': facts,
      'contacts': contacts,
      'source': source,
      'status': status,
      if (reportedBy != null) 'reportedBy': reportedBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MissingPersonEntity toEntity() {
    return MissingPersonEntity(
      id: id,
      firestoreId: id,
      name: name,
      nationality: nationality,
      birthDate: birthDate?.toDate(),
      lastSeenDate: lastSeenDate?.toDate(),
      lastSeenLocation: lastSeenLocation,
      sex: PersonSex.fromFirestore(sexId),
      heightCm: heightCm,
      photoUrls: photoUrls,
      facts: facts,
      contacts: contacts.map(_mapContact).toList(),
      source: source == 'admin'
          ? MissingPersonSource.firebase
          : MissingPersonSource.firebase,
      status: _parseStatus(status),
      createdAt: createdAt?.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }

  static FirestoreCaseModel fromEntity(
    MissingPersonEntity entity,
    String userId,
  ) {
    return FirestoreCaseModel(
      id: entity.firestoreId ?? '',
      name: entity.name,
      nationality: entity.nationality,
      birthDate: entity.birthDate != null
          ? Timestamp.fromDate(entity.birthDate!)
          : null,
      lastSeenDate: entity.lastSeenDate != null
          ? Timestamp.fromDate(entity.lastSeenDate!)
          : null,
      lastSeenLocation: entity.lastSeenLocation,
      sexId: entity.sex.interpolId ?? 'U',
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
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
