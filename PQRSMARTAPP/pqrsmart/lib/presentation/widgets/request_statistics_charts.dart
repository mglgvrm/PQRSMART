import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/presentation/utils/request_status_filter.dart';

class RequestStatBar {
  const RequestStatBar(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

class RequestTrendPoint {
  const RequestTrendPoint(this.label, this.received, this.resolved);

  final String label;
  final int received;
  final int resolved;
}

List<RequestStatBar> buildRequestTypeBars(List<RequestModel> requests) {
  final counts = <String, int>{};
  for (final request in requests) {
    final name = request.requestType?.nameRequestType.trim();
    if (name == null || name.isEmpty) continue;
    counts.update(name, (count) => count + 1, ifAbsent: () => 1);
  }
  final sorted = counts.entries.toList()
    ..sort((left, right) => right.value.compareTo(left.value));
  const colors = [
    AppColors.primary,
    AppColors.action,
    AppColors.attended,
    AppColors.claim,
    AppColors.complaint,
  ];
  return [
    for (var index = 0; index < sorted.length; index++)
      RequestStatBar(
        sorted[index].key,
        sorted[index].value,
        colors[index % colors.length],
      ),
  ];
}

List<RequestStatBar> buildRequestStatusBars(List<RequestModel> requests) {
  final counts = <String, int>{};
  for (final request in requests) {
    final name = request.requestState?.nameRequestState?.trim();
    if (name == null || name.isEmpty) continue;
    counts.update(name, (count) => count + 1, ifAbsent: () => 1);
  }
  final sorted = counts.entries.toList()
    ..sort((left, right) => right.value.compareTo(left.value));
  return [
    for (final entry in sorted)
      RequestStatBar(entry.key, entry.value, requestStatusColor(entry.key)),
  ];
}

List<RequestStatBar> buildDependenceBars(
  List<RequestModel> requests, {
  List<DependenceModel> dependences = const [],
}) {
  final counts = <String, int>{};
  for (final dependence in dependences) {
    final name = dependence.nameDependence?.trim();
    if (name != null && name.isNotEmpty) counts.putIfAbsent(name, () => 0);
  }
  for (final request in requests) {
    final name = request.dependence?.nameDependence?.trim();
    if (name == null || name.isEmpty) continue;
    counts.update(name, (count) => count + 1, ifAbsent: () => 1);
  }
  final sorted = counts.entries.toList()
    ..sort((left, right) => right.value.compareTo(left.value));
  return [
    for (var index = 0; index < sorted.length; index++)
      RequestStatBar(
        sorted[index].key,
        sorted[index].value,
        index.isEven ? AppColors.primary : AppColors.action,
      ),
  ];
}

List<RequestTrendPoint> buildMonthlyRequestTrend(
  List<RequestModel> requests, {
  int monthLimit = 12,
}) {
  final datedRequests = <(RequestModel, DateTime)>[];
  for (final request in requests) {
    final date = DateTime.tryParse(request.date);
    if (date != null) datedRequests.add((request, date));
  }
  if (datedRequests.isEmpty || monthLimit < 1) return const [];

  final resolvedDates = <DateTime>[];
  for (final request in requests) {
    if (!matchesRequestStatus(request, RequestStatusFilter.attended)) continue;
    final date = DateTime.tryParse(request.updatedAt ?? '');
    if (date != null) resolvedDates.add(date);
  }
  final latestReceived = datedRequests
      .map((entry) => entry.$2)
      .reduce((left, right) => left.isAfter(right) ? left : right);
  final latestActivity = resolvedDates.fold(
    latestReceived,
    (latest, date) => date.isAfter(latest) ? date : latest,
  );
  final latestMonth = DateTime(latestActivity.year, latestActivity.month);
  final firstMonth = DateTime(
    latestMonth.year,
    latestMonth.month - monthLimit + 1,
  );
  final receivedCounts = <DateTime, int>{};
  for (final entry in datedRequests) {
    final month = DateTime(entry.$2.year, entry.$2.month);
    if (!month.isBefore(firstMonth)) {
      receivedCounts.update(month, (count) => count + 1, ifAbsent: () => 1);
    }
  }
  final resolvedCounts = <DateTime, int>{};
  for (final date in resolvedDates) {
    final month = DateTime(date.year, date.month);
    if (!month.isBefore(firstMonth)) {
      resolvedCounts.update(month, (count) => count + 1, ifAbsent: () => 1);
    }
  }
  return [
    for (var offset = 0; offset < monthLimit; offset++)
      () {
        final month = DateTime(firstMonth.year, firstMonth.month + offset);
        final label =
            '${_monthNames[month.month - 1]} ${month.year.toString().substring(2)}';
        return RequestTrendPoint(
          label,
          receivedCounts[month] ?? 0,
          resolvedCounts[month] ?? 0,
        );
      }(),
  ];
}

const _monthNames = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

class AdminRequestStatistics extends StatelessWidget {
  const AdminRequestStatistics({
    required this.requests,
    required this.dependences,
    super.key,
  });

  final List<RequestModel> requests;
  final List<DependenceModel> dependences;

  @override
  Widget build(BuildContext context) {
    final types = buildRequestTypeBars(requests);
    final statuses = buildRequestStatusBars(requests);
    final monthlyTrend = buildMonthlyRequestTrend(requests);
    final dependenceBars = buildDependenceBars(
      requests,
      dependences: dependences,
    );
    final total = requests.length;
    final resolved = countRequestsByStatus(
      requests,
      RequestStatusFilter.attended,
    );
    final closed =
        resolved +
        countRequestsByStatus(requests, RequestStatusFilter.rejected) +
        countRequestsByStatus(requests, RequestStatusFilter.cancelled);
    final needsAttention = math.max(0, total - closed);
    final resolutionRate = total == 0 ? 0.0 : resolved / total;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final halfWidth = wide
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
              width: halfWidth,
              child: _BreakdownCard(
                title: 'Solicitudes por tipo',
                subtitle: 'Distribución de los registros disponibles',
                data: types,
                emptyMessage: 'No hay tipos de solicitud para graficar.',
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: _BreakdownCard(
                title: 'Estado general',
                subtitle: 'Estados presentes en la base de solicitudes',
                data: statuses,
                emptyMessage: 'No hay estados de solicitud disponibles.',
              ),
            ),
            SizedBox(
              width: constraints.maxWidth,
              child: _TrendCard(
                title: 'Evolución de solicitudes',
                subtitle: 'Registros y finalizaciones según fechas disponibles',
                points: monthlyTrend,
                series: const [
                  _TrendSeries('Recibidas', AppColors.primary),
                  _TrendSeries('Finalizadas', AppColors.attended),
                ],
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: _BreakdownCard(
                title: 'Solicitudes por dependencia',
                subtitle: 'Incluye dependencias sin solicitudes',
                data: dependenceBars,
                emptyMessage: 'No hay dependencias cargadas para comparar.',
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: _PerformanceCard(
                total: total,
                resolved: resolved,
                needsAttention: needsAttention,
                resolutionRate: resolutionRate,
              ),
            ),
          ],
        );
      },
    );
  }
}

