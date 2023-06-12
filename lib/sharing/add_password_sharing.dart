import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';

class AddPasswordSharing {

  Future<void> insertValuesParams({
    required String? username, 
    required String? newAuth, 
  }) async {

    const updateSharingAuth = "UPDATE sharing_info SET SET_PASS = :getval WHERE CUST_USERNAME = :username";
    final params = {'getval': AuthModel().computeAuth(newAuth!), 'username': username!};

    await Crud().update(
      query: updateSharingAuth, 
      params: params
    );
  
  }
}