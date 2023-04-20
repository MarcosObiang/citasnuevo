import 'package:citasnuevo/Utils/routes.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/services/Ads.dart';
import 'package:citasnuevo/main.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../App/PurchaseSystem/purchaseSystemPresentation/purchaseScreen.dart';

class PresentationDialogs {
  static PresentationDialogs instance = PresentationDialogs();

  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
    if (context != null) {
      showDialog(
          context: context,
          builder: (context) =>
              GenericErrorDialog(title: title, content: content));
    }
  }

  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  void showAdConsentDialog() {
    Navigator.push(startKey.currentContext as BuildContext,
        GoToRoute(page: AdConsentform()));
  }

  void showErrorDialogWithOptions(
      {required BuildContext? context,
      required List<DialogOptions> dialogOptionsList,
      required String dialogTitle,
      required String dialogText}) {
    List<Widget> buttons = [];

    dialogOptionsList.forEach((element) {
      buttons.add(TextButton(
        child: Text(element.text),
        onPressed: () => element.function.call(),
      ));
    });

    if (context != null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(dialogTitle),
                content: Text(dialogText),
                actions: buttons,
              ));
    }
  }
}

class DialogOptions {
  /// The functions that will be called after pressing the button
  VoidCallback function;

  /// The visible name of the button
  String text;
  DialogOptions({
    required this.function,
    required this.text,
  });
}

class NetwortErrorWidget extends StatelessWidget {
  const NetwortErrorWidget();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text("No se ha detectado una conexion a internet"),
      title: Text("No hay conexion"),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Entendido"))
      ],
    );
  }
}

class GenericErrorDialog extends StatelessWidget {
  final String content;
  final String title;

  const GenericErrorDialog({required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(content),
      title: Text(title),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Entendido"))
      ],
    );
  }
}

class GenericDialog extends StatelessWidget {
  final String content;
  final String title;

  const GenericDialog({required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(content),
      title: Text(title),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Entendido"))
      ],
    );
  }
}

enum AdConsentformState { LOADING, ERROR, READY, DONE }

class AdConsentform extends StatefulWidget {
  AdConsentformState adConsentformState = AdConsentformState.READY;
  bool consent = false;
  AdConsentform();

  @override
  State<AdConsentform> createState() => _AdConsentformState();
}

