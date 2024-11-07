import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../UserCreator/ProfileCharacteristicsEntity.dart';

class ProfileCharateristicsWidget extends StatefulWidget {
  final List<ProfileCharacteristics> profileCharateristicsData;
  bool _isInitialized = false;

  final BoxConstraints constraints;
   ProfileCharateristicsWidget(
      {required this.profileCharateristicsData, required this.constraints});

  @override
  State<ProfileCharateristicsWidget> createState() =>
      _ProfileCharateristicsWidgetState();
}

class _ProfileCharateristicsWidgetState
    extends State<ProfileCharateristicsWidget> {
  void initState() {
    super.initState();

  }

  void didChangeDependencies() {
    super.didChangeDependencies();

    if(widget._isInitialized == false) {
            characteristics = createProfileCharacteristicsWidgets(false);
    comonInterests = createProfileCharacteristicsWidgets(true);
    widget._isInitialized = true;
      
    }
  
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
                    AppLocalizations.of(context)!.common_interests_between_users,
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
                   AppLocalizations.of(context)!.intereses,
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
      if (element.characteristicIndex != 0&&sameInterestAsUSer==true&&element.sameAsUser==true) {
          widgetList.add(widgetValor(element.sameAsUser, Icon(element.iconData, color: Theme.of(context).colorScheme.onPrimary,),
              element.characteristicValue,true));
        
      

      }
      if(element.characteristicIndex != 0&&sameInterestAsUSer==false) {
        widgetList.add(widgetValor(element.sameAsUser, Icon(element.iconData ,color: Theme.of(context).colorScheme.onPrimaryContainer,),
            element.characteristicValue,false));
      }
    });

    return widgetList;
  }

  Widget widgetValor(bool esIgual, Icon icono, String valor, bool commonInterest) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: FilterChip(
        avatar: icono,
        selected: true,
        selectedColor:  commonInterest==true?Theme.of(context).colorScheme.primary:Theme.of(context).colorScheme.primaryContainer,
        
        showCheckmark: false,
        label: Text(
          valor,
          style: Theme.of(startKey.currentContext as BuildContext)
              .textTheme
              .labelSmall
              ?.apply(
                  color: commonInterest==true? Theme.of(startKey.currentContext as BuildContext)
                      .colorScheme
                      .onPrimary:Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeightDelta: 2),
        ),
        onSelected: (onSelected) {},
      ),
    );
  }
}
