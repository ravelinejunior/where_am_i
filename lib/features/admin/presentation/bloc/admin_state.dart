part of 'admin_bloc.dart';

enum AdminStatus { initial, loading, success, failure }

final class AdminState extends Equatable {
  final AdminStatus status;
  final List<MissingPersonEntity> cases;
  final String? processingId;
  final String? errorMessage;
  final String? lastActionMessage;

  const AdminState({
    this.status = AdminStatus.initial,
    this.cases = const [],
    this.processingId,
    this.errorMessage,
    this.lastActionMessage,
  });

  bool get isLoading => status == AdminStatus.loading;
  bool get isEmpty => status == AdminStatus.success && cases.isEmpty;
  bool isProcessing(String id) => processingId == id;

  AdminState copyWith({
    AdminStatus? status,
    List<MissingPersonEntity>? cases,
    String? processingId,
    String? errorMessage,
    String? lastActionMessage,
    bool clearProcessing = false,
  }) {
    return AdminState(
      status: status ?? this.status,
      cases: cases ?? this.cases,
      processingId:
          clearProcessing ? null : (processingId ?? this.processingId),
      errorMessage: errorMessage ?? this.errorMessage,
      lastActionMessage: lastActionMessage ?? this.lastActionMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, cases, processingId, errorMessage, lastActionMessage];
}
