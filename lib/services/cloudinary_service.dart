import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/secrets.dart';

class CloudinaryService {
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';

  Future<String> uploadLeafImage(String imagePath) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/${Secrets.cloudinaryCloudName}/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = Secrets.cloudinaryUploadPreset;
      request.fields['folder'] = 'greenscan_leaves';

      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return json['secure_url'] as String;
      } else {
        throw Exception('Upload failed: ${json['error']['message']}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}
