import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../core/dependencies/dependencyCreator.dart';

class ImageFile {
  static Future<Uint8List> getFile({required String fileId}) async {
    final storage = Storage(Dependencies.serverAPi.client!);

    late Uint8List imageData;
    try {
      imageData = await storage.getFileDownload(
        bucketId: '63712fd65399f32a5414',
        fileId: fileId,
      );
      return imageData;
    } catch (e) {
      if (e is AppwriteException) {
        throw Exception(e.message);
      } else {
        throw Exception(e.toString());
      }
    }
  }
}
