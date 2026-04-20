

import 'package:pqrsmart/data/model/State.dart';

class Dependence {
  final int idDependence;
  final String nameDependence;
  final State? state;

  Dependence({
    required this.idDependence,
    required this.nameDependence,
    required this.state
  });

  factory Dependence.fromJson(Map<String, dynamic> json) {
    return Dependence(
      idDependence: json['idDependence'] ?? 0,
      nameDependence: json['nameDependence']?.toString() ?? '',
      state: json['state'] != null
          ? State.fromJson(json['state'])
          : null,
    );
  }
}