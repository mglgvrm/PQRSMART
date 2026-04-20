

import 'package:pqrsmart/data/model/State.dart';

class DependenceModel {
  final int idDependence;
  final String nameDependence;
  final State? state;

  DependenceModel({
    required this.idDependence,
    required this.nameDependence,
    required this.state
  });

  factory DependenceModel.fromJson(Map<String, dynamic> json) {
    return DependenceModel(
      idDependence: json['idDependence'] ?? 0,
      nameDependence: json['nameDependence']?.toString() ?? '',
      state: json['state'] != null
          ? State.fromJson(json['state'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "idDependence": idDependence,
    };
  }
}