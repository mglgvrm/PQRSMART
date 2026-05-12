import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/repository/CategoryRepository.dart';
import 'package:pqrsmart/presentation/states/CategoryEvent.dart';
import 'package:pqrsmart/presentation/states/CategoryState.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await repository.getCategories();
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError('Error al cargar categorías'));
      }
    });

    on<SaveCategoryEvent>((event, emit) async {
      emit(CategoryLoading());

      try {
        final category = await repository.saveCategory(event.categoryModel);

        emit(SaveCategoryLoaded(category));
      } catch (e) {
        emit(CategoryError('Error al guardar Categoria'));
      }
    });
    on<ActivateCategoryEvent>((event, emit) async {
      emit(CategoryLoading());

      try {
        final Category = await repository.activateCategory(event.id);

        emit(ActivateCategoryLoaded(Category));
      } catch (e) {
        emit(CategoryError('Error al guardar Categoria'));
      }
    });
    on<CancelCategoryEvent>((event, emit) async {
      emit(CategoryLoading());

      try {
        final Category = await repository.cancelCategory(event.id);

        emit(CancelCategoryLoaded(Category));
      } catch (e) {
        emit(CategoryError('Error al guardar Categoria'));
      }
    });
  }
}