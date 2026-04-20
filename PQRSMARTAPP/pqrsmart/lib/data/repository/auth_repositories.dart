import 'package:pqrsmart/data/model/AuthResponse.dart';
import 'package:pqrsmart/data/model/IdentificationTypeModal.dart';
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import 'package:pqrsmart/data/model/user_model.dart';
import 'package:pqrsmart/data/services/AuthService.dart';
import 'package:pqrsmart/data/services/IdentificationTypeService.dart';
import 'package:pqrsmart/data/services/PersonTypeService.dart';

class AuthRepository {
  final AuthService service;
  final IdentificationTypeService identificationTypeService;
  final PersonTypeService personTypeService;

  AuthRepository(
    this.service,
    this.identificationTypeService,
    this.personTypeService,
  );

  Future<AuthResponse> login(String user, String password) {
    return service.login(user, password);
  }

  Future<UserModel> register({
    required String user,
    required String name,
    required String lastName,
    required String email,
    required String password,
    required int identificationType,
    required int identificationNumber,
    required int personType,
    required int number,
  }) {
    return service.register(
      user: user,
      name: name,
      lastName: lastName,
      email: email,
      password: password,
      identificationType: identificationType,
      identificationNumber: identificationNumber,
      personType: personType,
      number: number,
    );
  }

  Future<Map<String, dynamic>> getRegisterFormData() async {
    final results = await Future.wait([
      identificationTypeService.getAll(),
      personTypeService.getAll(),
    ]);
    return {
      'identificationTypes': results[0] as List<IdentificationTypeModal>,
      'personTypes': results[1] as List<PersonTypeModal>,
    };
  }
}
