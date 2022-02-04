import 'package:citasnuevo/domain/entities/ProfileCharacteristicsEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
    characteristics = createProfileCharacteristicsWidgets();
  }

  List<Widget> characteristics = [];
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 10.w,
          runSpacing: 20.h,
          children: characteristics,
        ));
  }

  List<Widget> createProfileCharacteristicsWidgets() {
    List<Widget> widgetList = [];
    var data = widget.profileCharateristicsData;

    data.forEach((element) {
      widgetList.add(widgetValor(element.sameAsUser, Icon(element.iconData),
          element.characteristicValue));
    });

    return widgetList;
  }

  Container widgetValor(bool esIgual, Icon icono, String valor) {
    return Container(
      width: 500.w,
      decoration: BoxDecoration(
        color: esIgual ? Colors.deepPurple : Colors.grey[400],
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icono,
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                valor,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: esIgual ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

