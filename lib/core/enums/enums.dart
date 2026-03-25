enum MissingPersonSource {
  interpol,
  firebase,
  merged;

  String get label {
    switch (this) {
      case MissingPersonSource.interpol:
        return 'INTERPOL';
      case MissingPersonSource.firebase:
        return 'Community';
      case MissingPersonSource.merged:
        return 'Multiple';
    }
  }
}

enum CaseStatus {
  pending,
  approved,
  resolved,
  rejected;

  String get label {
    switch (this) {
      case CaseStatus.pending:
        return 'Pending Review';
      case CaseStatus.approved:
        return 'Active Case';
      case CaseStatus.resolved:
        return 'Resolved';
      case CaseStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isVisible => this == CaseStatus.approved || this == CaseStatus.pending;
}

enum PersonSex {
  male,
  female,
  unknown;

  String get label {
    switch (this) {
      case PersonSex.male:
        return 'Male';
      case PersonSex.female:
        return 'Female';
      case PersonSex.unknown:
        return 'Unknown';
    }
  }

  String get labelPt {
    switch (this) {
      case PersonSex.male:
        return 'Masculino';
      case PersonSex.female:
        return 'Feminino';
      case PersonSex.unknown:
        return 'Não informado';
    }
  }

  /// Interpol API sexId value
  String? get interpolId {
    switch (this) {
      case PersonSex.male:
        return 'M';
      case PersonSex.female:
        return 'F';
      case PersonSex.unknown:
        return null;
    }
  }

  static PersonSex fromInterpolId(String? id) {
    switch (id?.toUpperCase()) {
      case 'M':
        return PersonSex.male;
      case 'F':
        return PersonSex.female;
      default:
        return PersonSex.unknown;
    }
  }

  static PersonSex fromFirestore(String? value) {
    switch (value?.toUpperCase()) {
      case 'M':
        return PersonSex.male;
      case 'F':
        return PersonSex.female;
      default:
        return PersonSex.unknown;
    }
  }
}

enum AppLocale {
  en,
  pt;

  String get languageCode {
    switch (this) {
      case AppLocale.en:
        return 'en';
      case AppLocale.pt:
        return 'pt';
    }
  }

  String get displayName {
    switch (this) {
      case AppLocale.en:
        return 'English';
      case AppLocale.pt:
        return 'Português';
    }
  }
}

enum SortOrder {
  newestFirst,
  oldestFirst,
  nameAZ,
  nameZA;

  String get label {
    switch (this) {
      case SortOrder.newestFirst:
        return 'Newest first';
      case SortOrder.oldestFirst:
        return 'Oldest first';
      case SortOrder.nameAZ:
        return 'Name A–Z';
      case SortOrder.nameZA:
        return 'Name Z–A';
    }
  }
}
