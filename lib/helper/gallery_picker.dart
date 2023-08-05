import 'package:image_picker/image_picker.dart';

class GalleryPickerHelper {

  static final imagePicker = ImagePicker();

  static Future<XFile?> pickerImage({required ImageSource source}) async {
    return await imagePicker.pickImage(source: source);
  }

}