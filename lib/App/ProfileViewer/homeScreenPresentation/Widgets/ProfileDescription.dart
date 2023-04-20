import 'package:flutter/material.dart';

class ProfileDescription extends StatelessWidget {
  final String bio;
  final BoxConstraints constraints;
  const ProfileDescription({required this.bio, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: constraints.maxHeight / 3,
      width: constraints.maxWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(bio),
      ),
    );
  }
}

class ProfileFoot extends StatelessWidget {
  final BoxConstraints constraints;
  const ProfileFoot({ required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: constraints.maxHeight / 3,
      width: constraints.maxWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
      ),
    );
  }
}