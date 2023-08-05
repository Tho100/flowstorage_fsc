import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionClass {

  late List<int> keyBytes;
  
  EncryptionClass() {
    keyBytes = utf8.encode("0123456789085746");
  }

  String encrypt(String? plainText) {
    
    try {
        
      final key = Key(Uint8List.fromList(keyBytes));
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      final encrypted = encrypter.encrypt(plainText!, iv: iv);

      return base64.encode(encrypted.bytes);

    } catch (err) {
      return "";
    }
  }

  String decrypt(String? plainText) {

    try {

      final key = Key(Uint8List.fromList(keyBytes));
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      final decrypted = encrypter.decrypt(Encrypted(base64.decode(plainText!)), iv: iv);

      return decrypted;

    } catch (err) {
      return "";
    }
  }
  
}
