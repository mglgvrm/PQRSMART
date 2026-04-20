class Identificationtype {
  final int id;
  final String name;

  Identificationtype({
    required this.id,
    required this.name,
  });

  factory Identificationtype.fromJson(Map<String, dynamic> json) {
    return Identificationtype(
      id: json['idPersonType'],
      name: json['namePersonType'] ?? '',
    );
  }
}