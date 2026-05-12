class StateModel {
  final int id;
  final String? description;

  StateModel({
    required this.id,
     this.description,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      description: json['description'] ?? '',
    );
  }
  // ✅ faltaba esto
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "description": description,
    };
  }
}