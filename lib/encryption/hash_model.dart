import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthModel {

  String computeAuth(String inputStr) {
    List<int> authByteCase = utf8.encode(inputStr);
    var authHashCase = sha256.convert(authByteCase);
    var strAuthCase = authHashCase.toString().toUpperCase();
    return strAuthCase;
  }

}