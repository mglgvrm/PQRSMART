class RequestStateHistoryModel {
  const RequestStateHistoryModel({
    required this.newState,
    required this.changedAt,
    this.previousState,
    this.changedBy,
    this.observation,
  });

  final String newState;
  final String? previousState;
  final String changedAt;
  final String? changedBy;
  final String? observation;

  factory RequestStateHistoryModel.fromJson(Map<String, dynamic> json) =>
      RequestStateHistoryModel(
        previousState: json['previousState']?.toString(),
        newState: json['newState']?.toString() ?? 'Estado actualizado',
        changedAt: json['changedAt']?.toString() ?? '',
        changedBy: json['changedBy']?.toString(),
        observation: json['observation']?.toString(),
      );
}
