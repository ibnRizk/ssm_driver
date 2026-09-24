import 'package:equatable/equatable.dart';

import '../../domain/entities/cod_summary.dart';
import '../../domain/entities/incentive_summary.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final CodSummary cod;
  final IncentiveSummary incentive;

  const HomeLoaded({required this.cod, required this.incentive});

  @override
  List<Object?> get props => [cod, incentive];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
