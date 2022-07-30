import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/NavigationBar.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../appSettingsPresentation/appSettingsScreen.dart';

class HomeAppScreen extends StatefulWidget {
  static final GlobalKey<AnimatedListState> profilesKey = GlobalKey();

  @override
  State<StatefulWidget> createState() {
    return _HomeAppScreenState();
  }
}

class _HomeAppScreenState extends State<HomeAppScreen>  with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
        WidgetsBinding.instance.addObserver(this);

  }

  void dispose(){
    super.dispose();
            WidgetsBinding.instance.removeObserver(this);


  }
AppLifecycleState appLifecycleState = AppLifecycleState.resumed;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if(state==AppLifecycleState.resumed){

    }
  }
  

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.homeScreenPresentation,
      child: Consumer<HomeScreenPresentation>(builder: (BuildContext context,
          HomeScreenPresentation homeScreenPresentation, Widget? child) {
        return Material(
          color: Colors.lightBlue,
          child: SafeArea(
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: [
                  Container(
                      color: Colors.deepPurple,
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                      child: homeScreenPresentation.profileListState ==
                              ProfileListState.error
                          ? serverError(homeScreenPresentation)
                          : homeScreenPresentation.profileListState ==
                                  ProfileListState.ready
                              ? profileListLoaded(
                                  homeScreenPresentation, constraints)
                              : homeScreenPresentation.profileListState ==
                                      ProfileListState.loading
                                  ? loadingProfiles()
                                  : homeScreenPresentation.profileListState ==
                                          ProfileListState.location_denied
                                      ? locationDeniedDialog(
                                          homeScreenPresentation)
                                      : homeScreenPresentation
                                                  .profileListState ==
                                              ProfileListState
                                                  .location_forever_denied
                                          ? locationDeniedForeverDialog(
                                              homeScreenPresentation)
                                          : homeScreenPresentation
                                                      .profileListState ==
                                                  ProfileListState
                                                      .location_disabled
                                              ? locationServicesDisabledDialog(
                                                  homeScreenPresentation)
                                              : homeScreenPresentation
                                                          .profileListState ==
                                                      ProfileListState
                                                          .profile_not_visible
                                                  ? invisibleProfileDialog(
                                                      homeScreenPresentation,
                                                      context)
                                                  : homeScreenPresentation
                                                              .profileListState ==
                                                          ProfileListState
                                                              .location_status_unknown
                                                      ? unableToDetermineLocationStatus(
                                                          homeScreenPresentation)
                                                      : noMoreProfilesDialog(
                                                          homeScreenPresentation,
                                                          context)),
                  HomeNavigationBar(
                      newChats: homeScreenPresentation.getNewChats,
                      newMessages: homeScreenPresentation.getNewMessages,
                      newReactions: homeScreenPresentation.getNewReactions)
                ],
              );
            }),
          ),
        );
      }),
    );
  }

  Container locationDeniedDialog(
      HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.my_location_outlined,
            color: Colors.white,
            size: 90.sp,
          ),
          Text(
            "Hotty necesita acceder a su localizacion para mostrarte perfiles cercanos a ti",
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 60.sp),
          ),
          ElevatedButton(
              onPressed: () {
                homeScreenPresentation.requestPermission();
              },
              child: Text("Dar permiso"))
        ],
      ),
    ));
  }

  Container locationDeniedForeverDialog(
      HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Parece que a Hotty se le ha negado el acceso a la ubicacion del telefono, deberás ir a ajustes para darnos permiso",
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 60.sp),
          ),
          ElevatedButton.icon(
              onPressed: () {
                homeScreenPresentation.openLocationSettings();
              },
              icon: Icon(Icons.settings),
              label: Text("Ir a ajustes")),
          Text(
            "- Si has ya has dato a hotty permiso desde los ajustes pulsa intentar de nuevo",
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 60.sp),
          ),
          ElevatedButton.icon(
              onPressed: () {
                homeScreenPresentation.getProfiles();
              },
              icon: Icon(Icons.refresh),
              label: Text("Intentar de nuevo"))
        ],
      ),
    ));
  }

  Container unableToDetermineLocationStatus(
      HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Hotty no puede determinar el estado de tu sistema de localizacion, asegurate de tener tu sistema de localizacion activado, luego reinicia la aplicacion y si el problema persiste contacta con soporte",
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 60.sp),
          ),
          ElevatedButton.icon(
              onPressed: () {
                homeScreenPresentation.getProfiles();
              },
              icon: Icon(Icons.refresh),
              label: Text("Intentar de nuevo"))
        ],
      ),
    ));
  }

  Container locationServicesDisabledDialog(
      HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Hotty necesita acceder a su localizacion para mostrarte perfiles cercanos a ti",
          style: GoogleFonts.roboto(color: Colors.white, fontSize: 50.sp),
        ),
        ElevatedButton(
            onPressed: () {
              Geolocator.openLocationSettings();
            },
            child: Text("Activar servicios ubicacion")),
        Text(
          "Si ya ha activado los servicios de ubicacion pulse en intentar de nuevo",
          style: GoogleFonts.roboto(color: Colors.white, fontSize: 50.sp),
        ),
        ElevatedButton.icon(
            onPressed: () {
              homeScreenPresentation.getProfiles();
            },
            icon: Icon(Icons.refresh),
            label: Text("Intentar de nuevo"))
      ],
    ));
  }

  Container noMoreProfilesDialog(
      HomeScreenPresentation homeScreenPresentation, BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Vaya...... no hemos enconotrado a nadie que coincida con tus filtros de busqueda, prueba a cambiarlos",
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 60.sp),
          ),
          ElevatedButton(
              onPressed: () {

                Navigator.push(context, GoToRoute(page: AppSettingsScreen()));
              },
              child: Text("Modificar filtros"))
        ],
      ),
    ));
  }

  Container invisibleProfileDialog(
      HomeScreenPresentation homeScreenPresentation, BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.my_location_outlined,
            color: Colors.white,
            size: 90.sp,
          ),
          Text(
            "No puedes ver perfiles mientras tu perfil esta oculto, activa la visibilidad de tu perfil es Ajustes > Mostrar perfil",
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 50.sp),
          ),
          ElevatedButton(
              onPressed: () {
                homeScreenPresentation.restart();

                Navigator.push(context, GoToRoute(page: AppSettingsScreen()));
              },
              child: Text("Ir a ajustes")),
          Text(
            "Si sigues viendo este mensaje despues de activar la visibilidad pulsa intentar de nuevo",
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 50.sp),
          ),
          ElevatedButton.icon(
              onPressed: () {
                homeScreenPresentation.getProfiles();
              },
              icon: Icon(Icons.refresh),
              label: Text("Intentar de nuevo"))
        ],
      ),
    ));
  }

  Container serverError(HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            "Ups... ha habido un error buscando perfiles, intentalo de nuevo ahora o mas tarde.Si sigue teniendo problemas contacte con soporte"),
        ElevatedButton.icon(
            onPressed: () {
              homeScreenPresentation.restart();
            },
            icon: Icon(Icons.refresh),
            label: Text("Intentar de nuevo"))
      ],
    ));
  }

  Column loadingProfiles() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 200.h,
          width: 200.h,
          child: LoadingIndicator(indicatorType: Indicator.circleStrokeSpin),
        ),
        Text("Cargando")
      ],
    );
  }

  AnimatedList profileListLoaded(HomeScreenPresentation homeScreenPresentation,
      BoxConstraints constraints) {
    return AnimatedList(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        initialItemCount:
            homeScreenPresentation.homeScreenController.profilesList.length,
        key: HomeAppScreen.profilesKey,
        itemBuilder:
            (BuildContext context, int index, Animation<double> animation) {
          return FadeTransition(
              opacity: animation,
              child: ProfileWidget(
                boxConstraints: constraints,
                profile: homeScreenPresentation
                    .homeScreenController.profilesList[index],
                needRatingWidget: true,
                listIndex: index,
              ));
        });
  }
}
