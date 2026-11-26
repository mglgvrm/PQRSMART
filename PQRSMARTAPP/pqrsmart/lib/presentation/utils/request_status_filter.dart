import 'package:flutter/material.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';

enum RequestStatusFilter {
  all('Recibidas'),
  pending('Pendientes'),
  waiting('En espera'),
  inProgress('En proceso'),
  attended('Atendidas'),
  rejected('Rechazadas'),
  cancelled('Canceladas');

  const RequestStatusFilter(this.label);

  final String label;
}

bool matchesRequestStatus(RequestModel request, RequestStatusFilter filter) {
  if (filter == RequestStatusFilter.all) return true;

  final status = (request.requestState?.nameRequestState ?? '').toUpperCase();
  return switch (filter) {
    RequestStatusFilter.all => true,
    RequestStatusFilter.pending => status.contains('PEND'),
    RequestStatusFilter.waiting =>
      status.contains('ESPER') || status.contains('WAIT'),
    RequestStatusFilter.inProgress =>
      status.contains('PROCES') ||
          status.contains('TRAMIT') ||
          status.contains('CURSO'),
    RequestStatusFilter.attended =>
      status.contains('ATEND') ||
          status.contains('FINAL') ||
          status.contains('RESUEL') ||
          status.contains('SOLU'),
    RequestStatusFilter.rejected => status.contains('RECH'),
    RequestStatusFilter.cancelled => status.contains('CANCEL'),
  };
}

List<RequestModel> filterRequestsByStatus(
  Iterable<RequestModel> requests,
  RequestStatusFilter filter,
) =>
    requests.where((request) => matchesRequestStatus(request, filter)).toList();

int countRequestsByStatus(
  Iterable<RequestModel> requests,
  RequestStatusFilter filter,
) => requests.where((request) => matchesRequestStatus(request, filter)).length;

Color requestStatusColor(String? value) {
  final status = (value ?? '').toUpperCase();
  if (status.contains('PEND')) return AppColors.action;
  if (status.contains('ESPER') || status.contains('WAIT')) {
    return AppColors.claim;
  }
  if (status.contains('PROCES') ||
      status.contains('TRAMIT') ||
      status.contains('CURSO')) {
    return AppColors.primary;
  }
  if (status.contains('ATEND') ||
      status.contains('FINAL') ||
      status.contains('RESUEL') ||
      status.contains('SOLU')) {
    return AppColors.attended;
  }
  if (status.contains('RECH')) return AppColors.complaint;
  if (status.contains('CANCEL')) return AppColors.muted;
  return AppColors.muted;
}
