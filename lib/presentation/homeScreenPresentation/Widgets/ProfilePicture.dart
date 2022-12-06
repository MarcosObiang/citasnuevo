import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class ProfilePicture extends StatefulWidget {
  final Map profilePicture;
  final BoxConstraints boxConstraints;
  final storage = Storage(Dependencies.serverAPi.client!);
  Uint8List? imageData;

  ProfilePicture({required this.profilePicture, required this.boxConstraints});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  @override
  void initState() {
    super.initState();
    if (widget.imageData == null) {
      _getImageData();
    }
  }

  void _getImageData() async {
    try {
      widget.imageData = await widget.storage.getFileDownload(
        bucketId: '63712fd65399f32a5414',
        fileId: widget.profilePicture["imageId"],
      );
      setState(() {});
    } catch (e) {
      if (e is AppwriteException) {
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.boxConstraints.maxHeight,
        width: widget.boxConstraints.maxWidth,
        child: widget.imageData != null
            ? Image.memory(
                widget.imageData!,
              )
            : CircularProgressIndicator());
  }
}
