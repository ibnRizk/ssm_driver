import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/current_work.dart';

abstract class OrdersRepository {
  /// `Right(null)` means the Driver has no accepted active order.
  Future<Either<Failure, CurrentWork?>> getCurrentWork();
}
