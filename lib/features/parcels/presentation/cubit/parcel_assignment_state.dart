import 'package:equatable/equatable.dart';

import '../../domain/entities/parcel.dart';

sealed class ParcelAssignmentState extends Equatable {
  const ParcelAssignmentState();

  @override
  List<Object?> get props => [];
}

/// Nothing new to announce.
class ParcelAssignmentIdle extends ParcelAssignmentState {
  const ParcelAssignmentIdle();
}

/// Active parcels the server lists that this session hadn't seen before.
/// Never empty.
class ParcelAssignmentFound extends ParcelAssignmentState {
  final List<Parcel> parcels;

  const ParcelAssignmentFound(this.parcels);

  @override
  List<Object?> get props => [parcels];
}
