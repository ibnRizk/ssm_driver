import 'package:equatable/equatable.dart';

/// A service zone a Driver can register in (`GET /zone/list`).
class Zone extends Equatable {
  final int id;
  final String name;

  const Zone({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
