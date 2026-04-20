class IdentificationTypeModal {
  final int idIdentificationType;
  final String nameIdentificationType;

  IdentificationTypeModal({
    required this.idIdentificationType,
    required this.nameIdentificationType,
  });

  factory IdentificationTypeModal.fromJson(Map<String, dynamic> json) {
    return IdentificationTypeModal(
      idIdentificationType: json['idIdentificationType']?? 0,
      nameIdentificationType: json['nameIdentificationType'] ?? '',
    );
  }
}