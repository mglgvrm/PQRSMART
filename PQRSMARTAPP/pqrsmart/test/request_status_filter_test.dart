import 'package:flutter_test/flutter_test.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/model/RequestStateModel.dart';
import 'package:pqrsmart/presentation/utils/request_status_filter.dart';

void main() {
  final requests = [
    _request('Pendiente'),
    _request('En espera'),
    _request('En proceso'),
    _request('Finalizado'),
    _request('Rechazado'),
    _request('Cancelado'),
    _request('Estado sin clasificar'),
  ];

  test('Recibidas includes every authorized request', () {
    expect(countRequestsByStatus(requests, RequestStatusFilter.all), 7);
    expect(filterRequestsByStatus(requests, RequestStatusFilter.all), requests);
  });

  test('status filters map current and supported status names correctly', () {
    final expectedByFilter = {
      RequestStatusFilter.pending: 'Pendiente',
      RequestStatusFilter.waiting: 'En espera',
      RequestStatusFilter.inProgress: 'En proceso',
      RequestStatusFilter.attended: 'Finalizado',
      RequestStatusFilter.rejected: 'Rechazado',
      RequestStatusFilter.cancelled: 'Cancelado',
    };

    for (final entry in expectedByFilter.entries) {
      final matches = filterRequestsByStatus(requests, entry.key);
      expect(matches, hasLength(1), reason: entry.key.label);
      expect(
        matches.single.requestState?.nameRequestState,
        entry.value,
        reason: entry.key.label,
      );
    }

    expect(
      matchesRequestStatus(_request('Solución'), RequestStatusFilter.attended),
      isTrue,
    );
  });
}

RequestModel _request(String status) => RequestModel(
  requestType: null,
  dependence: null,
  category: null,
  description: '',
  date: '',
  requestState: RequestStateModel(idRequestState: 1, nameRequestState: status),
  mediumAnswer: '',
);
