import 'package:equatable/equatable.dart';

import '../../domain/entities/c2c_parcel.dart';

sealed class C2cJobState extends Equatable {
  const C2cJobState();

  @override
  List<Object?> get props => [];
}

class C2cJobLoading extends C2cJobState {
  const C2cJobLoading();
}

class C2cJobLoaded extends C2cJobState {
  final C2cParcel parcel;

  const C2cJobLoaded(this.parcel);

  @override
  List<Object?> get props => [parcel];
}

/// The job is no longer active for this Driver — delivered, cancelled or
/// taken away. [parcel] is the last copy seen, if any.
class C2cJobEnded extends C2cJobState {
  final C2cParcel? parcel;

  const C2cJobEnded(this.parcel);

  @override
  List<Object?> get props => [parcel];
}

class C2cJobError extends C2cJobState {
  final String message;

  const C2cJobError(this.message);

  @override
  List<Object?> get props => [message];
}
