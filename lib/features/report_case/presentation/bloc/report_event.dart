part of 'report_bloc.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

final class ReportNameChanged extends ReportEvent {
  final String value;
  const ReportNameChanged(this.value);
  @override List<Object?> get props => [value];
}

final class ReportNationalityChanged extends ReportEvent {
  final String value;
  const ReportNationalityChanged(this.value);
  @override List<Object?> get props => [value];
}

final class ReportBirthDateChanged extends ReportEvent {
  final DateTime? value;
  const ReportBirthDateChanged(this.value);
  @override List<Object?> get props => [value];
}

final class ReportLastSeenDateChanged extends ReportEvent {
  final DateTime? value;
  const ReportLastSeenDateChanged(this.value);
  @override List<Object?> get props => [value];
}

final class ReportLastLocationChanged extends ReportEvent {
  final String value;
  const ReportLastLocationChanged(this.value);
  @override List<Object?> get props => [value];
}

final class ReportSexChanged extends ReportEvent {
  final PersonSex value;
  const ReportSexChanged(this.value);
  @override List<Object?> get props => [value];
}

final class ReportHeightChanged extends ReportEvent {
  final String value;
  const ReportHeightChanged(this.value);
  @override List<Object?> get props => [value];
}

final class ReportFactsChanged extends ReportEvent {
  final String value;
  const ReportFactsChanged(this.value);
  @override List<Object?> get props => [value];
}

final class ReportPhotoAdded extends ReportEvent {
  final String localPath;
  const ReportPhotoAdded(this.localPath);
  @override List<Object?> get props => [localPath];
}

final class ReportPhotoRemoved extends ReportEvent {
  final int index;
  const ReportPhotoRemoved(this.index);
  @override List<Object?> get props => [index];
}

final class ReportSubmitted extends ReportEvent {
  const ReportSubmitted();
}

final class ReportReset extends ReportEvent {
  const ReportReset();
}
