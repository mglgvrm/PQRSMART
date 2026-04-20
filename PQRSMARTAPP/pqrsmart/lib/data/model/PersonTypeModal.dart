class PersonTypeModal {
  final int idPersonType;
  final String namePersonType;

  PersonTypeModal({
    required this.idPersonType,
    required this.namePersonType,
  });

  factory PersonTypeModal.fromJson(Map<String, dynamic> json) {
    return PersonTypeModal(
      idPersonType: json['idPersonType']?? 0,
      namePersonType: json['namePersonType'] ?? '',
    );
  }
}