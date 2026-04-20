import 'package:pqrsmart/data/model/CategoryModel.dart';
import 'package:pqrsmart/data/services/CategoryService.dart';

class CategoryRepository {
  final CategoryService service;
  CategoryRepository(this.service);

  Future<List<CategoryModel>> getCategories() {
    return service.getCategories();
  }
}