class _AdConsentformState extends State<AdConsentform> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(50.w),
        child: Stack(
          children: [
            widget.adConsentformState == AdConsentformState.LOADING
                ? Container(
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Por favor, espere"),
                            Container(
                                height: 200.h,
                                width: 200.h,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.orbit))
                          ]),
                    ),
                  )
                : widget.adConsentformState == AdConsentformState.ERROR
                    ? Container(
                        child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Ha ocurrido un error inesperado"),
                                Column(
                                  children: [
                                    TextButton.icon(
                                        onPressed: () async {
                                          setState(() {
                                            widget.adConsentformState =
                                                AdConsentformState.LOADING;
                                          });
                                          bool result = await Dependencies
                                              .advertisingServices
                                              .setConsentStatus(
                                                  consentPersonalizedAds:
                                                      widget.consent);
                                          if (result) {
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.DONE;
                                            });
                                          } else {
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.ERROR;
                                            });
                                          }
                                        },
                                        icon: Icon(Icons.refresh),
                                        label: Text("Intentar de nuevo")),
                                    TextButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.refresh),
                                        label: Text("Intentar mas tarde"))
                                  ],
                                )
                              ]),
                        ),
                      )
                    : widget.adConsentformState == AdConsentformState.DONE
                        ? Container(
                            child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Gracias"),
                                    Column(
                                      children: [
                                        TextButton.icon(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Dependencies.clearDependenciesOnly();
                                              Dependencies.initializeDependencies();
                                            },
                                            icon: Icon(Icons.refresh),
                                            label: Text("Continuar")),
                                      ],
                                    )
                                  ]),
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(30.h),
                                  child: ListView(
                                    children: [
                                      Text(
                                        "Personaliza tu experiencia\n\n\nHotty solicita su consentimiento para personalizar su experiencia publicitaria mostrándole los anuncios que nosotros y nuestros socios creemos que son los más relevantes para usted. Según su configuración de privacidad, nuestro proveedor de anuncios Appodeal y sus socios pueden recopilar y procesar los siguientes datos personales: identificadores de dispositivos, datos de ubicación y otros datos demográficos y de interés. Esto tiene como objetivo brindarle una mejor experiencia publicitaria. Al aceptar, confirma que tiene más de 18 años y desea personalizar su experiencia publicitaria.",
                                        style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 50.sp),
                                        softWrap: true,
                                      ),
                                      Divider(
                                        height: 100.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text(
                                            "Almacenamiento y acceso a la información",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          collapsed: Text(
                                            "",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            maxLines: 1,
                                          ),
                                          expanded: Text(
                                            "El almacenamiento de información, o el acceso a información que ya está almacenada, en su dispositivo, como identificadores de publicidad, identificadores de dispositivos, cookies y tecnologías similares.",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            softWrap: true,
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text(
                                            "Personalización",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          collapsed: Text(
                                            "",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            maxLines: 1,
                                          ),
                                          expanded: Text(
                                            "La recopilación y el procesamiento de información sobre su uso de este servicio para personalizar posteriormente la publicidad y/o el contenido para usted en otros contextos, como en otros sitios web o aplicaciones, a lo largo del tiempo. Por lo general, el contenido del sitio o la aplicación se usa para hacer inferencias sobre sus intereses, lo que informa la selección futura de publicidad y/o contenido.",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            softWrap: true,
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text(
                                            "Selección de anuncios, entrega, informes",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          collapsed: Text(
                                            "",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            maxLines: 1,
                                          ),
                                          expanded: Text(
                                            "La recopilación de información, y la combinación con la información recopilada previamente, para seleccionar y enviar anuncios para usted, y para medir la entrega y la eficacia de dichos anuncios. Esto incluye el uso de información recopilada previamente sobre sus intereses para seleccionar anuncios, procesar datos sobre qué anuncios se mostraron, con qué frecuencia se mostraron, cuándo y dónde se mostraron, y si realizó alguna acción relacionada con el anuncio, incluido, por ejemplo, hacer clic en un anuncio o hacer una compra. Esto no incluye la personalización, que es la recopilación y el procesamiento de información sobre su uso de este servicio para personalizar posteriormente la publicidad y/o el contenido para usted en otros contextos, como sitios web o aplicaciones, a lo largo del tiempo.",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            softWrap: true,
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text(
                                            "Selección de contenido, entrega, informes",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          collapsed: Text(
                                            "",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            maxLines: 1,
                                          ),
                                          expanded: Text(
                                            "La recopilación de información, y la combinación con la información recopilada previamente, para seleccionar y entregarle contenido, y para medir la entrega y la efectividad de dicho contenido. Esto incluye el uso de información recopilada previamente sobre sus intereses para seleccionar contenido, procesar datos sobre qué contenido se mostró, con qué frecuencia o durante cuánto tiempo se mostró, cuándo y dónde se mostró, y si tomó alguna medida relacionada con el contenido, incluido por ejemplo, hacer clic en el contenido. Esto no incluye la personalización, que es la recopilación y el procesamiento de información sobre su uso de este servicio para personalizar posteriormente contenido y/o publicidad para usted en otros contextos, como sitios web o aplicaciones, a lo largo del tiempo.",
                                            softWrap: true,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text(
                                            "Medición",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Text(
                                            "La recopilación de información sobre su uso del contenido, y la combinación con información recopilada previamente, utilizada para medir, comprender e informar sobre su uso del servicio. Esto no incluye la personalización, la recopilación de información sobre su uso de este servicio para personalizar posteriormente contenido y/o publicidad para usted en otros contextos, es decir, en otro servicio, como sitios web o aplicaciones, a lo largo del tiempo.",
                                            softWrap: true,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          )),
                                      Divider(
                                        height: 100.h,
                                        color: Colors.transparent,
                                      ),
                                      Text(
                                        "Socios",
                                        style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 70.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(
                                        height: 100.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Appodeal, Inc.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://appodeal.com/privacy-policy/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Bid Machine, Inc.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalizaciónSelección de anuncios, entrega, informes",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                               TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://bidmachine.io/privacy-policy/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("AdColony, Inc.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            maxLines: 1,
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Características\nCoincidencia de datos con fuentes fuera de línea\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ), TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://adcolony.com/privacy-policy/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Google LLC",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://policies.google.com/privacy"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Amazon",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://amazon.com/privacy"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("AppLovin",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://applovin.com/privacy"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                              
                                              
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Chartboost, Inc.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://answers.chartboost.com/en-us/articles/200780269"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Meta, Inc.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://www.facebook.com/privacy/policy/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("InMobi Pte Ltd",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Características\nCoincidencia de datos con fuentes fuera de línea\nConectando dispositivos\nDatos precisos de ubicación geográfica\nPropósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\nSelección de contenido, entrega, informes\nMedición\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://www.inmobi.com/privacy-policy"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text(
                                            "IronSource Ltd",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://www.is.com/privacy-policy"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                              
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text(
                                              "MobVista International Technology Limited",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://www.mobvista.com/en/privacy"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("My.com B.V.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://legal.my.com/us/mytarget/privacy/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Ogury Ltd.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Características\nConectando dispositivos\nDatos precisos de ubicación geográfica\nPropósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\nSelección de contenido, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                                 TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://ogury.com/privacy-policy/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Smaato, Inc.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Características\nDatos precisos de ubicación geográfica\nPropósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\nSelección de contenido, entrega, informes\nMedición\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://www.smaato.com/privacy/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("StartApp Inc",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Características\nDatos precisos de ubicación geográfica\nPropósito basado en intereses legítimos\nPersonalización\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://www.start.io/policy/privacy-policy-site/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("tapjoy, inc.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                            maxLines: 1,
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://dev.tapjoy.com/en/legal/Privacy-Policy"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Unity Technologies",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://unity.com/legal/game-player-and-app-user-privacy-policy"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("Vungle, Inc.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes\n",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://vungle.com/privacy/"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                      Divider(
                                        height: 50.h,
                                        color: Colors.transparent,
                                      ),
                                      ExpandablePanel(
                                          header: Text("YANDEX LLC",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold)),
                                          collapsed: Text(
                                            "",
                                            maxLines: 1,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 50.sp),
                                          ),
                                          expanded: Column(
                                            children: [
                                              Text(
                                                "Propósito basado en intereses legítimos\nAlmacenamiento y acceso a la información.\nPersonalización\nSelección de anuncios, entrega, informes",
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                          "https://yandex.com/legal/confidential/index.html"),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  },
                                                  child: Text(
                                                      "Ver las políticas de privacidad de los socios"))
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: kToolbarHeight * 2,
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          widget.consent = true;
                                          setState(() {
                                            widget.adConsentformState =
                                                AdConsentformState.LOADING;
                                          });
                                          bool result = await Dependencies
                                              .advertisingServices
                                              .setConsentStatus(
                                                  consentPersonalizedAds:
                                                      widget.consent);
                                          if (result) {
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.DONE;
                                            });
                                          } else {
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.ERROR;
                                            });
                                          }
                                        },
                                        child: Text(
                                            "Ver anuncios personalizados")),
                                    TextButton(
                                        onPressed: () async {
                                          widget.consent = false;

                                          setState(() {
                                            widget.adConsentformState =
                                                AdConsentformState.LOADING;
                                          });
                                          bool result = await Dependencies
                                              .advertisingServices
                                              .setConsentStatus(
                                                  consentPersonalizedAds:
                                                      widget.consent);
                                          if (result) {
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.DONE;
                                            });
                                          } else {
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.ERROR;
                                            });
                                          }
                                        },
                                        child: Text(
                                            "No ver anuncios personalizados"))
                                  ],
                                ),
                              )
                            ],
                          ),
          ],
        ),
      ),
    );
  }
}
