import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/widgets/pqr_widgets.dart';

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key, required this.request});
  final RequestModel request;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  bool _showAnalysis = false;

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final status = request.requestState?.nameRequestState ?? 'En proceso';
    final canCancel =
        request.idRequest != null &&
        (status.toUpperCase().contains('PROCESO') ||
            status.toUpperCase().contains('PENDIENTE'));
    return BlocListener<RequestBloc, RequestState>(
      listener: (context, state) {
        if (state is RequestCancelled) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Solicitud cancelada.')));
          Navigator.pop(context, true);
        } else if (state is RequestError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: const PqrPageHeader(title: 'Detalle de solicitud'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            PqrCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request.radicado?.isNotEmpty == true
                              ? request.radicado!
                              : '#PQR-${request.idRequest ?? '---'}',
                          style: const TextStyle(
                            color: AppColors.dark,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      PqrStatusBadge(status: status),
                    ],
                  ),
                  const Divider(height: 25, color: AppColors.border),
                  _DetailRow(
                    label: 'Categoría',
                    value: request.category?.nameCategory ?? 'No disponible',
                  ),
                  _DetailRow(
                    label: 'Tipo',
                    value:
                        request.requestType?.nameRequestType ?? 'No disponible',
                  ),
                  _DetailRow(label: 'Fecha de registro', value: request.date),
                  const SizedBox(height: 13),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    request.description,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PqrCard(
              padding: EdgeInsets.zero,
              color: AppColors.surfaceBlue,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                leading: const Icon(
                  Icons.description_outlined,
                  color: AppColors.icon,
                ),
                title: const Text(
                  'Análisis de la solicitud',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                initiallyExpanded: _showAnalysis,
                onExpansionChanged: (value) =>
                    setState(() => _showAnalysis = value),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        request.answer?.isNotEmpty == true
                            ? request.answer!
                            : 'El análisis estará disponible cuando sea asignado por la dependencia responsable.',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (canCancel) ...[
              const SizedBox(height: 20),
              PqrPrimaryButton(
                label: 'Cancelar solicitud',
                icon: Icons.close,
                loading: context.watch<RequestBloc>().state is RequestLoading,
                onPressed: () => _confirmCancellation(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancellation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar solicitud'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta solicitud?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Cancelar solicitud',
              style: TextStyle(color: AppColors.cancelled),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final id = widget.request.idRequest;
      if (id != null) context.read<RequestBloc>().add(CancelRequestEvent(id));
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 126,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.text, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
