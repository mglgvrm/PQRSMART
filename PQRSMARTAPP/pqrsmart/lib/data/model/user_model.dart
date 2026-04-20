class UserModel {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final String? phoneNumber;
  final String? userId;
  final String? picture;
  final String? nameCompany;
  final int? idPersonType;
  final int? idIdentificationType;
  final String? identification;
  final String? authProvider;
  final String token;
  final String nit;
  final String img;

  UserModel({
    required this.email,
    required this.token,
    required this.name,
    required this.lastname,
    required this.nit,
    required this.identification,
    required this.img,
    required this.id,
    this.phoneNumber,
    this.nameCompany,
    this.idPersonType,
    this.idIdentificationType,
    this.authProvider,
    this.picture,
    this.userId,
  });
  UserModel.minimal({required this.email, required this.name, required id})
    : id = id,
      lastname = '',
      token = '',
      nit = '',
      identification = null,
      img = '',
      phoneNumber = null,
      userId = null,
      picture = null,
      nameCompany = null,
      idPersonType = null,
      idIdentificationType = null,
      authProvider = null;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '', // Default to empty string if not provided
      token: json['token'] ?? '', // Default to empty string if not provided
      name: json['name'] ?? '', // Default to empty string if not provided
      lastname:
          json['lastname'] ?? '', // Added the required 'lastname' parameter
      nit: json['nit'] ?? '', // Default to empty string if not provided
      identification:
          json['identification'] ?? 0, // Default to 0 if not provided
      img: json['img'] ?? '', // Default to empty string if not provided
      id: json['id'] ?? 0, // Default to 0 if not provided
      phoneNumber:
          json['phoneNumber'] ?? null, // Default to null if not provided
      nameCompany:
          json['nameCompany'] ?? null, // Default to null if not provided
      idPersonType:
          json['idPersonType'] ?? null, // Default to null if not provided
      idIdentificationType:
          json['idIdentificationType'] ??
          null, // Default to null if not provided
    );
  }
}