class RequestActivityChart extends StatelessWidget {
  const RequestActivityChart({required this.requests, super.key});

  final List<RequestModel> requests;

  @override
  Widget build(BuildContext context) => _TrendCard(
    title: 'Actividad mensual de la dependencia',
    subtitle:
        'Ingresos y última actualización de solicitudes finalizadas por mes',
    points: buildMonthlyRequestTrend(requests),
    series: const [
      _TrendSeries('Recibidas', AppColors.primary),
      _TrendSeries('Finalizadas', AppColors.attended),
    ],
  );
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.title,
    required this.subtitle,
    required this.data,
    required this.emptyMessage,
  });

  final String title;
  final String subtitle;
  final List<RequestStatBar> data;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => _ChartCard(
    title: title,
    subtitle: subtitle,
    child: data.isEmpty
        ? _ChartEmpty(message: emptyMessage)
        : Column(
            children: [
              for (final entry in data)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 112,
                        child: Text(
                          entry.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 12,
                            value:
                                entry.value /
                                data.map((item) => item.value).reduce(math.max),
                            color: entry.color,
                            backgroundColor: AppColors.backgroundBlue,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 38,
                        child: Text(
                          '${entry.value}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
  );
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.total,
    required this.resolved,
    required this.needsAttention,
    required this.resolutionRate,
  });

  final int total;
  final int resolved;
  final int needsAttention;
  final double resolutionRate;

  @override
  Widget build(BuildContext context) => _ChartCard(
    title: 'Rendimiento de atención',
    subtitle: 'Volumen recibido y solicitudes finalizadas',
    child: total == 0
        ? const _ChartEmpty(message: 'Aún no hay solicitudes para analizar.')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PerformanceMetric(
                    label: 'Recibidas',
                    value: total,
                    color: AppColors.primary,
                  ),
                  _PerformanceMetric(
                    label: 'Finalizadas',
                    value: resolved,
                    color: AppColors.attended,
                  ),
                  _PerformanceMetric(
                    label: 'Por gestionar',
                    value: needsAttention,
                    color: AppColors.claim,
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: resolutionRate,
                        color: AppColors.attended,
                        backgroundColor: AppColors.backgroundBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(resolutionRate * 100).toStringAsFixed(0)}% finalizadas',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              const Text(
                'El porcentaje compara las solicitudes finalizadas con el total recibido.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
  );
}

class _PerformanceMetric extends StatelessWidget {
  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 10),
        ),
      ],
    ),
  );
}

