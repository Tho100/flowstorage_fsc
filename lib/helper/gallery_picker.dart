import 'package:image_picker/image_picker.dart';

class GalleryImagePicker {

  static final imagePicker = ImagePicker();

  static Future<XFile?> pickerImage({required ImageSource source}) async {
    return await imagePicker.pickImage(source: source);
  }

  static Future<List<XFile>?> pickMultiImage() async {
    return await imagePicker.pickMultiImage();
  }
  
  static Future<XFile?> pickerVideo({required ImageSource source}) async {
    return await imagePicker.pickVideo(source: source);
  }

}