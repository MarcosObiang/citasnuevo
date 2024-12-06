import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/foundation.dart';

import '../core/dependencies/dependencyCreator.dart';

class ImageFile {
  static Future<Uint8List> getFile(
      {required String fileId, required String bucketId, bool? preview}) async {
    late Uint8List imageData;
    Storage storage = Storage(Dependencies.serverAPi.client);

    try {
      if (preview != null) {
        if (preview) {
          imageData =
              await storage.getFilePreview(bucketId: bucketId, fileId: fileId);
          return imageData;
        }
      }

      imageData =
          await storage.getFileDownload(bucketId: bucketId, fileId: fileId);
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
