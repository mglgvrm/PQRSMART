import 'package:pqrsmart/data/model/CategoryModel.dart';

abstract class CategoryEvent {}

class LoadCategoriesEvent extends CategoryEvent {}

class SaveCategoryEvent extends CategoryEvent {
  final CategoryModel categoryModel;

  SaveCategoryEvent(this.categoryModel);
}
class ActivateCategoryEvent extends CategoryEvent{
  final int id;
  ActivateCategoryEvent(this.id);
}
class CancelCategoryEvent extends CategoryEvent{
  final int id;
  CancelCategoryEvent(this.id);
}