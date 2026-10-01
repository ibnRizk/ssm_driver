import 'package:equatable/equatable.dart';

/// The choices for one registration dropdown (zones, vehicle types).
sealed class OptionsState<T> extends Equatable {
  const OptionsState();

  @override
  List<Object?> get props => [];
}

class OptionsLoading<T> extends OptionsState<T> {
  const OptionsLoading();
}

/// [items] is never empty — an empty list is [OptionsEmpty].
class OptionsLoaded<T> extends OptionsState<T> {
  final List<T> items;

  const OptionsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// The backend answered, but has nothing to choose from.
class OptionsEmpty<T> extends OptionsState<T> {
  const OptionsEmpty();
}

class OptionsError<T> extends OptionsState<T> {
  final String message;

  const OptionsError({required this.message});

  @override
  List<Object?> get props => [message];
}
