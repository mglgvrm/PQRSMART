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
  }
}