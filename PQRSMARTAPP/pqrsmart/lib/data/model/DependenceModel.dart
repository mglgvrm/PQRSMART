

import 'package:pqrsmart/data/model/StateModel.dart';

class DependenceModel {
  final int? idDependence;
  final String? nameDependence;
  final StateModel? state;

  DependenceModel({
     this.idDependence,
     this.nameDependence,
     this.state
  });


  factory DependenceModel.fromJson(Map<String, dynamic> json) {
    return DependenceModel(
      idDependence: json['idDependence'] ?? 0,
      nameDependence: json['nameDependence']?.toString() ?? '',
      state: json['state'] != null
          ? StateModel.fromJson(json['state'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "idDependence": idDependence,
      "nameDependence": nameDependence,  // ✅ faltaba esto
      "state": state?.toJson(),          // ✅ faltaba esto
    };
  }

}