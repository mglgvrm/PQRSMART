import 'package:pqrsmart/data/model/CategoryModel.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}

class SaveCategoryLoaded extends CategoryState {
  final CategoryModel categoryModel;

  SaveCategoryLoaded(this.categoryModel);
}
class ActivateCategoryLoaded extends CategoryState {
  final CategoryModel categoryModel;

  ActivateCategoryLoaded(this.categoryModel);
}

class CancelCategoryLoaded extends CategoryState {
  final CategoryModel categoryModel;

  CancelCategoryLoaded(this.categoryModel);
}