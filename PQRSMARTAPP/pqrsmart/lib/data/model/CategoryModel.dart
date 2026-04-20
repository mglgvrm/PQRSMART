import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/State.dart';

class CategoryModel {
  final int idCategory;
  final String nameCategory;
  final DependenceModel? dependence;
  final State? state;

  CategoryModel({
    required this.idCategory,
    required this.nameCategory,
    required this.dependence,
    required this.state
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
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
  Map<String, dynamic> toJson() {
    return {
      "idCategory": idCategory,
    };
  }

}