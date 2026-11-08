import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/shared/providers/firebase_providers.dart';
import 'package:uuid/uuid.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(firebaseStorageProvider));
});

class StorageService {
  final FirebaseStorage _storage;
  static const _uuid = Uuid();

  StorageService(this._storage);

  /// Uploads a file and returns the download URL.
  Future<String> uploadFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    final name = fileName ?? '${_uuid.v4()}${_getExtension(file.path)}';
    final ref = _storage.ref().child(path).child(name);

    final metadata = SettableMetadata(
      contentType: _getContentType(file.path),
      customMetadata: {
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    final uploadTask = ref.putFile(file, metadata);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads profile image with compression-ready path.
  Future<String> uploadProfileImage({
    required File file,
    required String userId,
  }) async {
    return uploadFile(
      file: file,
      path: 'profile_images',
      fileName: '$userId${_getExtension(file.path)}',
    );
  }

  /// Uploads event image.
  Future<String> uploadEventImage({
    required File file,
    required String eventId,
  }) async {
    return uploadFile(
      file: file,
      path: 'event_images',
      fileName: '${eventId}_${_uuid.v4()}${_getExtension(file.path)}',
    );
  }

  /// Uploads club image.
  Future<String> uploadClubImage({
    required File file,
    required String clubId,
  }) async {
    return uploadFile(
      file: file,
      path: 'club_images',
      fileName: '${clubId}_${_uuid.v4()}${_getExtension(file.path)}',
    );
  }

  /// Deletes a file by its download URL.
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // File may already be deleted; ignore.
    }
  }

  String _getExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return '.$ext';
  }

  String _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}

