import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';

class RequestsAdminPage extends StatefulWidget {
  const RequestsAdminPage({super.key});

  @override
  State<RequestsAdminPage> createState() => _RequestsAdminPageState();
}

class _RequestsAdminPageState extends State<RequestsAdminPage> {
  static const _filters = [
    'Todas',
    'Pendientes',
    'En proceso',
    'Atendidas',
    'Canceladas',
  ];
  final _searchController = TextEditingController();
  int _selectedFilter = 0;
  String _query = '';
  String? _selectedCategory;
  String? _selectedDependence;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(RequestModel request) {
    final status = (request.requestState?.nameRequestState ?? '').toUpperCase();
    return switch (_selectedFilter) {
      1 => status.contains('PEND'),
      2 => status.contains('PROCESO'),
      3 =>
        status.contains('ATEND') ||
            status.contains('FINAL') ||
            status.contains('RESUEL'),
      4 => status.contains('CANCEL') || status.contains('RECHAZ'),
      _ => true,
    };
  }

  bool _matchesSearch(RequestModel request) {
    final query = _query.toLowerCase();
    if (query.isEmpty) return true;
    return [
      request.radicado,
      request.idRequest?.toString(),
      request.user?.name,
      request.user?.lastName,
      request.category?.nameCategory,
      request.dependence?.nameDependence,
      request.date,
    ].whereType<String>().any((value) => value.toLowerCase().contains(query));
  }

