import 'package:equatable/equatable.dart';

import '../../domain/entities/parcel.dart';

sealed class ParcelDetailsState extends Equatable {
  const ParcelDetailsState();

  @override
  List<Object?> get props => [];
}

class ParcelDetailsLoading extends ParcelDetailsState {
  const ParcelDetailsLoading();
}

class ParcelDetailsLoaded extends ParcelDetailsState {
  final Parcel parcel;

  const ParcelDetailsLoaded(this.parcel);

  @override
  List<Object?> get props => [parcel];
}

class ParcelDetailsError extends ParcelDetailsState {
  final String message;

  const ParcelDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
