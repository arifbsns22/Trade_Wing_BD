import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:minio/minio.dart';

class R2StorageService {
  late final Minio _minio;

  // TODO: Replace with your actual R2 Bucket Name
  final String bucketName = 'tradewingbd';

  // TODO: Replace with your custom domain or R2 public access URL if configured
  // E.g., 'https://pub-e765ef492d604fa36bd1b6e44092354d.r2.dev' or 'https://images.tradewignbd.com'
  final String publicBaseUrl =
      'https://pub-f79e83d1af1b400f9c54301c8230b986.r2.dev';

  R2StorageService() {
    _minio = Minio(
      // Cloudflare R2 S3-Compatible Endpoint: <account_id>.r2.cloudflarestorage.com
      endPoint: 'e765ef492d604fa36bd1b6e44092354d.r2.cloudflarestorage.com',

      accessKey: 'eb41285eff4fe648b94282e9ce5a4833',
      secretKey: 'fff222b4c8311badba72533413e5615819a535a310c51b0f762c3340a4057456',
      useSSL: true,
    );
  }

  /// Uploads raw bytes to Cloudflare R2 bucket.
  /// Returns the public access URL of the uploaded object, or null if failed.
  Future<String?> uploadBytes({
    required Uint8List bytes,
    required String destinationPath,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      final int size = bytes.length;
      final Stream<Uint8List> stream = Stream.value(bytes);

      debugPrint('Uploading $destinationPath to R2 ($size bytes)...');

      // Upload the object
      await _minio.putObject(
        bucketName,
        destinationPath,
        stream,
        size: size,
        metadata: {'content-type': contentType},
      );

      debugPrint('Upload successful!');
      return '$publicBaseUrl/$destinationPath';
    } catch (e) {
      debugPrint('R2 Upload Error: $e');
      return null;
    }
  }

  /// Uploads a file to Cloudflare R2 bucket (Native only).
  /// Returns the public access URL of the uploaded object, or null if failed.
  Future<String?> uploadFile({
    required File file,
    required String destinationPath,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      return uploadBytes(
        bytes: bytes,
        destinationPath: destinationPath,
        contentType: contentType,
      );
    } catch (e) {
      debugPrint('R2 File Upload Error: $e');
      return null;
    }
  }

  /// Downloads a file from Cloudflare R2 bucket.
  Future<Stream<List<int>>> downloadFile(String objectName) async {
    return await _minio.getObject(bucketName, objectName);
  }

  /// Deletes a file from Cloudflare R2 bucket.
  Future<void> deleteFile(String objectName) async {
    await _minio.removeObject(bucketName, objectName);
  }
}
