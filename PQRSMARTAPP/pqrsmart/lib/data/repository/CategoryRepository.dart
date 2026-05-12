import 'package:pqrsmart/data/model/CategoryModel.dart';
import 'package:pqrsmart/data/services/CategoryService.dart';

class CategoryRepository {
  final CategoryService service;
  CategoryRepository(this.service);

  Future<List<CategoryModel>> getCategories() {
    return service.getCategories();
  }
  Future<CategoryModel> saveCategory(CategoryModel category){
    return service.saveCategory(category);
  }
  Future<CategoryModel> activateCategory(int id){
    return service.activateCategory(id);
  }
  Future<CategoryModel> cancelCategory(int id){
    return service.cancelCategory(id);
  }
}