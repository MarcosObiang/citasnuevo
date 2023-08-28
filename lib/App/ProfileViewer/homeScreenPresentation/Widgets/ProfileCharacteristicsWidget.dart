import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../UserCreator/ProfileCharacteristicsEntity.dart';

class ProfileCharateristicsWidget extends StatefulWidget {
  final List<ProfileCharacteristics> profileCharateristicsData;

  final BoxConstraints constraints;
  const ProfileCharateristicsWidget(
      {required this.profileCharateristicsData, required this.constraints});

  @override
  State<ProfileCharateristicsWidget> createState() =>
      _ProfileCharateristicsWidgetState();
}

class _ProfileCharateristicsWidgetState
    extends State<ProfileCharateristicsWidget> {
  void initState() {
    super.initState();
    characteristics = createProfileCharacteristicsWidgets(false);
    comonInterests = createProfileCharacteristicsWidgets(true);
  }

  List<Widget> characteristics = [];
  List<Widget> comonInterests = [];
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            comonInterests.isNotEmpty
                ? Text(
                    "Intereses comunes",
                    style: Theme.of(context).textTheme.bodyMedium?.apply(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeightDelta: 2),
                  )
                : Container(),
            Wrap(
              children: comonInterests,
            ),
            characteristics.isNotEmpty
                ? Text(
                    "Intereses",
                    style: Theme.of(context).textTheme.bodyMedium?.apply(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeightDelta: 2),
                  )
                : Container(),
            Wrap(
              children: characteristics,
            ),
          ],
        ));
  }

  List<Widget> createProfileCharacteristicsWidgets(bool sameInterestAsUSer) {
    List<Widget> widgetList = [];
    var data = widget.profileCharateristicsData;
    int i = 1;

    data.forEach((element) {
      if (element.characteristicIndex == 0) {
        if (i % 2 == 0 && sameInterestAsUSer == false) {
          widgetList.add(widgetValor(sameInterestAsUSer, Icon(element.iconData),
              element.characteristicValue));
        }
        if (i % 3 == 0 && sameInterestAsUSer == true) {
          widgetList.add(widgetValor(sameInterestAsUSer, Icon(element.iconData),
              element.characteristicValue));
        }

        i = i + 1;
      }
    });

    return widgetList;
  }

  Widget widgetValor(bool esIgual, Icon icono, String valor) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: FilterChip(
        avatar: icono,
        selected: true,
        showCheckmark: false,
        label: Text(
          valor,
          style: Theme.of(startKey.currentContext as BuildContext)
              .textTheme
              .labelSmall
              ?.apply(
                  color: Theme.of(startKey.currentContext as BuildContext)
                      .colorScheme
                      .onPrimaryContainer,
                  fontWeightDelta: 2),
        ),
        onSelected: (onSelected) {},
      ),
    );
  }
}
