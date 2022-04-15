import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/presentation/appSettingsPresentation/appSettingsScreen.dart';
import 'package:citasnuevo/presentation/settingsPresentation/settingsScreenPresentation.dart';
import 'package:citasnuevo/presentation/userSettingsPresentation/userSettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import '../Routes.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen();

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.settingsScreenPresentation,
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Consumer<SettingsScreenPresentation>(builder:
              (BuildContext context,
                  SettingsScreenPresentation settingsScreenPresentation,
                  Widget? child) {
            return Container(
              color: Colors.white,
              child: settingsScreenPresentation.settingsScreenState ==
                      SettingsScreenState.loaded
                  ? Column(children: [
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Row(
                            children: [
                              Flexible(
                                flex: 4,
                                fit: FlexFit.tight,
                                child: Container(
                                    child: OctoImage(
                                  fadeInDuration: Duration(milliseconds: 50),
                                  fit: BoxFit.fitHeight,
                                  image: CachedNetworkImageProvider(
                                      settingsScreenPresentation
                                          .settingsEntity.userPicture),
                                  placeholderBuilder: OctoPlaceholder.blurHash(
                                      settingsScreenPresentation
                                          .settingsEntity.userPictureHash,
                                      fit: BoxFit.cover),
                                )),
                              ),
                              Flexible(
                                  flex: 7,
                                  fit: FlexFit.tight,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        settingsScreenPresentation
                                            .settingsEntity.userName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(settingsScreenPresentation
                                          .settingsEntity.userAge
                                          .toString()),
                                      Container(
                                        width: 500.w,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  GoToRoute(
                                                      page:
                                                          AppSettingsScreen()));
                                            },
                                            child: Text("Ajustes")),
                                      ),
                                      Container(
                                        width: 500.w,
                                        child: ElevatedButton(
                                            onPressed: () {
                                                  Navigator.push(
                                                  context,
                                                  GoToRoute(
                                                      page:
                                                          UserSettingsScreen()));
                                            },
                                            child: Text("Editar perfil")),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 8,
                        fit: FlexFit.tight,
                        child: Container(
                          color: Colors.white,
                        ),
                      )
                    ])
                  : settingsScreenPresentation.settingsScreenState ==
                          SettingsScreenState.error
                      ? Container(
                          color: Colors.red,
                          child: Center(
                            child: ElevatedButton.icon(
                                onPressed: () =>
                                    settingsScreenPresentation.restart(),
                                icon: Icon(Icons.refresh),
                                label: Text("Intentar de nuevo")),
                          ))
                      : Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Cargando"),
                              Container(
                                height: 300.h,
                                width: 300.h,
                                child: LoadingIndicator(
                                    indicatorType:
                                        Indicator.ballSpinFadeLoader),
                              )
                            ],
                          ),
                        ),
            );
          }),
        ),
      ),
    );
  }
}
