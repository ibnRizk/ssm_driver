import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/support_info.dart';

abstract class SupportRepository {
  Future<Either<Failure, SupportInfo>> getSupportInfo();
}
