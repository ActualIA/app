import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Contains either the OCR result (left) or an error (right).
typedef _Content = Either<String, Error>;

enum Error { recognition, processing, noImage }

class NewsRecognitionViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;

  _Content? _content;
  bool isProcessing = false;

  List<String> _oldContexts = [];
  late Directory _contextDirectory;

  bool get hasError => _content?.isRight() ?? false;
  String? get result => _content?.fold((l) => l, (r) => null);
  List<String> get contexts => _oldContexts;

  String getErrorMessage(AppLocalizations loc) {
    final error = (_content?.fold((l) => null, (r) => r))!;
    switch (error) {
      case Error.recognition:
        return loc.ocrErrorRecognition;
      case Error.processing:
        return loc.ocrErrorProcessing;
      case Error.noImage:
        return loc.ocrErrorNoImage;
    }
  }

  @protected
  void setError(Error error) {
    _content = Right(error);
    notifyListeners();
  }

  @protected
  void setContent(String content) {
    _content = Left(content);
    notifyListeners();
  }

  @protected
  void markProcessingAs(bool started) {
    isProcessing = started;
    notifyListeners();
  }

  final ImagePicker _picker = ImagePicker();

  NewsRecognitionViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
    Future.microtask(() => retrieveContexts());
  }

  Future<void> ocr(String filePath) async {
    try {
      final textFromImage = await recognizeText(filePath);
      log("Text from image: $textFromImage", level: Level.INFO.value);
      await invokeProcessImage(textFromImage);
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

  Future<void> invokeProcessImage(String textFromImage) async {
    try {
      final processImageResponse = await supabase.functions
          .invoke('process-image', body: {"textFromImage": textFromImage});

      log("Edge function 'process-image' invoked successfully.",
          level: Level.INFO.value);
      setContent(processImageResponse.data);
    } catch (e) {
      log("Error invoking process-image edge function: $e",
          level: Level.WARNING.value);
      throw Exception("Failed to invoke process-image function");
    }
  }

  Future<XFile?> takePicture() async {
    final permission = await askPermission();

    if (permission.isGranted) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        return photo;
      }
    } else {
      log('Permission denied', level: Level.WARNING.value);
    }
    return null;
  }

  Future<void> takePictureAndProcess() async {
    final picture = await takePicture();
    if (picture == null) {
      setError(Error.noImage);
      return;
    }

    markProcessingAs(true);
    final text = await recognizeText(picture.path);
    await invokeProcessImage(text);
    if (result != null) {
      _oldContexts = [result!, ..._oldContexts];
    }
    // Write the context to a file
    Future.microtask(writeContext);
    markProcessingAs(false);
  }

  Future<PermissionStatus> askPermission() async {
    return await Permission.camera.request();
  }

  Future<void> writeContext() async {
    if (result == null) {
      log('Context is null', level: Level.WARNING.value);
      return;
    }
    final file =
        File('${_contextDirectory.path}/${_oldContexts.length + 1}.txt');
    await file.writeAsString(result!);
  }

  Future<void> retrieveContexts() async {
    final dir = await getApplicationDocumentsDirectory();
    _contextDirectory = Directory('${dir.path}/contexts');

    if (!await _contextDirectory.exists()) {
      await _contextDirectory.create(recursive: true);
    }

    // Get all files in the context directory
    final files = await _contextDirectory.list().toList() as List<File>;
    // Sort the files by descending name (the name should be 1.txt, 2.txt, 3.txt, etc.)
    files.sort((a, b) => b.path.compareTo(a.path));

    List<String> contexts = [];
    // For each file, get its content and add it to the list
    for (var file in files) {
      final content = await file.readAsString();
      contexts.add(content);
    }

    _oldContexts = contexts;
  }
}
