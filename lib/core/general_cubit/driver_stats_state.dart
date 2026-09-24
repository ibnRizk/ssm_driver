import 'package:equatable/equatable.dart';

import '../services/driver_stats/cod_summary.dart';
import '../services/driver_stats/incentive_summary.dart';

sealed class DriverStatsState extends Equatable {
  const DriverStatsState();

  @override
  List<Object?> get props => [];
}

class DriverStatsInitial extends DriverStatsState {
  const DriverStatsInitial();
}

class DriverStatsLoading extends DriverStatsState {
  const DriverStatsLoading();
}

class DriverStatsLoaded extends DriverStatsState {
  final CodSummary cod;
  final IncentiveSummary incentive;

  const DriverStatsLoaded({required this.cod, required this.incentive});

  @override
  List<Object?> get props => [cod, incentive];
}

class DriverStatsError extends DriverStatsState {
  final String message;

  const DriverStatsError({required this.message});

  @override
  List<Object?> get props => [message];
}
