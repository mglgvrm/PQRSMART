class RequestTypeModel {
  final int idRequestType;
  final String nameRequestType;

  RequestTypeModel({
    required this.idRequestType,
    required this.nameRequestType
  });
  factory RequestTypeModel.fromJson(Map<String, dynamic> json){
    return RequestTypeModel(
        idRequestType: json["idRequestType"]?? 0,
        nameRequestType: json["nameRequestType"]??''
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "idRequestType": idRequestType,
    };
  }

}