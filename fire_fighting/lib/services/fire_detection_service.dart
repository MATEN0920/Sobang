import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class FireDetectionService {
  static Future<String> sendImage(PlatformFile file) async {
    try {
      final uri = Uri.parse('http://YOUR_SERVER_URL/predict'); // 🔁 서버 주소로 수정

      http.MultipartRequest request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
      } else {
        final f = File(file.path!);
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          f.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      return '전송 중 오류 발생: $e';
    }
  }
}
