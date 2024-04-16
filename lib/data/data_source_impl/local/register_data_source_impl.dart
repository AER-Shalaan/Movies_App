import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:movies_app/core/firebase/auth_helper.dart';
import 'package:movies_app/data/data_source_contract/local/register_data_source.dart';

@Injectable(as: RegisterDataSource)
class registerDataSourceImpl extends RegisterDataSource {
  AuthHelper authHelper;
  @factoryMethod
  registerDataSourceImpl(this.authHelper);
  @override
  Future<Either<String, UserCredential>> register({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential reg =
          await authHelper.register(email: email, password: password);
      log("registerDataSourceImpl");
      return Right(reg);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? "");
    } catch (e) {
      return Left(e.toString());
    }
  }
}
