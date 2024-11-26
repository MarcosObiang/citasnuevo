import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/foundation.dart';

import '../core/dependencies/dependencyCreator.dart';

class ImageFile {
  static Future<Uint8List> getFile({required String fileId}) async {

    late Uint8List imageData;
    try {
      Storage storage = Storage(Dependencies.serverAPi.client);

      imageData = await storage.getFileDownload(bucketId: kUserPicturesBucketId, fileId: fileId);
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
