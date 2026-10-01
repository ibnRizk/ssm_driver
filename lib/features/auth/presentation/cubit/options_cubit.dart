import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import 'options_state.dart';

/// Loads the choices for one registration dropdown from [_fetch] — e.g.
/// `OptionsCubit<Zone>(repository.getZones)`.
class OptionsCubit<T> extends Cubit<OptionsState<T>> {
  final Future<Either<Failure, List<T>>> Function() _fetch;

  OptionsCubit(this._fetch) : super(OptionsLoading<T>());

  Future<void> load() async {
    emit(OptionsLoading<T>());
    final Either<Failure, List<T>> result = await _fetch();
    if (isClosed) return;
    emit(
      result.fold(
        (Failure f) =>
            OptionsError<T>(message: f.message ?? Strings.somethingWentWrong),
        (List<T> items) =>
            items.isEmpty ? OptionsEmpty<T>() : OptionsLoaded<T>(items),
      ),
    );
  }
}
