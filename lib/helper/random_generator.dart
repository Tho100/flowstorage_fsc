import 'dart:math';

class Generator {

  static String generateRandomString(int length) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  static int generateRandomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }
  
}