import 'package:flowstorage_fsc/extra_query/crud.dart';

class VerifySharing {
  
  Future<bool> isAlreadyUploaded(String fileName, String receiverName,String fromName) async {

    const selectFileName = 'SELECT COUNT(*) FROM cust_sharing WHERE CUST_TO = :receiver AND CUST_FILE_PATH = :filename AND CUST_FROM = :from LIMIT 1';
    final params = {'receiver': receiverName,'filename': fileName,'from': fromName};    

    final countFileName = await Crud().count(
      query: selectFileName, 
      params: params
    );

    return countFileName > 0;

  }

  Future<bool> unknownUser(String receiverName) async {

    const query = 'SELECT COUNT(*) FROM information WHERE CUST_USERNAME = :username';
    final params = {'username': receiverName};

    final crud = Crud();
    final countReceiverName = await crud.count(
      query: query, 
      params: params
    );

    return countReceiverName == 0;

  }
}