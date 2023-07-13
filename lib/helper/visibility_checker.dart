import 'package:flowstorage_fsc/global/globals.dart';

class VisibilityChecker {

  static bool setNotVisibleList(List<String> origin) {
    return !(origin.contains(Globals.fileOrigin));
  }

  static bool setNotVisible(String origin) {
    return Globals.fileOrigin != origin;
  }

}