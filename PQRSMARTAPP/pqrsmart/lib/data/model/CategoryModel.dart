import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/StateModel.dart';

class CategoryModel {
  final int? idCategory;
  final String nameCategory;
  final DependenceModel? dependence;
  final StateModel? state;

  CategoryModel({
     this.idCategory,
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
          ? StateModel.fromJson(json['state'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "idCategory": idCategory,
      "state": state?.toJson(),
      "nameCategory": nameCategory,
      "dependence": dependence?.toJson()
    };
  }

}