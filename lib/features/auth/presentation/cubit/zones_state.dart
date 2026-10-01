import 'package:equatable/equatable.dart';

import '../../domain/entities/zone.dart';

sealed class ZonesState extends Equatable {
  const ZonesState();

  @override
  List<Object?> get props => [];
}

class ZonesLoading extends ZonesState {
  const ZonesLoading();
}

/// [zones] is never empty — an empty list is [ZonesEmpty].
class ZonesLoaded extends ZonesState {
  final List<Zone> zones;

  const ZonesLoaded(this.zones);

  @override
  List<Object?> get props => [zones];
}

/// The backend answered, but has no zones to register in.
class ZonesEmpty extends ZonesState {
  const ZonesEmpty();
}

class ZonesError extends ZonesState {
  final String message;

  const ZonesError({required this.message});

  @override
  List<Object?> get props => [message];
}
