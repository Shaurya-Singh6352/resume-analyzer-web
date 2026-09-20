import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:resume_analyzer_web/models/analysis_result.dart';

// Override at build time: flutter run --dart-define=API_URL=https://...
const String apiBase =
String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Uploads the file, then fetches its analysis.
  Future<AnalysisResult> uploadAndAnalyze(PlatformFile file) async {
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final upload = await _dio.post('/api/resumes', data: form);
      final id = upload.data['id'];

      final res = await _dio.get('/api/resumes/$id/analysis');
      return AnalysisResult.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_messageFrom(e));
    }
  }

  String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    if (e.response == null) {
      return 'Cannot reach the server. Is the backend running?';
    }
    return 'Something went wrong (status ${e.response?.statusCode}).';
  }
}