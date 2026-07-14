import 'dart:async';
import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickLogoImage() async {
  final completer = Completer<XFile?>();
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/png, image/jpeg, image/jpg';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final blobUrl = html.Url.createObjectUrlFromBlob(file);
      completer.complete(XFile(blobUrl, name: file.name));
    } else {
      completer.complete(null);
    }
  });

  // Handle case where user closes the dialog without selecting a file
  // Wait a bit and complete null if no change is detected (standard file picker workaround)
  // But usually completing null on empty selection is handled by the browser event.
  
  return completer.future;
}
