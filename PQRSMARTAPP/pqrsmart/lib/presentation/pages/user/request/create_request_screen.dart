import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/CategoryModel.dart';
import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/model/RequestStateModel.dart';
import 'package:pqrsmart/data/model/RequestTypeModel.dart';
import 'package:pqrsmart/data/repository/CategoryRepository.dart';
import 'package:pqrsmart/data/repository/DependenceRepository.dart';
import 'package:pqrsmart/data/repository/RequestRepository.dart';
import 'package:pqrsmart/data/repository/RequestTypeRepository.dart';
import 'package:pqrsmart/data/services/CategoryService.dart';
import 'package:pqrsmart/data/services/DependenceService.dart';
import 'package:pqrsmart/data/services/RequestService.dart';
import 'package:pqrsmart/data/services/RequestTypeService.dart';
import 'package:pqrsmart/presentation/blocs/CategoryBloc.dart';
import 'package:pqrsmart/presentation/blocs/DependenceBloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestTypeBloc.dart';
import 'package:pqrsmart/presentation/states/CategoryEvent.dart';
import 'package:pqrsmart/presentation/states/CategoryState.dart';
import 'package:pqrsmart/presentation/states/DependenceEvent.dart';
import 'package:pqrsmart/presentation/states/DependenceState.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/states/RequestTypeEvent.dart';
import 'package:pqrsmart/presentation/states/RequestTypeState.dart';
import 'package:pqrsmart/presentation/widgets/pqr_widgets.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  RequestTypeModel? _requestType;
  DependenceModel? _dependence;
  CategoryModel? _category;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_requestType == null || _dependence == null || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona el tipo, la dependencia y la categoría.'),
        ),
      );
      return;
    }
    context.read<RequestBloc>().add(
      SaveRequestEvent(
        RequestModel(
          description: _descriptionController.text.trim(),
          requestType: _requestType,
          dependence: _dependence,
          category: _category,
          date: DateTime.now().toIso8601String().split('T').first,
          mediumAnswer: 'Correo',
          requestState: RequestStateModel(idRequestState: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            RequestTypeBloc(RequestTypeRepository(RequestTypeService()))
              ..add(LoadRequestTypeEvent()),
      ),
      BlocProvider(
        create: (_) =>
            DependenceBloc(DependenceRepository(DependenceService()))
              ..add(LoadDependenceEvent()),
      ),
      BlocProvider(
        create: (_) =>
            CategoryBloc(CategoryRepository(CategoryService()))
              ..add(LoadCategoriesEvent()),
      ),
      BlocProvider(
        create: (_) => RequestBloc(RequestRepository(RequestService())),
      ),
    ],
    child: BlocListener<RequestBloc, RequestState>(
      listener: (context, state) {
        if (state is RequestSaved) {
          Navigator.pop(context, true);
        } else if (state is RequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.cancelled,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: const PqrPageHeader(title: 'Nueva solicitud'),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              const PqrFieldLabel('Tipo de solicitud'),
              BlocBuilder<RequestTypeBloc, RequestTypeState>(
                builder: (context, state) {
                  if (state is RequestTypeError) {
                    return _LoadError(message: state.message);
                  }
                  final types = state is RequestTypeLoaded
                      ? state.requestTypeModel
                      : <RequestTypeModel>[];
                  return DropdownButtonFormField<RequestTypeModel>(
                    initialValue: _requestType,
                    isExpanded: true,
                    hint: Text(
                      state is RequestTypeLoading
                          ? 'Cargando tipos...'
                          : 'Selecciona un tipo',
                    ),
                    items: types
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.nameRequestType),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _requestType = value),
                    validator: (value) =>
                        value == null ? 'Selecciona un tipo' : null,
                  );
                },
              ),
              const SizedBox(height: 17),
              const PqrFieldLabel('Dependencia'),
              BlocBuilder<DependenceBloc, DependenceState>(
                builder: (context, state) {
                  if (state is DependenceError) {
                    return _LoadError(message: state.message);
                  }
                  final dependencies = state is DependenceLoaded
                      ? state.dependence
                      : <DependenceModel>[];
                  return DropdownButtonFormField<DependenceModel>(
                    initialValue: _dependence,
                    isExpanded: true,
                    hint: Text(
                      state is DependenceLoading
                          ? 'Cargando dependencias...'
                          : 'Selecciona una dependencia',
                    ),
                    items: dependencies
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.nameDependence ?? 'Sin nombre'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _dependence = value;
                      _category = null;
                    }),
                    validator: (value) =>
                        value == null ? 'Selecciona una dependencia' : null,
                  );
                },
              ),
              const SizedBox(height: 17),
              const PqrFieldLabel('Categoría'),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryError) {
                    return _LoadError(message: state.message);
                  }
                  final allCategories = state is CategoryLoaded
                      ? state.categories
                      : <CategoryModel>[];
                  final categories = _dependence == null
                      ? <CategoryModel>[]
                      : allCategories
                            .where(
                              (category) =>
                                  category.dependence?.idDependence ==
                                  _dependence!.idDependence,
                            )
                            .toList();
                  return DropdownButtonFormField<CategoryModel>(
                    key: ValueKey(_dependence?.idDependence),
                    initialValue: _category,
                    isExpanded: true,
                    hint: Text(
                      _dependence == null
                          ? 'Selecciona primero una dependencia'
                          : state is CategoryLoading
                          ? 'Cargando categorías...'
                          : 'Selecciona una categoría',
                    ),
                    items: categories
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.nameCategory),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _category = value),
                    validator: (value) =>
                        value == null ? 'Selecciona una categoría' : null,
                  );
                },
              ),
              const SizedBox(height: 17),
              const PqrFieldLabel('Descripción'),
              TextFormField(
                controller: _descriptionController,
                minLines: 5,
                maxLines: 7,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Describe tu solicitud o inquietud...',
                  alignLabelWithHint: true,
                  counterStyle: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe una descripción'
                    : null,
              ),
              const SizedBox(height: 14),
              const PqrFieldLabel('Adjuntar archivo (opcional)'),
              InkWell(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'La carga de archivos requiere habilitar el servicio de adjuntos.',
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 94,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlue,
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file, color: AppColors.icon, size: 23),
                      SizedBox(height: 5),
                      Text(
                        'Selecciona un archivo',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Imágenes o documentos',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 23),
              BlocBuilder<RequestBloc, RequestState>(
                builder: (context, state) => PqrPrimaryButton(
                  label: 'Enviar solicitud',
                  icon: Icons.send_outlined,
                  loading: state is RequestLoading,
                  onPressed: () => _save(context),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Text(
    message,
    style: const TextStyle(color: AppColors.cancelled, fontSize: 12),
  );
}
