import 'package:flutter/material.dart';
class GoToRoute extends PageRouteBuilder {
  final Widget page;
  GoToRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: Duration(milliseconds: 100),
          reverseTransitionDuration: Duration(milliseconds: 100),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(

                opacity: animation,
          
            child: child,
          ),
        );}