class StateUser {
  final int id;
  final String state;

  StateUser({
    required this.id,
    required this.state,
  });

  factory StateUser.fromJson(Map<String, dynamic> json) {
    return StateUser(
      id: json['id']?? 0,
      state: json['state']?.toString() ?? '',
    );
  }
}