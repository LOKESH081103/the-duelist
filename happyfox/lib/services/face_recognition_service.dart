import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class FaceRecognitionService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  Future<Map<String, dynamic>> processAttendance(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/process-attendance'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } catch (e) {
      throw Exception('Failed to process attendance: $e');
    }
  }
}
