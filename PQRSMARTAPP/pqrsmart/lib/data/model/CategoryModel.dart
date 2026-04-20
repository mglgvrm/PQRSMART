

import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/State.dart';

class Category {
  final int idCategory;
  final String nameCategory;
  final DependenceModel? dependence;
  final State? state;

  Category({
    required this.idCategory,
    required this.nameCategory,
    required this.dependence,
    required this.state
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      idCategory: json['idCategory'] ?? 0,
      nameCategory: json['nameCategory']?.toString() ?? '',
      dependence: json['dependence'] != null
          ? DependenceModel.fromJson(json['dependence'])
          : null,
      state: json['state'] != null
          ? State.fromJson(json['state'])
          : null,
    );
  }
}