  bool _matchesRequest(RequestModel request) {
    if (!_matchesFilter(request) || !_matchesSearch(request)) return false;
    if (_selectedCategory != null &&
        request.category?.nameCategory != _selectedCategory) {
      return false;
    }
    if (_selectedDependence != null &&
        request.dependence?.nameDependence != _selectedDependence) {
      return false;
    }
    if (_dateRange != null) {
      final date = DateTime.tryParse(request.date);
      if (date == null) return false;
      final start = DateTime(
        _dateRange!.start.year,
        _dateRange!.start.month,
        _dateRange!.start.day,
      );
      final end = DateTime(
        _dateRange!.end.year,
        _dateRange!.end.month,
        _dateRange!.end.day,
        23,
        59,
        59,
      );
      if (date.isBefore(start) || date.isAfter(end)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Solicitudes'),
      actions: [
        IconButton(
          tooltip: 'Actualizar solicitudes',
          onPressed: () =>
              context.read<RequestBloc>().add(LoadAllRequestsEvent()),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading || state is RequestInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.action),
          );
        }
        if (state is RequestError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    color: AppColors.muted,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No fue posible cargar las solicitudes.\n${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<RequestBloc>().add(LoadAllRequestsEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is! RequestLoaded) {
          return const Center(child: Text('No hay solicitudes disponibles.'));
        }

        final categories =
            state.request
                .map((request) => request.category?.nameCategory)
                .whereType<String>()
                .where((name) => name.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final dependences =
            state.request
                .map((request) => request.dependence?.nameDependence)
                .whereType<String>()
                .where((name) => name.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final requests = state.request.where(_matchesRequest).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Buscar por radicado, ciudadano o dependencia',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar búsqueda',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 55,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ChoiceChip(
                  label: Text(_filters[index]),
                  selected: _selectedFilter == index,
                  onSelected: (_) => setState(() => _selectedFilter = index),
                  selectedColor: AppColors.action,
                  backgroundColor: AppColors.surfaceBlue,
                  labelStyle: TextStyle(
                    color: _selectedFilter == index
                        ? AppColors.white
                        : AppColors.text,
                  ),
                  showCheckmark: false,
                  side: BorderSide.none,
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  PopupMenuButton<String>(
                    initialValue: _selectedCategory ?? '',
                    tooltip: 'Filtrar por categoría',
                    onSelected: (value) => setState(
                      () => _selectedCategory = value.isEmpty ? null : value,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: '',
                        child: Text('Todas las categorías'),
                      ),
                      for (final category in categories)
                        PopupMenuItem(value: category, child: Text(category)),
                    ],
                    child: _FilterButton(
                      icon: Icons.category_outlined,
                      label: _selectedCategory ?? 'Categoría',
                      active: _selectedCategory != null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    initialValue: _selectedDependence ?? '',
                    tooltip: 'Filtrar por dependencia',
                    onSelected: (value) => setState(
                      () => _selectedDependence = value.isEmpty ? null : value,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: '',
                        child: Text('Todas las dependencias'),
                      ),
                      for (final dependence in dependences)
                        PopupMenuItem(
                          value: dependence,
                          child: Text(dependence),
                        ),
                    ],
                    child: _FilterButton(
                      icon: Icons.business_outlined,
                      label: _selectedDependence ?? 'Dependencia',
                      active: _selectedDependence != null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: pickDateRange,
                    icon: const Icon(Icons.date_range_outlined, size: 18),
                    label: Text(
                      _dateRange == null
                          ? 'Fecha'
                          : '${_dateRange!.start.day}/${_dateRange!.start.month} - '
                                '${_dateRange!.end.day}/${_dateRange!.end.month}',
                    ),
                  ),
                  if (_selectedCategory != null ||
                      _selectedDependence != null ||
                      _dateRange != null)
                    IconButton(
                      tooltip: 'Limpiar filtros',
                      onPressed: () => setState(() {
                        _selectedCategory = null;
                        _selectedDependence = null;
                        _dateRange = null;
                      }),
                      icon: const Icon(Icons.filter_alt_off_outlined),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${requests.length} solicitud(es)',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: requests.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay solicitudes que coincidan con los filtros.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _RequestCard(
                        request: requests[index],
                        onTap: () => _showDetails(requests[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    ),
  );

  Future<void> pickDateRange() async {
    final today = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year + 1),
      initialDateRange: _dateRange,
    );
    if (selected != null && mounted) {
      setState(() => _dateRange = selected);
    }
  }

  void _showDetails(RequestModel request) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.radicado?.isNotEmpty == true
                    ? request.radicado!
                    : '#PQR-${request.idRequest ?? '---'}',
                style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(height: 24),
              _DetailLine(
                'Ciudadano',
                '${request.user?.name ?? ''} ${request.user?.lastName ?? ''}'
                    .trim(),
              ),
              _DetailLine(
                'Categoría',
                request.category?.nameCategory ?? 'No disponible',
              ),
              _DetailLine(
                'Dependencia',
                request.dependence?.nameDependence ?? 'No disponible',
              ),
              _DetailLine(
                'Estado',
                request.requestState?.nameRequestState ?? 'No disponible',
              ),
              _DetailLine('Fecha', request.date),
              const SizedBox(height: 14),
              const Text(
                'Descripción',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                request.description,
                style: const TextStyle(color: AppColors.muted, height: 1.45),
              ),
              if (request.answer?.isNotEmpty == true) ...[
                const SizedBox(height: 14),
                const Text(
                  'Respuesta registrada',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.answer!,
                  style: const TextStyle(color: AppColors.muted, height: 1.45),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 220),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: active ? AppColors.surfaceBlue : AppColors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: active ? AppColors.action : AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: active ? AppColors.primary : AppColors.muted,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.text,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.muted),
      ],
    ),
  );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onTap});

  final RequestModel request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = [
      request.user?.name,
      request.user?.lastName,
    ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
    final status = request.requestState?.nameRequestState ?? 'Sin estado';
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceBlue,
          child: Icon(Icons.description_outlined, color: AppColors.primary),
        ),
        title: Text(
          request.radicado?.isNotEmpty == true
              ? request.radicado!
              : '#PQR-${request.idRequest ?? '---'}',
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '$name · ${request.category?.nameCategory ?? 'Sin categoría'}\n'
            '${request.dependence?.nameDependence ?? 'Sin dependencia'} · ${request.date}',
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, color: AppColors.icon, size: 10),
            const SizedBox(height: 4),
            Text(
              status,
              style: const TextStyle(color: AppColors.text, fontSize: 11),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: AppColors.muted)),
        ),
      ],
    ),
  );
}
