import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'lossless_optimizer.dart';

abstract class R2StorageService {
  Future<String?> uploadFile({
    required String objectKey,
    required File file,
    String? contentType,
  });

  Future<String?> uploadBytes({
    required String objectKey,
    required Uint8List bytes,
    String? contentType,
  });

  Future<bool> deleteFile(String objectKey);

  String getPublicUrl(String objectKey);
}

class R2StorageServiceImpl implements R2StorageService {
  final String accountId;
  final String accessKeyId;
  final String secretAccessKey;
  final String bucketName;
  final String publicBaseUrl;

  R2StorageServiceImpl({
    this.accountId = 'e047b8102b56a5e1688aaa9f856b0472',
    this.accessKeyId = '7db2ad944f6756a972d2801d593a93cd',
    this.secretAccessKey =
        '0fa67e8a7674e8079811de4cb717b38afebf7be94820a918ee7efbadac9b9d93',
    this.bucketName = 'picstools-cloud',
    this.publicBaseUrl =
        'https://pub-eb2560872a184d01a125f4362bd0d6c4.r2.dev',
  });

  @override
  String getPublicUrl(String objectKey) {
    final sanitizedKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
    final sanitizedBase = publicBaseUrl.endsWith('/')
        ? publicBaseUrl.substring(0, publicBaseUrl.length - 1)
        : publicBaseUrl;
    return '$sanitizedBase/$sanitizedKey';
  }

  @override
  Future<String?> uploadFile({
    required String objectKey,
    required File file,
    String? contentType,
  }) async {
    try {
      if (!await file.exists()) {
        debugPrint('❌ [R2Storage] File does not exist at ${file.path}');
        return null;
      }
      final rawBytes = await file.readAsBytes();
      final bytes = await LosslessImageOptimizer.optimize(
        bytes: rawBytes,
        filePath: file.path,
      );
      final determinedContentType =
          contentType ?? _inferContentType(file.path);
      return await uploadBytes(
        objectKey: objectKey,
        bytes: bytes,
        contentType: determinedContentType,
      );
    } catch (e) {
      debugPrint('❌ [R2Storage] uploadFile error: $e');
      return null;
    }
  }

