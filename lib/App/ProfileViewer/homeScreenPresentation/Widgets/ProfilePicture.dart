import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../core/dependencies/dependencyCreator.dart';

class ProfilePicture extends StatefulWidget {
  final Map profilePicture;
  final BoxConstraints boxConstraints;
  final storage = Storage(Dependencies.serverAPi.client!);
  Uint8List? imageData;
  final bool isFirstPicture;

  ProfilePicture(
      {required this.profilePicture,
      required this.boxConstraints,
      required this.isFirstPicture});

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
    return widget.imageData != null
        ? Container(
            height: widget.boxConstraints.maxHeight,
            child: Image.memory(
              widget.imageData!,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            height: widget.boxConstraints.maxHeight,
            child: Center(
              child: Container(
                  color: Colors.transparent,
                  height: 200.h,
                  width: 200.h,
                  child: LoadingIndicator(
                      indicatorType: Indicator.circleStrokeSpin)),
            ),
          );
  }
}
