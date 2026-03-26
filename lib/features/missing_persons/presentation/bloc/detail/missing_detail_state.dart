part of 'missing_detail_bloc.dart';

enum MissingDetailStatus { initial, loading, success, failure }

final class MissingDetailState extends Equatable {
  final MissingDetailStatus status;
  final MissingPersonEntity? person;

  const MissingDetailState({
    this.status = MissingDetailStatus.initial,
    this.person,
  });

  bool get isLoading => status == MissingDetailStatus.loading;
  bool get isSuccess => status == MissingDetailStatus.success;
  bool get isFailure => status == MissingDetailStatus.failure;

  MissingDetailState copyWith({
    MissingDetailStatus? status,
    MissingPersonEntity? person,
  }) {
    return MissingDetailState(
      status: status ?? this.status,
      person: person ?? this.person,
    );
  }

  @override
  List<Object?> get props => [status, person];
}
