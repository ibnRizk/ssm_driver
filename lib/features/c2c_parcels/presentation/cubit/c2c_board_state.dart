import 'package:equatable/equatable.dart';

import '../../domain/entities/c2c_parcel.dart';

sealed class C2cBoardState extends Equatable {
  const C2cBoardState();

  @override
  List<Object?> get props => [];
}

class C2cBoardLoading extends C2cBoardState {
  const C2cBoardLoading();
}

/// Either list may be empty.
class C2cBoardLoaded extends C2cBoardState {
  /// Waiting offers — coarse areas only.
  final List<C2cParcel> offers;

  /// Accepted, unfinished jobs.
  final List<C2cParcel> jobs;

  const C2cBoardLoaded({required this.offers, required this.jobs});

  bool get isEmpty => offers.isEmpty && jobs.isEmpty;

  @override
  List<Object?> get props => [offers, jobs];
}

class C2cBoardError extends C2cBoardState {
  final String message;

  const C2cBoardError(this.message);

  @override
  List<Object?> get props => [message];
}
