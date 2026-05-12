import 'package:pqrsmart/data/model/user_model.dart';
import 'package:pqrsmart/data/services/UserService.dart';

class UserRepository {
  final UserService userService;

  UserRepository(this.userService);
  Future<List<UserModel>> getAll(){
    return userService.getAll();
  }
  Future<UserModel> getMyUserEvent(){
    return userService.getMyUserEvent();
  }
  Future<UserModel> cancelUser(int id){
    return userService.cancelUser(id);
  }

}