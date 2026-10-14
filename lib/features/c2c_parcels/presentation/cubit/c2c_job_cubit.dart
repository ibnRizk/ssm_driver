import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/push/push_hint.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/repositories/c2c_parcels_repository.dart';
import 'c2c_job_state.dart';

/// One accepted C2C job. The contract has no single-parcel read, so it is
/// looked up in the Driver's active jobs; a push about it re-reads it.
class C2cJobCubit extends Cubit<C2cJobState> {
  final C2cParcelsRepository _repository;
  StreamSubscription<PushHint>? _pushSubscription;
  int? _parcelId;

  C2cJobCubit(this._repository, {Stream<PushHint>? pushHints})
    : super(const C2cJobLoading()) {
    _pushSubscription = pushHints
        ?.where(
          (PushHint hint) =>
              hint.concerns(PushTarget.c2cParcel) &&
              (hint.id == null || hint.id == _parcelId),
        )
        .listen((_) {
          final int? id = _parcelId;
          if (id != null) load(id);
        });
  }

  /// Shows [initial] (e.g. the board's copy) at once, then the server's.
  Future<void> load(int parcelId, {C2cParcel? initial}) async {
    _parcelId = parcelId;
    final C2cJobState before = state;
    if (initial != null && !initial.isOffer) {
      emit(C2cJobLoaded(initial));
    } else if (before is! C2cJobLoaded) {
      emit(const C2cJobLoading());
    }

    final Either<Failure, List<C2cParcel>> result = await _repository
        .getActiveJobs();
    if (isClosed) return;
    result.fold(
      (Failure f) {
        // A failed refresh keeps the job on screen; only a first load fails.
        if (state is! C2cJobLoaded) {
          emit(C2cJobError(f.message ?? Strings.somethingWentWrong));
        }
      },
      (List<C2cParcel> jobs) {
        final C2cParcel? job = jobs
            .where((C2cParcel j) => j.id == parcelId)
            .firstOrNull;
        if (job != null) {
          emit(C2cJobLoaded(job));
        } else {
          final C2cJobState current = state;
          emit(C2cJobEnded(current is C2cJobLoaded ? current.parcel : null));
        }
      },
    );
  }

  /// A server-confirmed update from a lifecycle command.
  void applyParcel(C2cParcel parcel) {
    _parcelId = parcel.id;
    emit(
      parcel.isTerminal || parcel.status == C2cStatus.delivered
          ? C2cJobEnded(parcel)
          : C2cJobLoaded(parcel),
    );
  }

  @override
  Future<void> close() {
    _pushSubscription?.cancel();
    return super.close();
  }
}
