import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import 'package:pqrsmart/data/model/StateUser.dart';
import 'package:pqrsmart/data/model/IdentificationTypeModal.dart';

class UserModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final int number;
  final String user;
  final int identificationNumber;
  final String role;
  final StateUser? stateUser;
  final DependenceModel? dependence;
  final PersonTypeModal? personType;
  final IdentificationTypeModal? identificationType;

  UserModel({
    required this.email,
    required this.name,
    required this.lastName,
    required this.id,
    required this.role,
    required this.number,
    required this.user,
    required this.identificationNumber,
    this.stateUser,
    this.dependence,
    this.personType,
    this.identificationType,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email']?.toString() ?? '', // Default to empty string if not provided
      name: json['name']?.toString() ?? '', // Default to empty string if not provided
      lastName:
          json['lastName']?.toString() ?? '', // Added the required 'lastname' parameter
      id: json['id'] ?? 0, // Default to 0 if not provided
      role: json['role']?.toString() ?? '',
      stateUser: json['stateUser'] != null
          ? StateUser.fromJson(json['stateUser'])
          : null,
      number: json['number'] ?? 0,
      user: json['user']?.toString() ??'',
      identificationNumber: json['identificationNumber'] ?? 0,
      dependence: json['dependence'] != null
          ? DependenceModel.fromJson(json['dependence'])
          : null,
      personType: json['personType'] != null
          ? PersonTypeModal.fromJson(json['personType'])
          : null,
      identificationType: json['identificationType'] != null
          ? IdentificationTypeModal.fromJson(json['identificationType'])
          : null,
     // Default to null if not provided
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
    };
  }
}
