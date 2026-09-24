import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/repositories/parcels_repository.dart';
import 'parcel_details_state.dart';

/// One parcel (`GET /delivery-man/parcels/{id}`).
class ParcelDetailsCubit extends Cubit<ParcelDetailsState> {
  final ParcelsRepository _repository;

  ParcelDetailsCubit(this._repository) : super(const ParcelDetailsLoading());

  /// [initial] (the list's copy) renders at once while the server copy
  /// loads. If that refresh fails the list copy stays: it is only as old as
  /// the list, and any stale state surfaces as an error on the next action.
  Future<void> loadParcel(int parcelId, {Parcel? initial}) async {
    emit(
      initial != null
          ? ParcelDetailsLoaded(initial)
          : const ParcelDetailsLoading(),
    );
    final result = await _repository.getParcelDetails(parcelId);
    if (isClosed) return;
    result.fold((Failure f) {
      if (state is! ParcelDetailsLoaded) {
        emit(ParcelDetailsError(f.message ?? Strings.somethingWentWrong));
      }
    }, (Parcel parcel) => emit(ParcelDetailsLoaded(parcel)));
  }

  /// Reflects a server-confirmed start or completion.
  void applyParcel(Parcel parcel) => emit(ParcelDetailsLoaded(parcel));
}
