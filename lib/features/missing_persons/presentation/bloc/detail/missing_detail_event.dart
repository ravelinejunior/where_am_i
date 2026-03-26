part of 'missing_detail_bloc.dart';

sealed class MissingDetailEvent extends Equatable {
  const MissingDetailEvent();
  @override
  List<Object?> get props => [];
}

final class MissingDetailLoaded extends MissingDetailEvent {
  final String id;
  final bool isInterpolCase;

  /// If the entity was already fetched by the list screen, pass it here
  /// to avoid a redundant network call.
  final MissingPersonEntity? prefetched;

  const MissingDetailLoaded({
    required this.id,
    required this.isInterpolCase,
    this.prefetched,
  });

  @override
  List<Object?> get props => [id, isInterpolCase, prefetched];
}
