import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsRecognitionViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;

  NewsRecognitionViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
  }

  Future<String> recognizeText(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    return recognizedText.text;
  }

  Future<void> invokeProcessImage(String textFromImage) async {
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
}
