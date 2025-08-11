import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExtinguisherMissionScreen extends StatefulWidget {
  const ExtinguisherMissionScreen({super.key});

  @override
  State<ExtinguisherMissionScreen> createState() =>
      _ExtinguisherMissionScreenState();
}

class _ExtinguisherMissionScreenState extends State<ExtinguisherMissionScreen> {
  String? _result;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  List<String>? _detectedObjects;

  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _detectedObjects = null;
    });

    try {
      // 이미지를 바이트로 읽어서 미리보기용으로 저장
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });

      final uri = Uri.parse("http://localhost:5000/predict");

      http.MultipartRequest request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: 'upload.jpg'),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      print('서버로 요청 전송 중...');
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print('서버 응답: $respStr');

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(respStr);
        setState(() {
          _result = jsonResp['result'];
          _detectedObjects = jsonResp['detected_objects']?.cast<String>();
        });
      } else {
        setState(() {
          _result = '서버 오류: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('오류 발생: $e');
      setState(() {
        _result = '전송 중 오류 발생: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("소화기 인증 미션")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 업로드 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : pickAndUploadImage,
              child: _isLoading 
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text("분석 중..."),
                    ],
                  )
                : const Text("이미지 업로드 및 분석"),
            ),
            const SizedBox(height: 20),
            
            // 업로드된 이미지 미리보기
            if (_imageBytes != null) ...[
              const Text(
                "업로드된 이미지:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // 분석 결과
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!.contains('감지됨') ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _result!.contains('감지됨') ? Colors.green : Colors.orange,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "분석 결과:",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: _result!.contains('감지됨') ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 감지된 객체 목록
            if (_detectedObjects != null && _detectedObjects!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "감지된 객체들:",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_detectedObjects!.map((obj) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("• $obj"),
                    ))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
