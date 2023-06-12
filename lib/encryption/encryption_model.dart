import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionClass {

  late List<int> _keyBytes;

  EncryptionClass() {
    _keyBytes = utf8.encode("0123456789085746");
  }

  String Encrypt(String? plainText) {
    try {
    final key = Key(Uint8List.fromList(_keyBytes));
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plainText!, iv: iv);

    return base64.encode(encrypted.bytes);
    } catch (errr) {
      return "";
      //
    }
  }

  String Decrypt(String? plainText) {
    try {
    final key = Key(Uint8List.fromList(_keyBytes));
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final decrypted = encrypter.decrypt(Encrypted(base64.decode(plainText!)), iv: iv);

    return decrypted;
    } catch (err) {
      return "";
    }
  }
  
}
