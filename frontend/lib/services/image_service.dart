class ImageService {
  static const String _baseUrl = 'http://localhost:8080';

  static String getFullImageUrl(String relativePath) {
    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$_baseUrl$path';
  }
}
