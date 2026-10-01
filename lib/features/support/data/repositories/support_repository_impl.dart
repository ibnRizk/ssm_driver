import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/support_info.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource _remote;

  const SupportRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, SupportInfo>> getSupportInfo() async {
    try {
      return Right<Failure, SupportInfo>(await _remote.getSupportInfo());
    } on AppException catch (e) {
      return Left<Failure, SupportInfo>(e.toFailure());
    } catch (_) {
      return Left<Failure, SupportInfo>(
        ServerFailure(message: Strings.somethingWentWrong),
      );
    }
  }
}
