import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NewsRecognitionViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;
  final ImagePicker _picker = ImagePicker();

  NewsRecognitionViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
  }

  Future<String?> ocr(String filePath) async {
    try {
      final textFromImage = await recognizeText(filePath);
      log("Text from image: $textFromImage", level: Level.INFO.value);
      return await invokeProcessImage(textFromImage);
    } catch (e) {
      log("Error processing image: $e", level: Level.WARNING.value);
      throw Exception("Failed to process image");
    }
  }

  Future<String> recognizeText(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    return recognizedText.text;
  }

  Future<String?> invokeProcessImage(String textFromImage) async {
    try {
      final processImageResponse = await supabase.functions
          .invoke('process-image', body: {"textFromImage": textFromImage});

      log("Edge function 'process-image' invoked successfully.",
          level: Level.INFO.value);
      return processImageResponse.data;
    } catch (e) {
      log("Error invoking process-image edge function: $e",
          level: Level.WARNING.value);
      throw Exception("Failed to invoke process-image function");
    }
  }

  Future<XFile?> takePicture() async {
    final permission = await Permission.camera.request();

    if (permission.isGranted) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        debugPrint('Path to picture: ${photo.path}');
        return photo;
      }
    } else {
      log('Permission denied', level: Level.WARNING.value);
    }
    return null;
  }
}
