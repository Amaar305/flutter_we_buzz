import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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

  static Future<void> saveImage(String imageUrl) async {
    try {
      if (!imageUrl.validateURL()) return;

      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 80,
      );
      if (result['isSuccess']) toast('Image Successifully Saved');
      await Future.delayed(const Duration(milliseconds: 50));

      Get.back();
      log(result);
    } catch (e) {
      toast('Error While Saving Image');
      log("Error While Saving Image $e");
    }
  }
}
