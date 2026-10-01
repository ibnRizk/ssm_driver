import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/support_info.dart';
import '../../domain/repositories/support_repository.dart';
import 'support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  final SupportRepository _repository;

  SupportCubit(this._repository) : super(const SupportLoading());

  Future<void> load() async {
    emit(const SupportLoading());
    final result = await _repository.getSupportInfo();
    if (isClosed) return;
    result.fold(
      (Failure f) => emit(SupportError(f.message ?? Strings.somethingWentWrong)),
      (SupportInfo info) => emit(SupportLoaded(info)),
    );
  }
}
