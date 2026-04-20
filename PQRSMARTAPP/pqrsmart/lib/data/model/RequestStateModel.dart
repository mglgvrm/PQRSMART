class RequestStateModel {
  final int idRequestState;
  final String? nameRequestState;

  RequestStateModel({
    required this.idRequestState,
     this.nameRequestState
  });
  factory RequestStateModel.fromJson(Map<String, dynamic> json){
    return RequestStateModel(
      idRequestState: json["idRequestState"]?? 0,
      nameRequestState: json["nameRequestState"]??''
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "idRequestState": idRequestState,
    };
  }

}