class _TrendSeries {
  const _TrendSeries(this.label, this.color);

  final String label;
  final Color color;
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.series,
  });

  final String title;
  final String subtitle;
  final List<RequestTrendPoint> points;
  final List<_TrendSeries> series;

  @override
  Widget build(BuildContext context) => _ChartCard(
    title: title,
    subtitle: subtitle,
    child: points.isEmpty
        ? const _ChartEmpty(
            message: 'No hay fechas válidas para mostrar una evolución.',
          )
        : Column(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  for (final item in series)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CustomPaint(
                  painter: _TrendPainter(points: points, series: series),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    points.first.label,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    points.last.label,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
  );
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.points, required this.series});

  final List<RequestTrendPoint> points;
  final List<_TrendSeries> series;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || series.isEmpty) return;
    const left = 25.0;
    const right = 8.0;
    const top = 10.0;
    const bottom = 10.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      math.max(left + 1, size.width - right),
      math.max(top + 1, size.height - bottom),
    );

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = plot.top + plot.height * index / 3;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
    }

    final values = [
      for (final point in points) point.received,
      for (final point in points)
        if (series.any((item) => item.label == 'Finalizadas')) point.resolved,
    ];
    final maxValue = math.max(1, values.reduce(math.max));
    for (final item in series) {
      final isResolved = item.label == 'Finalizadas';
      final offsets = <Offset>[];
      for (var index = 0; index < points.length; index++) {
        final value = isResolved
            ? points[index].resolved
            : points[index].received;
        final x = points.length == 1
            ? plot.center.dx
            : plot.left + plot.width * index / (points.length - 1);
        final y = plot.bottom - plot.height * value / maxValue;
        offsets.add(Offset(x, y));
      }
      final line = Paint()
        ..color = item.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        path.lineTo(offset.dx, offset.dy);
      }
      if (offsets.length > 1) canvas.drawPath(path, line);
      final pointPaint = Paint()..color = item.color;
      for (final offset in offsets) {
        canvas.drawCircle(offset, 3.5, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.series != series;
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    ),
  );
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 110,
    child: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
    ),
  );
}
