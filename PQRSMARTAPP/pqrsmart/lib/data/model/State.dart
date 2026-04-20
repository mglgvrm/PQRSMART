class State {
  final int id;
  final String description;

  State({
    required this.id,
    required this.description,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'],
      description: json['description'] ?? '',
    );
  }
}