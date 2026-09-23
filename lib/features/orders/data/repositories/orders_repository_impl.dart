import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/current_work.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remote;

  const OrdersRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, CurrentWork?>> getCurrentWork() async {
    try {
      return Right<Failure, CurrentWork?>(await _remote.getCurrentWork());
    } on AppException catch (e) {
      return Left<Failure, CurrentWork?>(e.toFailure());
    } catch (_) {
      return Left<Failure, CurrentWork?>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
  }
}
