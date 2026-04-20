import 'package:dartz/dartz.dart';
import 'package:urbanestia/core/error/failures.dart';
import 'package:urbanestia/domain/model/change_password.dart';

abstract class PasswordRecoveryRepository {
  Future<Either<Failure, void>> sendRecoveryEmail(String email);
  Future<Either<Failure, bool>> changePassword(ChangePassword password);
}
