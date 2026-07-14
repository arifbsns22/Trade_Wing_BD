import 'package:image_picker/image_picker.dart';

Future<XFile?> pickLogoImage() async {
  final ImagePicker picker = ImagePicker();
  return await picker.pickImage(source: ImageSource.gallery);
}
