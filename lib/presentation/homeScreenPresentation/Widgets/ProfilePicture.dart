import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class ProfilePicture extends StatelessWidget {
  final Map profilePicture;
  final BoxConstraints boxConstraints;
  ProfilePicture({required this.profilePicture, required this.boxConstraints});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: boxConstraints.maxHeight,
        width: boxConstraints.maxWidth,
        child: OctoImage(
          fadeInDuration: Duration(milliseconds: 50),
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(profilePicture["Imagen"]),
          placeholderBuilder: OctoPlaceholder.blurHash(profilePicture["hash"],
              fit: BoxFit.cover),
        ));
  }
}
