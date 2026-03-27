part of 'admin_bloc.dart';

sealed class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

final class AdminPendingCasesLoaded extends AdminEvent {
  const AdminPendingCasesLoaded();
}

final class AdminCaseApproved extends AdminEvent {
  final String firestoreId;
  const AdminCaseApproved(this.firestoreId);
  @override
  List<Object?> get props => [firestoreId];
}

final class AdminCaseRejected extends AdminEvent {
  final String firestoreId;
  const AdminCaseRejected(this.firestoreId);
  @override
  List<Object?> get props => [firestoreId];
}
