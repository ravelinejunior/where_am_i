part of 'report_bloc.dart';

enum ReportStatus { idle, loading, success, failure }

final class ReportState extends Equatable {
  final ReportStatus status;

  // Form fields
  final String name;
  final String nationality;
  final DateTime? birthDate;
  final DateTime? lastSeenDate;
  final String lastSeenLocation;
  final PersonSex sex;
  final String height;
  final String eyeColor;
  final String hairColor;
  final String facts;
  final List<String> localPhotoPaths;

  // Validation
  final bool showErrors;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.idle,
    this.name = '',
    this.nationality = '',
    this.birthDate,
    this.lastSeenDate,
    this.lastSeenLocation = '',
    this.sex = PersonSex.unknown,
    this.height = '',
    this.eyeColor = '',
    this.hairColor = '',
    this.facts = '',
    this.localPhotoPaths = const [],
    this.showErrors = false,
    this.errorMessage,
  });

  bool get isSubmitting => status == ReportStatus.loading;
  bool get isSuccess => status == ReportStatus.success;

  bool get nameValid => name.trim().length >= 2;
  bool get lastSeenDateValid => lastSeenDate != null;
  bool get lastSeenLocationValid => lastSeenLocation.trim().length >= 3;
  bool get isFormValid =>
      nameValid && lastSeenDateValid && lastSeenLocationValid;

  ReportState copyWith({
    ReportStatus? status,
    String? name,
    String? nationality,
    DateTime? birthDate,
    DateTime? lastSeenDate,
    String? lastSeenLocation,
    PersonSex? sex,
    String? height,
    String? eyeColor,
    String? hairColor,
    String? facts,
    List<String>? localPhotoPaths,
    bool? showErrors,
    String? errorMessage,
    bool clearBirthDate = false,
    bool clearLastSeenDate = false,
    bool clearError = false,
  }) {
    return ReportState(
      status: status ?? this.status,
      name: name ?? this.name,
      nationality: nationality ?? this.nationality,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      lastSeenDate:
          clearLastSeenDate ? null : (lastSeenDate ?? this.lastSeenDate),
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      sex: sex ?? this.sex,
      height: height ?? this.height,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
      facts: facts ?? this.facts,
      localPhotoPaths: localPhotoPaths ?? this.localPhotoPaths,
      showErrors: showErrors ?? this.showErrors,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        name,
        nationality,
        birthDate,
        lastSeenDate,
        lastSeenLocation,
        sex,
        height,
        eyeColor,
        hairColor,
        facts,
        localPhotoPaths,
        showErrors,
        errorMessage,
      ];
}
