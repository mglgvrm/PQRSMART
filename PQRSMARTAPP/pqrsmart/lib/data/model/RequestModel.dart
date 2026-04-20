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
  final String? answer;
  final RequestStateModel? requestState;
  final String mediumAnswer;
  final String? archivo;
  final String? archiveAnswer;
  final String? radicado;

  RequestModel({
    this.idRequest,
    this.user,
    required this.requestType,
    required this.dependence,
    required this.category,
    required this.description,
    required this.date,
    this.answer,
    required this.requestState,
    required this.mediumAnswer,
    this.archivo,
    this.archiveAnswer,
    this.radicado,
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
      answer: json['answer']?.toString(),
      requestState: json['requestState'] != null
          ? RequestStateModel.fromJson(json['requestState'])
          : null,
      mediumAnswer: json['mediumAnswer']?.toString() ?? '',
      archivo: json['archivo']?.toString(),
      archiveAnswer: json['archiveAnswer']?.toString(),
      radicado: json['radicado']?.toString(),
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
      "answer": answer,
      "requestState": requestState?.toJson(),
      "mediumAnswer": mediumAnswer,
      "archivo": archivo,
      "archiveAnswer": archiveAnswer,
      "radicado": radicado,
    };
  }
}