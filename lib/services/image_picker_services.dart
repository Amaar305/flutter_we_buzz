import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

class ImagePickerService {
  Future<XFile?> imagePicker({
    required ImageSource source,
    required CropAspectRatio cropAspectRatio,
  }) async {
    try {
      // Pick Image
      XFile? pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return null;

      CroppedFile? croppedFile = await croppedImage(pickedImage.path);

      if (croppedFile == null) return null;

      return XFile(croppedFile.path);
    } catch (e) {
      log('Error trying to pick and crop image');
      log(e);
      return null;
    }
  }

  Future<CroppedFile?> croppedImage(String sourcePath) async {
    try {
      // Crop Picked Image
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        // aspectRatio: cropAspectRatio,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9,
              ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
      );
      if (croppedImage == null) return null;
      return croppedImage;
    } catch (e) {
      log('Error trying to crop image');
      log(e);
      return null;
    }
  }
}
