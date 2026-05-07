import 'dart:convert';

import 'package:http/http.dart' as http;

import '../http_client_factory.dart';

class R2UploadService {
  final Uri endpoint;

  R2UploadService({required this.endpoint});

  Future<List<String>> uploadImages({
    required String propertyName,
    required List<http.MultipartFile> images,
  }) async {
    final client = createHttpClient();
    try {
      final request = http.MultipartRequest('POST', endpoint);
      request.fields['propertyName'] = propertyName;
      for (final f in images) {
        request.files.add(f);
      }

      print('UPLOAD URL: $endpoint');
      print('FIELDS: ${request.fields}');
      print('FILES COUNT: ${request.files.length}');
      for (final f in request.files) {
        print('FILE -> field: ${f.field}');
        print('FILE -> filename: ${f.filename}');
        print('FILE -> length: ${f.length}');
        print('FILE -> contentType: ${f.contentType}');
      }

      final streamed = await client.send(request);
      final response = await http.Response.fromStream(streamed);

      print('STATUS: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Upload failed (${response.statusCode}): ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response');
      }

      final urls = decoded['urls'];
      if (urls is! List) {
        throw Exception('Invalid response format');
      }

      return urls.map((e) => e.toString()).toList();
    } finally {
      client.close();
    }
  }
}
