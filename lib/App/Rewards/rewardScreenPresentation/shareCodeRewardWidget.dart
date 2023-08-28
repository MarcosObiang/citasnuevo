import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'rewardScreenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ShareCodeRewardCard extends StatefulWidget {
  RewardScreenPresentation rewardScreenPresentation;
  ShareCodeRewardCard({
    required this.rewardScreenPresentation,
  });

  @override
  State<ShareCodeRewardCard> createState() => _ShareCodeRewardCardState();
}

class _ShareCodeRewardCardState extends State<ShareCodeRewardCard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(30.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Invita a un amigo y gana",
                          style: Theme.of(context).textTheme.titleMedium?.apply(
                              color: Theme.of(context).colorScheme.onSurface)),
                      Row(
                        children: [
                          Text("5000",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
                          Icon(LineAwesomeIcons.coins,
                              color: Theme.of(context).colorScheme.onSurface)
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 50.h,
                  ),
                  Text(
                      "Comparte este codigo con un amigo y gana cuando se registre",
                      style: Theme.of(context).textTheme.bodyMedium?.apply(
                          color: Theme.of(context).colorScheme.onSurface)),
                  Divider(
                    color: Colors.transparent,
                    height: 50.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Codigo",
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                              color: Theme.of(context).colorScheme.onSurface)),
                      SelectableText(
                        widget.rewardScreenPresentation.sharingLink as String,
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 50.h,
                      ),
                      FilledButton.tonal(
                          onPressed: () {
                            Clipboard.setData(new ClipboardData(
                                text: widget.rewardScreenPresentation
                                    .sharingLink as String));
                          },
                          child: Text(
                            'Copiar codigo',
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
