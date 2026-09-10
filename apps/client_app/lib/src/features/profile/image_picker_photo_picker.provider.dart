import 'package:image_picker/image_picker.dart';

import 'package:client_app/src/features/profile/photo_picker.provider.dart';

class ImagePickerPhotoPicker implements PhotoPicker {
  const ImagePickerPhotoPicker();

  @override
  Future<String?> pickPhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    return image?.path;
  }
}