  @override
  Future<String?> uploadBytes({
    required String objectKey,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      final sanitizedKey =
          objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
      final mimeType = contentType ?? 'application/octet-stream';
      final host = '$accountId.r2.cloudflarestorage.com';
      final uri = Uri.parse('https://$host/$bucketName/$sanitizedKey');

      final now = DateTime.now().toUtc();
      final amzDate = _formatAmzDate(now);
      final dateStamp = _formatDateStamp(now);
      final payloadHash = sha256.convert(bytes).toString();

      final headers = <String, String>{
        'host': host,
        'content-type': mimeType,
        'x-amz-content-sha256': payloadHash,
        'x-amz-date': amzDate,
      };

      final authHeader = _computeSigV4(
        method: 'PUT',
        canonicalUri: '/$bucketName/$sanitizedKey',
        headers: headers,
        payloadHash: payloadHash,
        dateStamp: dateStamp,
        amzDate: amzDate,
      );

      headers['Authorization'] = authHeader;

      final client = HttpClient();
      try {
        final request = await client.putUrl(uri);
        request.contentLength = bytes.length;
        headers.forEach((k, v) => request.headers.set(k, v));
        request.add(bytes);
        final response = await request.close();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final publicUrl = getPublicUrl(sanitizedKey);
          debugPrint('🎉 [R2Storage] Uploaded $sanitizedKey -> $publicUrl');
          return publicUrl;
        } else {
          final body = await response.transform(utf8.decoder).join();
          debugPrint('❌ [R2Storage] Upload failed (${response.statusCode}): $body');
          return null;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('❌ [R2Storage] uploadBytes error: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteFile(String objectKey) async {
    try {
      final sanitizedKey =
          objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
      final host = '$accountId.r2.cloudflarestorage.com';
      final uri = Uri.parse('https://$host/$bucketName/$sanitizedKey');

      final now = DateTime.now().toUtc();
      final amzDate = _formatAmzDate(now);
      final dateStamp = _formatDateStamp(now);
      final payloadHash = sha256.convert(const []).toString();

      final headers = <String, String>{
        'host': host,
        'x-amz-content-sha256': payloadHash,
        'x-amz-date': amzDate,
      };

      final authHeader = _computeSigV4(
        method: 'DELETE',
        canonicalUri: '/$bucketName/$sanitizedKey',
        headers: headers,
        payloadHash: payloadHash,
        dateStamp: dateStamp,
        amzDate: amzDate,
      );

      headers['Authorization'] = authHeader;

      final client = HttpClient();
      try {
        final request = await client.deleteUrl(uri);
        request.contentLength = 0;
        headers.forEach((k, v) => request.headers.set(k, v));
        final response = await request.close();
        return response.statusCode == 204 || response.statusCode == 200;
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('❌ [R2Storage] deleteFile error: $e');
      return false;
    }
  }

  String _computeSigV4({
    required String method,
    required String canonicalUri,
    required Map<String, String> headers,
    required String payloadHash,
    required String dateStamp,
    required String amzDate,
  }) {
    const region = 'auto';
    const service = 's3';

    // Canonical headers
    final sortedHeaderKeys = headers.keys.map((k) => k.toLowerCase()).toList()..sort();
    final canonicalHeaders = sortedHeaderKeys
        .map((k) => '$k:${headers[k]!.trim()}\n')
        .join();
    final signedHeaders = sortedHeaderKeys.join(';');

    final canonicalRequest = [
      method,
      canonicalUri,
      '', // canonical querystring
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final canonicalRequestHash =
        sha256.convert(utf8.encode(canonicalRequest)).toString();

    const algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = '$dateStamp/$region/$service/aws4_request';
    final stringToSign = [
      algorithm,
      amzDate,
      credentialScope,
      canonicalRequestHash,
    ].join('\n');

    final kDate = _hmacSha256(utf8.encode('AWS4$secretAccessKey'), dateStamp);
    final kRegion = _hmacSha256(kDate, region);
    final kService = _hmacSha256(kRegion, service);
    final kSigning = _hmacSha256(kService, 'aws4_request');
    final signature =
        Hmac(sha256, kSigning).convert(utf8.encode(stringToSign)).toString();

    return '$algorithm Credential=$accessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';
  }

  List<int> _hmacSha256(List<int> key, String data) {
    return Hmac(sha256, key).convert(utf8.encode(data)).bytes;
  }

  String _formatAmzDate(DateTime d) {
    String pad(int n, [int width = 2]) => n.toString().padLeft(width, '0');
    return '${d.year}${pad(d.month)}${pad(d.day)}T${pad(d.hour)}${pad(d.minute)}${pad(d.second)}Z';
  }

  String _formatDateStamp(DateTime d) {
    String pad(int n, [int width = 2]) => n.toString().padLeft(width, '0');
    return '${d.year}${pad(d.month)}${pad(d.day)}';
  }

  String _inferContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }
}

class MockR2StorageServiceImpl implements R2StorageService {
  final Map<String, Uint8List> uploadedObjects = {};

  @override
  String getPublicUrl(String objectKey) {
    return 'https://mock.r2.dev/$objectKey';
  }

  @override
  Future<String?> uploadFile({
    required String objectKey,
    required File file,
    String? contentType,
  }) async {
    uploadedObjects[objectKey] = Uint8List.fromList([1, 2, 3]);
    return getPublicUrl(objectKey);
  }

  @override
  Future<String?> uploadBytes({
    required String objectKey,
    required Uint8List bytes,
    String? contentType,
  }) async {
    uploadedObjects[objectKey] = bytes;
    return getPublicUrl(objectKey);
  }

  @override
  Future<bool> deleteFile(String objectKey) async {
    uploadedObjects.remove(objectKey);
    return true;
  }
}
