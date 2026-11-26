import 'package:flutter_test/flutter_test.dart';
import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/model/RequestStateModel.dart';
import 'package:pqrsmart/data/model/RequestTypeModel.dart';
import 'package:pqrsmart/presentation/widgets/request_statistics_charts.dart';

void main() {
  final requests = [
    _request(
      date: '2026-01-03',
      updatedAt: '2026-02-02T10:00:00Z',
      type: 'Queja',
      state: 'Finalizado',
      dependence: 'Salud',
    ),
    _request(
      date: '2026-01-19',
      type: 'Peticion',
      state: 'Pendiente',
      dependence: 'Educación',
    ),
    _request(
      date: '2026-02-11',
      type: 'Queja',
      state: 'Pendiente',
      dependence: 'Salud',
    ),
  ];

  test('builds type, status and dependence summaries from request data', () {
    expect(
      buildRequestTypeBars(
        requests,
      ).map((item) => (item.label, item.value)).toList(),
      [('Queja', 2), ('Peticion', 1)],
    );
    expect(
      buildRequestStatusBars(
        requests,
      ).map((item) => (item.label, item.value)).toList(),
      [('Pendiente', 2), ('Finalizado', 1)],
    );
    expect(
      buildDependenceBars(
        requests,
        dependences: [
          DependenceModel(nameDependence: 'Salud'),
          DependenceModel(nameDependence: 'Gobierno'),
        ],
      ).map((item) => (item.label, item.value)).toList(),
      [('Salud', 2), ('Educación', 1), ('Gobierno', 0)],
    );
  });

  test('groups real registration and final-update dates by month', () {
    final trend = buildMonthlyRequestTrend(requests, monthLimit: 3);

    expect(trend.map((point) => point.label), ['Dic 25', 'Ene 26', 'Feb 26']);
    expect(trend.map((point) => point.received), [0, 2, 1]);
    expect(trend.map((point) => point.resolved), [0, 0, 1]);
  });

  test('returns no chart points when registrations have no valid dates', () {
    expect(buildMonthlyRequestTrend([_request(date: 'not-a-date')]), isEmpty);
  });
}

RequestModel _request({
  required String date,
  String? updatedAt,
  String? type,
  String? state,
  String? dependence,
}) => RequestModel(
  requestType: type == null
      ? null
      : RequestTypeModel(idRequestType: 1, nameRequestType: type),
  dependence: dependence == null
      ? null
      : DependenceModel(nameDependence: dependence),
  category: null,
  description: '',
  date: date,
  updatedAt: updatedAt,
  requestState: state == null
      ? null
      : RequestStateModel(idRequestState: 1, nameRequestState: state),
  mediumAnswer: '',
);
