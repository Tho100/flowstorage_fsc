import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';

class VisibilityChecker {

  static final _tempData = GetIt.instance<TempDataProvider>();

  static bool setNotVisibleList(List<String> origin) {
    return !(origin.contains(_tempData.fileOrigin));
  }

  static bool setNotVisible(String origin) {
    return _tempData.fileOrigin != origin;
  }

}