import "dart:typed_data";

import "package:actualia/viewmodels/news_recognition.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:image_picker/image_picker.dart";
import "package:permission_handler/permission_handler.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class FakeFunctionsClient extends Fake implements FunctionsClient {
  @override
  Future<FunctionResponse> invoke(String functionName,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      HttpMethod method = HttpMethod.post,
      Map<String, dynamic>? queryParameters}) {
    expect(functionName, equals('process-image'));
    expect(method, equals(HttpMethod.post));

    return Future.value(FunctionResponse(data: "Hello, world!", status: 200));
  }
}

class FailingFuctionsClient extends Fake implements FunctionsClient {
  @override
  Future<FunctionResponse> invoke(String functionName,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      HttpMethod method = HttpMethod.post,
      Map<String, dynamic>? queryParameters}) {
    throw Exception("Failed to invoke function");
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  FunctionsClient get functions => FakeFunctionsClient();
}

class FailingSupabaseClient extends Fake implements SupabaseClient {
  @override
  FunctionsClient get functions => FailingFuctionsClient();
}

class FakeNewsRecognitionVM extends NewsRecognitionViewModel {
  FakeNewsRecognitionVM() : super(FakeSupabaseClient());

  @override
  Future<PermissionStatus> askPermission() async {
    return PermissionStatus.granted;
  }

  @override
  Future<XFile?> takePicture() async {
    return XFile.fromData(Uint8List(256));
  }
}

class NoPermissionNewsRecognitionVM extends NewsRecognitionViewModel {
  NoPermissionNewsRecognitionVM() : super(FakeSupabaseClient());

  @override
  Future<PermissionStatus> askPermission() async {
    return PermissionStatus.denied;
  }
}

class FailingNewsRecognitionVM extends NewsRecognitionViewModel {
  FailingNewsRecognitionVM() : super(FailingSupabaseClient());

  @override
  Future<String> recognizeText(String filePath) async {
    return "Hello, world!";
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test("Taking a picture without permission returns null", () async {
    NoPermissionNewsRecognitionVM vm = NoPermissionNewsRecognitionVM();
    XFile? image = await vm.takePicture();
    expect(image, isNull);
  });

  test("Taking a picture with permission returns a XFile", () async {
    FakeNewsRecognitionVM vm = FakeNewsRecognitionVM();
    XFile? image = await vm.takePicture();
    expect(image, isNotNull);
  });

  test("InvokeProcessImage returns data from the response", () async {
    FakeNewsRecognitionVM vm = FakeNewsRecognitionVM();
    String? data = await vm.invokeProcessImage("Test");
    expect(data, equals("Hello, world!"));
  });

  test("InvokeProcessImage throws an exception on failure", () async {
    FailingNewsRecognitionVM vm = FailingNewsRecognitionVM();
    expect(() async => await vm.invokeProcessImage("Test"), throwsException);
  });

  test("Ocr with failing supabase function throws exception", () async {
    FailingNewsRecognitionVM vm = FailingNewsRecognitionVM();
    expect(() async => await vm.ocr("path"), throwsException);
  });
}
