import 'package:pqrsmart/data/model/CategoryModel.dart';
import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/RequestStateModel.dart';
import 'package:pqrsmart/data/model/RequestTypeModel.dart';
import 'package:pqrsmart/data/model/user_model.dart';

class RequestModel {
  final int? idRequest;
  final UserModel? user;
  final RequestTypeModel? requestType;
  final DependenceModel? dependence;
  final CategoryModel? category;
  final String description;
  final String date;
  final String? updatedAt;
  final String? answer;
  final RequestStateModel? requestState;
  final String mediumAnswer;
  final String? archivo;
  final String? archiveAnswer;
  final String? radicado;
  final double? latitude;
  final double? longitude;
  final String? locationSource;
  final String? locationMethod;
  final String? locationDescription;
  final String? locationCapturedAt;
  final String? citizenName;
  final String? citizenEmail;
  final String? citizenPhone;
  final UserModel? registeredBy;

  RequestModel({
    this.idRequest,
    this.user,
    required this.requestType,
    required this.dependence,
    required this.category,
    required this.description,
    required this.date,
    this.updatedAt,
    this.answer,
    required this.requestState,
    required this.mediumAnswer,
    this.archivo,
    this.archiveAnswer,
    this.radicado,
    this.latitude,
    this.longitude,
    this.locationSource,
    this.locationMethod,
    this.locationDescription,
    this.locationCapturedAt,
    this.citizenName,
    this.citizenEmail,
    this.citizenPhone,
    this.registeredBy,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      idRequest: json['idRequest'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      requestType: json["requestType"] != null
          ? RequestTypeModel.fromJson(json['requestType'])
          : null,
      dependence: json['dependence'] != null
          ? DependenceModel.fromJson(json['dependence'])
          : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString(),
      answer: json['answer']?.toString(),
      requestState: json['requestState'] != null
          ? RequestStateModel.fromJson(json['requestState'])
          : null,
      mediumAnswer: json['mediumAnswer']?.toString() ?? '',
      archivo: json['archivo']?.toString(),
      archiveAnswer: json['archiveAnswer']?.toString(),
      radicado: json['radicado']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationSource: json['locationSource']?.toString(),
      locationMethod: json['locationMethod']?.toString(),
      locationDescription: json['locationDescription']?.toString(),
      locationCapturedAt: json['locationCapturedAt']?.toString(),
      citizenName: json['citizenName']?.toString(),
      citizenEmail: json['citizenEmail']?.toString(),
      citizenPhone: json['citizenPhone']?.toString(),
      registeredBy: json['registeredBy'] != null
          ? UserModel.fromJson(json['registeredBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idRequest": idRequest,
      "user": user?.toJson(),
      "requestType": requestType?.toJson(),
      "dependence": dependence?.toJson(),
      "category": category?.toJson(),
      "description": description,
      "date": date,
      "updatedAt": updatedAt,
      "answer": answer,
      "requestState": requestState?.toJson(),
      "mediumAnswer": mediumAnswer,
      "archivo": archivo,
      "archiveAnswer": archiveAnswer,
      "radicado": radicado,
      "latitude": latitude,
      "longitude": longitude,
      "locationSource": locationSource,
      "locationMethod": locationMethod,
      "locationDescription": locationDescription,
      "locationCapturedAt": locationCapturedAt,
      "citizenName": citizenName,
      "citizenEmail": citizenEmail,
      "citizenPhone": citizenPhone,
    };
  }
}
