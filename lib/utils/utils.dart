import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);
  Uint8List im;

  if (_file != null) {
    im = await _file.readAsBytes();
    return [_file, im];
  }

  print("No image seletec");
}
