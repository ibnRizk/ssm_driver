import 'package:equatable/equatable.dart';

/// A vehicle type a Driver can register with (`GET /vehicle/list`).
class VehicleType extends Equatable {
  final int id;
  final String name;

  const VehicleType({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
