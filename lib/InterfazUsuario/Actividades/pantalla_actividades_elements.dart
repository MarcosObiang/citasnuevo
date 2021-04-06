import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'dart:ui';

import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorDenuncias.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVerificacion.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/EstadoConexion.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import "package:citasnuevo/Inte../../DatosAplicacion/ControladorConversacion.dart";
import 'package:citasnuevo/InterfazUsuario/Actividades/TarjetaPerfiles.dart';
import 'package:citasnuevo/InterfazUsuario/Ajustes/AjustesHotty.dart';
import 'package:citasnuevo/InterfazUsuario/Ajustes/PantallaAjustes.dart';
import "package:citasnuevo/InterfazUsuario/Conversaciones/ListaConversaciones.dart";
import 'package:citasnuevo/InterfazUsuario/Valoraciones/ListaValoraciones.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:ntp/ntp.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:image_picker/image_picker.dart';

import 'package:image_cropper/image_cropper.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:swipe_stack/swipe_stack.dart';

import 'Pantalla_Actividades.dart';

// ignore: must_be_immutable
class PerfilesGenteCitas extends StatefulWidget  {
  List<List<Widget>> perfiles = new List();
  static int posicion;

  BoxConstraints limites;
  static double valor;
  static BoxConstraints limitesPrimeraFoto;
  static BoxConstraints limitesParaCreador;
  static int indicePerfil = 0;
  static double valorPerfilPasado = 0;
  static double valorPerfilPresente = 0;
  bool cambiarIndice = false;
  PerfilesGenteCitas({@required this.limites}) {
    if (this.limites.biggest.height != null &&
        this.limites.biggest.width != null) {
      limitesPrimeraFoto = this.limites;
    }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PerfilesGenteCitasState();
  }
}

class PerfilesGenteCitasState extends State<PerfilesGenteCitas> with AutomaticKeepAliveClientMixin {
  static ItemScrollController mover = new ItemScrollController();
  static SwiperController controladorSwipe = new SwiperController();

  @override
  void initState() {
    PerfilesGenteCitas.indicePerfil = 0;
    super.initState();
  }

  Function soltarLikes;
  int devolverIndices = 0;
  bool leGusta = false;
  double valorSlider = 5;
  
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Container(
      height: widget.limites.biggest.height,
      width: widget.limites.biggest.width,
      decoration: BoxDecoration(),
      child: Stack(
        children: <Widget>[
          Perfiles.perfilesCitas.estadoLista == EstadoListaPerfiles.listaCargada
              ? LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    PerfilesGenteCitas.limitesPrimeraFoto = box;
                    PerfilesGenteCitas.limitesParaCreador = box;
                    ImagenesCarrete.limitesCuadro = box;
                    return Container(
                      color: Colors.white,
                      height: box.biggest.height,
                      width: box.biggest.width,
                      child: GestureDetector(
                        onHorizontalDragStart: (valor) {},
                        onHorizontalDragUpdate: (valor) {},
                        onHorizontalDragCancel: () {},
                        onHorizontalDragDown: (valor) {},
                        onHorizontalDragEnd: (valor) {},
                        onLongPress: () {},
                        child: Swiper(
                          loop: false,
                          physics: NeverScrollableScrollPhysics(),
                          layout: SwiperLayout.STACK,
                          itemWidth: box.biggest.width,
                          curve: Curves.easeInOut,
                          onIndexChanged: (index) {
                            if (Perfiles.perfilesCitas.listaPerfiles != null) {
                              PerfilesGenteCitas.indicePerfil = index;
                              if (Perfiles.perfilesCitas.listaPerfiles.length >
                                  PerfilesGenteCitas.indicePerfil + 1) {
                                PerfilesGenteCitas.valorPerfilPasado = Perfiles
                                    .perfilesCitas
                                    .listaPerfiles[
                                        PerfilesGenteCitas.indicePerfil]
                                    .valoracion;
                                PerfilesGenteCitas.valorPerfilPresente =
                                    Perfiles
                                        .perfilesCitas
                                        .listaPerfiles[
                                            PerfilesGenteCitas.indicePerfil + 1]
                                        .valoracion;
                                Perfiles.perfilesCitas.notifyListeners();
                              }
                            }

                                 if(this.mounted){
                             setState(() {});

                        }
                 
                         

                            widget.cambiarIndice = false;
                          },
                          controller: controladorSwipe,
                          itemCount:
                              Perfiles.perfilesCitas.listaPerfiles.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int indice) {
                            PerfilesGenteCitas.indicePerfil=indice;
                            return RepaintBoundary(
                              child: Container(
                                height: box.biggest.height,
                                width: box.biggest.width,
                                color: Colors.white,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Stack(
                                      children: [
                                        ListView(
                                          padding: EdgeInsets.all(0),
                                          children: Perfiles.perfilesCitas
                                              .listaPerfiles[indice].carrete,
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: kBottomNavigationBarHeight,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Colors.black,
                                                    Colors.transparent
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    leGusta
                                        ? pantallaGusta(box, indice)
                                        : Container(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                )
              : Perfiles.perfilesCitas.estadoLista ==
                      EstadoListaPerfiles.listaVacia
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left:20,right:80.0),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                                  "Vaya algo ha ido mal.....",
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 70.sp
                                  ),
                                ),
                                Divider(height:100.h),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                
                                "Upps no hay perfiles que coincidan con tu busqueda, prueba a modificar los filtros",textAlign: TextAlign.left,
                                style: GoogleFonts.lato(
                                    color: Colors.white, ),
                              ),
                              RaisedButton(
                                color: Colors.deepPurple[900],
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Ajustes()));
                                },
                                child: Text(
                                  "Cambiar filtros",
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Puede que en tu zona no hayan muchos usuarios de Hotty, comparte la aplicacion con tus amigos y gana 2500 creditos por cada amigo que invites",
                                style: GoogleFonts.lato(
                                    color: Colors.white, ),
                              ),
                              RaisedButton(
                                color: Colors.deepPurple[900],
                                onPressed: () {
                                  Navigator.push(context,CupertinoPageRoute(builder: (context)=>PantallaCompartir()));
                                },
                                child: Text(
                                  "Invitar a amigos",
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                    ),
                      ))
                  : Perfiles.perfilesCitas.estadoLista ==
                          EstadoListaPerfiles.errorCargarLista
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                "Ha habido un error al obtener a los usuarios",
                                style: GoogleFonts.lato(
                                    color: Colors.white, fontSize: 70.sp),
                        ),
                        RaisedButton(
                            color:Colors.deepPurple[900],
                            child: Text("Intentar de nuevo",style: GoogleFonts.lato(color:Colors.white)),onPressed: ()async{
                               ControladorAjustes.instancia.obtenerLocalizacion().then(
                 
                (value) async => ControladorAjustes.instancia.cargaPerfiles());
                Perfiles.perfilesCitas.estadoLista=EstadoListaPerfiles.cargandoLista;
               setState(() {
                                
                              });
                        },)
                              ],
                            ),
                          ))
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 100.h,
                                width: 100.h,
                                child: LoadingIndicator(indicatorType: Indicator.ballScaleMultiple, color: Colors.white,)),
                              Text(
                              "Por favor, espere",
                              style: GoogleFonts.lato(
                                  color: Colors.white, fontSize: 70.sp),
                        ),
                            ],
                          )),
          Perfiles.perfilesCitas.estadoLista == EstadoListaPerfiles.listaCargada
              ? deslizadorCompuesto()
              : Container(
                  height: 0,
                  width: 0,
                ),
          EstadoConexionInternet.estadoConexion.conexion !=
                  EstadoConexion.conectado
              ? Container(
                  color: Color.fromRGBO(20, 20, 20, 100),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Espere mientras se intenta reestablecer la conexion con el servidor",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(60)),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          botonesLateralesCitas(context),
        ],
      ),
    );
  }

  Padding botonDenuncia(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 150.w,
        width: 150.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Color.fromRGBO(36, 28, 41, 100),
        ),
        child: Center(child: panelDenunciasPerfiles(context)),
      ),
    );
  }

  Padding botonRecompensa(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 150.w,
          width: 150.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Color.fromRGBO(36, 28, 41, 100),
          ),
          child: BotonAnimadoRecompensas(
            recompensaPorReferencia: recompensaPorReferencia,
            recompensaDiaria: recompensaDiaria,
            recompensaPorVerificacion: recompensaPorVerificacion,
          ),
        ),
      ),
    );
  }

  Container recompensaPorReferencia(
      BoxConstraints limites, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Invita y gana",
                  textAlign: TextAlign.start,
                  style:
                      GoogleFonts.lato(color: Colors.white60, fontSize: 75.sp),
                ),
                Icon(
                  LineAwesomeIcons.share,
                  color: Colors.white60,
                  size: 120.sp,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Gana 1500 creditos por cada amigo que instale, se registre en Hotty y cumpla el proceso de verificación. Ademas te regalamos 1000 creditos por la primera compra que haga",
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 40.sp),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                width: limites.biggest.width,
                child: FlatButton(
                  disabledColor: Colors.green,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PantallaCompartir()));
                  },
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Invitar amigos",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.lato(fontSize: 40.sp),
                          ),
                          Icon(LineAwesomeIcons.user_friends),
                        ],
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container recompensaPorVerificacion(
      BoxConstraints limites, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Verifica tu perfil y gana",
                  textAlign: TextAlign.start,
                  style:
                      GoogleFonts.lato(color: Colors.white60, fontSize: 75.sp),
                ),
                Icon(
                  LineAwesomeIcons.check_circle,
                  color: Colors.white60,
                  size: 120.sp,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Gana 2000 creditos por verificar tu perfil y ayudarnos a mantener Hotty seguro",
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 40.sp),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                width: limites.biggest.width,
                child: FlatButton(
                  disabledColor: Colors.green,
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  height: 1200.h,
                                  width: ScreenUtil.screenWidth,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Verifica que éres tu y gana 2500 creditos",
                                          style: GoogleFonts.lato(
                                              fontSize: 90.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white70),
                                        ),
                                        Divider(height: 20.h),
                                        Text(
                                          "Hazte una foto imitando la pose del chico de la imagen que te mostraremos a continuación, y así comprobamos que éres tú y te llevas tu recompensa",
                                          style: GoogleFonts.lato(
                                              fontSize: 50.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Divider(
                                          height: 100.h,
                                        ),
                                        LayoutBuilder(
                                          builder: (BuildContext context,
                                              BoxConstraints limites) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                                final aleatorio = new Random();
                                                int numeroFoto =
                                                    aleatorio.nextInt(6) + 1;
                                                while (numeroFoto == 0) {
                                                  numeroFoto =
                                                      aleatorio.nextInt(6) + 1;
                                                }

                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PantallaPrimeraFotoVerificacion(
                                                              fotoVerificacion:
                                                                  "verificacion$numeroFoto",
                                                            )));
                                              },
                                              child: Container(
                                                height: 100.h,
                                                width: limites.biggest.width,
                                                decoration: BoxDecoration(
                                                    color:
                                                        Colors.deepPurple[900],
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Center(
                                                    child: Text(
                                                  "Empezar",
                                                  style: GoogleFonts.lato(
                                                      color: Colors.white,
                                                      fontSize: 40.sp),
                                                )),
                                              ),
                                            );
                                          },
                                        )
                                      ]),
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Verificar perfil",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.lato(fontSize: 40.sp),
                          ),
                          Icon(LineAwesomeIcons.user_friends),
                        ],
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container recompensaDiaria(BoxConstraints limites, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Stack(
        children: [
          Container(
            height: 500.h,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "500 Creditos gratis",
                          textAlign: TextAlign.start,
                          style: GoogleFonts.lato(
                              fontSize: 65.sp, color: Colors.white60),
                        ),
                        Icon(
                          LineAwesomeIcons.money_bill,
                          size: 120.sp,
                          color: Colors.white60,
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Si tienes menos de 175 creditos, entonces puedes reponer 500 creditos gratuitos para gastar en la aplicación cada día.",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Usuario.esteUsuario.segundosRestantesRecompensa > 0
                                ? Colors.grey
                                : Colors.green,
                      ),
                      width: limites.biggest.width,
                      child: FlatButton(
                          disabledColor: Colors.green,
                          onPressed: () {
                            ControladorCreditos.instancia.recompensaDiaria();
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Usuario.esteUsuario
                                        .segundosRestantesRecompensa >
                                    0
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Tiempo Restante",
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.lato(),
                                      ),
                                      StreamBuilder<int>(
                                        stream: Usuario.esteUsuario
                                            .tiempoHastaRecompensa.stream,
                                        initialData: Usuario.esteUsuario
                                            .segundosRestantesRecompensa,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<int> dato) {
                                          if (Usuario.esteUsuario
                                                  .segundosRestantesRecompensa ==
                                              0) {}

                                          return Container(
                                              child: Text(
                                                  Valoracion.formatoTiempo
                                                      .format(DateTime(0, 0, 0,
                                                          0, 0, dato.data)),
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black)));
                                        },
                                      ),
                                      Icon(
                                        LineAwesomeIcons.clock,
                                        color: Colors.black,
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Reclamar recompensa",
                                        style:
                                            GoogleFonts.lato(fontSize: 40.sp),
                                      ),
                                      Icon(
                                        LineAwesomeIcons.money_bill,
                                        size: 80.sp,
                                      )
                                    ],
                                  ),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ControladorCreditos.instancia.estadoSolicitudCreditos ==
                  EstadoSolicitudCreditosGratuitos.solicitando
              ? Container(
                  height: 500.h,
                  width: ScreenUtil.screenWidth,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(20, 20, 20, 100),
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            border: Border.all(color: Colors.deepPurple),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Procesando....",
                                  style: GoogleFonts.lato(
                                      color: Colors.white, fontSize: 50.sp)),
                              CircularProgressIndicator()
                            ],
                          ),
                        ),
                      ),
                    )),
                  ),
                )
              : Container(
                  height: 0,
                  width: 0,
                )
        ],
      ),
    );
  }

  IconButton panelDenunciasPerfiles(BuildContext context) {
    return IconButton(
      onPressed: () => showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    height: 1200.h,
                    width: ScreenUtil.screenWidth,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Denunciar",
                            style: TextStyle(
                                fontSize: 90.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70),
                          ),
                          Divider(height: 100.h),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PantallaDenunciaVisorPerfiles(
                                                  idDenunciado: Perfiles
                                                      .perfilesCitas
                                                      .listaPerfiles[
                                                          PerfilesGenteCitas
                                                              .indicePerfil]
                                                      .idUsuario,
                                                  tipoDenuncia: TipoDenuncia
                                                      .perfilFalso)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: Container(
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Perfil falso/SPAM",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PantallaDenunciaVisorPerfiles(
                                                  idDenunciado: Perfiles
                                                      .perfilesCitas
                                                      .listaPerfiles[
                                                          PerfilesGenteCitas
                                                              .indicePerfil]
                                                      .idUsuario,
                                                  tipoDenuncia:
                                                      TipoDenuncia.menorEdad)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: Container(
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Menor de edad",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PantallaDenunciaVisorPerfiles(
                                                  idDenunciado: Perfiles
                                                      .perfilesCitas
                                                      .listaPerfiles[
                                                          PerfilesGenteCitas
                                                              .indicePerfil]
                                                      .idUsuario,
                                                  tipoDenuncia: TipoDenuncia
                                                      .fotosBiografiaInapropiada)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: Container(
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Contenido inapropiado",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PantallaDenunciaVisorPerfiles(
                                                  idDenunciado: Perfiles
                                                      .perfilesCitas
                                                      .listaPerfiles[
                                                          PerfilesGenteCitas
                                                              .indicePerfil]
                                                      .idUsuario,
                                                  tipoDenuncia: TipoDenuncia
                                                      .hacePublicidad)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: Container(
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Hace Publicidad",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PantallaDenunciaVisorPerfiles(
                                                  idDenunciado: Perfiles
                                                      .perfilesCitas
                                                      .listaPerfiles[
                                                          PerfilesGenteCitas
                                                              .indicePerfil]
                                                      .idUsuario,
                                                  tipoDenuncia:
                                                      TipoDenuncia.otroTipo)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: Container(
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Otros",
                                              style: GoogleFonts.lato(
                                                  fontSize: 40.sp,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 60.0, right: 60),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: Container(
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Icon(Icons.arrow_back_ios,
                                              color: Colors.white),
                                          Text("Atras",
                                              style: GoogleFonts.lato(
                                                  fontSize: 40.sp,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                        ]),
                    color: Colors.transparent,
                  ),
                ),
              ),
            );
          }),
      icon: Icon(
        Icons.report_outlined,
        color: Colors.white,
      ),
    );
  }

  Align botonesLateralesCitas(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 150.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                      gradient: RadialGradient(
                          focalRadius: 50.h,
                          colors: [Colors.black, Colors.transparent]),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListaDeValoraciones())),
                    child: Stack(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                            ),
                            child: Center(
                              child: Text(
                                "${Valoracion.instanciar.mediaUsuario != null ? Valoracion.instanciar.mediaUsuario.toStringAsFixed(2) : 0}",
                                style: GoogleFonts.lato(
                                    fontSize: 45.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                        Valoracion.instanciar.listaDeValoraciones.length > 0
                            ? Align(
                                alignment: Alignment.bottomLeft,
                                child: Valoracion.instanciar.listaDeValoraciones
                                            .length <
                                        9
                                    ? Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.deepPurple),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            "${Valoracion.instanciar.listaDeValoraciones.length}",
                                            style: GoogleFonts.lato(
                                                fontSize: 35.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            color: Colors.deepPurple),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            "${Valoracion.instanciar.listaDeValoraciones.length}",
                                            style: GoogleFonts.lato(
                                                fontSize: 35.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ))
                            : Container(
                                height: 0,
                                width: 0,
                              )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50.h,
                ),
                Container(
                  height: 150.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                      gradient: RadialGradient(
                          focalRadius: 50.h,
                          colors: [Colors.black, Colors.transparent]),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PantallaSolicitudesConversaciones())),
                    child: Stack(
                      children: [
                        Container(
                          child: Center(
                            child: Icon(
                              LineAwesomeIcons.inbox,
                              color: Colors.white,
                              size: 80.sp,
                            ),
                          ),
                        ),
                        Solicitudes.instancia.listaSolicitudesConversacion
                                    .length >
                                0
                            ? Align(
                                alignment: Alignment.bottomLeft,
                                child: Solicitudes
                                            .instancia
                                            .listaSolicitudesConversacion
                                            .length <
                                        9
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            "${Solicitudes.instancia.listaSolicitudesConversacion.length}",
                                            style: GoogleFonts.lato(
                                                fontSize: 35.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            "${Solicitudes.instancia.listaSolicitudesConversacion.length}",
                                            style: GoogleFonts.lato(
                                                fontSize: 35.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ))
                            : Container(
                                height: 0,
                                width: 0,
                              )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50.h,
                ),
                Container(
                  height: 150.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                      gradient: RadialGradient(
                          colors: [Colors.black, Colors.transparent]),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListaDeValoraciones())),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 4,
                          fit: FlexFit.tight,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                            ),
                            child: RepaintBoundary(
                                child: BotonAnimadoRecompensas(
                              recompensaPorReferencia: recompensaPorReferencia,
                              recompensaDiaria: recompensaDiaria,
                              recompensaPorVerificacion:
                                  recompensaPorVerificacion,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50.h,
                ),
                Container(
                  height: 150.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(36, 28, 41, 100),
                      gradient: RadialGradient(
                          colors: [Colors.black, Colors.transparent]),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PantallaSolicitudesConversaciones())),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          flex: 4,
                          fit: FlexFit.tight,
                          child: Container(
                            child:
                                Center(child: panelDenunciasPerfiles(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget deslizadorCompuesto() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight, left: 20, right: 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Color.fromRGBO(36, 28, 41, 99)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              child: Text(
                                  "${Perfiles.perfilesCitas.listaPerfiles[PerfilesGenteCitas.indicePerfil].nombreusuaio}, ${Perfiles.perfilesCitas.listaPerfiles[PerfilesGenteCitas.indicePerfil].edad} ",
                                  style: GoogleFonts.lato(
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                            ),
                            Perfiles
                                    .perfilesCitas
                                    .listaPerfiles[
                                        PerfilesGenteCitas.indicePerfil]
                                    .verificado
                                ? Icon(
                                    LineAwesomeIcons.check_circle,
                                    color: Colors.white,
                                    size: 50.sp,
                                  )
                                : Container(
                                    height: 0,
                                    width: 0,
                                  )
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              LineAwesomeIcons.alternate_map_marker,
                              color: Colors.white,
                              size: 50.sp,
                            ),
                            !ControladorAjustes
                                    .instancia.getVisualizarDistanciaEnMillas
                                ? Text(
                                    "${Perfiles.perfilesCitas.listaPerfiles[PerfilesGenteCitas.indicePerfil].distancia} Km",
                                    style: GoogleFonts.lato(
                                        fontSize: 45.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                : Text(
                                    "${((Perfiles.perfilesCitas.listaPerfiles[PerfilesGenteCitas.indicePerfil].distancia).toInt() * 0.62).toStringAsFixed(0)} mi",
                                    style: GoogleFonts.lato(
                                        fontSize: 45.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                          ],
                        )
                      ]),
                ),
              ),
            ),
            Container(
              height: kBottomNavigationBarHeight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RepaintBoundary(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(36, 28, 41, 100),
                                blurRadius: 2,
                                spreadRadius: 2)
                          ], shape: BoxShape.circle, color: Colors.deepPurple),
                          child: Center(
                            child: Icon(
                              Icons.close_outlined,
                              size: 90.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 10,
                        child: Container(
                          child: deslizadorPuntuacion(
                            soltarLikes,
                            PerfilesGenteCitas.indicePerfil,
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(36, 28, 41, 100),
                                blurRadius: 2,
                                spreadRadius: 2)
                          ], shape: BoxShape.circle, color: Colors.deepPurple),
                          child: Center(
                            child: Icon(
                              LineAwesomeIcons.heart,
                              size: 90.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void dialogoFinPerfiles(BuildContext context) {
    bool denttroDePantalla = false;
    showGeneralDialog(
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 100),
        context: context,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondanimation) {
          denttroDePantalla = true;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: ScreenUtil().setHeight(1000),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromRGBO(20, 20, 20, 50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Text("Upps... Parece que no queda nadie",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(70))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.transparent,
                            child: TweenAnimationBuilder(
                                tween: Tween<double>(
                                    begin: ScreenUtil().setSp(0),
                                    end: ScreenUtil().setSp(300)),
                                duration: Duration(milliseconds: 250),
                                builder: (BuildContext context, double valor,
                                    Widget child) {
                                  return Icon(
                                    LineAwesomeIcons
                                        .frowning_face_with_open_mouth_1,
                                    size: valor,
                                    color: Colors.yellow,
                                  );
                                }),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(30),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            child: Text(
                                "Invita a tus amigos a unirse y gana creditos cuando se registren por ayudarnos a crecer",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(40))),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(40),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.green),
                          child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Invitar amigos"),
                                Icon(LineAwesomeIcons.share),
                              ],
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(50),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  "Modifica tus filtros para ver mas perfiles",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(40))),
                            ),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(50),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.green),
                          child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Modificar Filtros"),
                                Icon(LineAwesomeIcons.edit)
                              ],
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(30),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.transparent),
                          child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Cerrar",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.close, color: Colors.red)
                              ],
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  TweenAnimationBuilder<double> pantallaGusta(
      BoxConstraints limitesPantallaLeGusta, int indice) {
    return TweenAnimationBuilder(
        tween:
            Tween<double>(begin: 0, end: limitesPantallaLeGusta.biggest.height),
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInSine,
        builder: (BuildContext context, double valor, Widget child) {
          return AnimatedContainer(
            curve: Curves.linear,
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color:
                    Perfiles.perfilesCitas.listaPerfiles[indice].valoracion >=
                            4.9
                        ? Color.fromARGB(90, 196, 51, 255)
                        : Color.fromRGBO(255, 0, 42, 100)),
            height: valor,
            width: limitesPantallaLeGusta.biggest.width,
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: valor == limitesPantallaLeGusta.biggest.height
                    ? mensajePantallaCalificacion(
                        limitesPantallaLeGusta, indice)
                    : Container()),
          );
        });
  }

  Column mensajePantallaCalificacion(
      BoxConstraints limitesPantallaLeGusta, int indice) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Perfiles.perfilesCitas.listaPerfiles[indice].valoracion > 4.99 &&
                Perfiles.perfilesCitas.listaPerfiles[indice].valoracion < 6.5
            ? Text(
                "No esta mal",
                style: GoogleFonts.lato(
                    fontSize: ScreenUtil().setSp(100),
                    fontWeight: FontWeight.bold),
              )
            : Perfiles.perfilesCitas.listaPerfiles[indice].valoracion > 6.5 &&
                    Perfiles.perfilesCitas.listaPerfiles[indice].valoracion < 9
                ? Text(
                    "Me gustas",
                    style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(100),
                        fontWeight: FontWeight.bold),
                  )
                : Perfiles.perfilesCitas.listaPerfiles[indice].valoracion > 9
                    ? Text(
                        "Smash",
                        style: GoogleFonts.lato(
                            fontSize: ScreenUtil().setSp(100),
                            fontWeight: FontWeight.bold),
                      )
                    : Center(
                        child: Text(
                          "Pass",
                          style: GoogleFonts.lato(
                              fontSize: ScreenUtil().setSp(150),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
        Perfiles.perfilesCitas.listaPerfiles[indice].valoracion >= 0
            ? RepaintBoundary(
                child: anilloPuntuacion(limitesPantallaLeGusta, indice))
            : Container(),
      ],
    );
  }

  TweenAnimationBuilder<double> anilloPuntuacion(
      BoxConstraints limitesPantallaLeGusta, int indice) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 10, end: ScreenUtil().setSp(600)),
        curve: Curves.linearToEaseOut,
        duration: Duration(milliseconds: 300),
        builder: (BuildContext context, double valor, Widget child) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
                height: 600.w,
                width: 600.w,
                child: SleekCircularSlider(
                  appearance: CircularSliderAppearance(
                      animationEnabled: false,
                      infoProperties: InfoProperties(
                        mainLabelStyle: GoogleFonts.lato(
                            fontSize: 150.sp, fontWeight: FontWeight.bold),
                        modifier: (valor) => "${valor.toStringAsFixed(1)}",
                      )),
                  initialValue:
                      Perfiles.perfilesCitas.listaPerfiles[indice].valoracion,
                  max: 10.0,
                )

                /*CircularPercentIndicator(
                radius: valor,
                percent:
                    Perfiles.perfilesCitas.listaPerfiles[indice].valoracion /
                        10,
                animationDuration: 200,
                lineWidth: ScreenUtil().setHeight(50),
                linearGradient: LinearGradient(
                    colors: [Colors.pink, Colors.pinkAccent[100]]),
                center: Text(
                  "${Perfiles.perfilesCitas.listaPerfiles[indice].valoracion.toStringAsFixed(1)}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          ScreenUtil().setSp(90, allowFontScalingSelf: false),
                      color: Colors.white),
                ),
              ),*/
                ),
          );
        });
  }

  AnimatedContainer botonEscribirMensaje() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.linearToEaseOut,
      width: ScreenUtil().setWidth(400),
      height: ScreenUtil().setHeight(100),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white),
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.message,
            size: ScreenUtil().setSp(40),
          ),
          Text(
            "Enviar Mensaje",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(40), fontWeight: FontWeight.bold),
          ),
        ],
      )),
    );
  }

void llamarMasPerfiles(int indice){
  if(Perfiles.perfilesCitas.listaPerfiles.length-indice<6){
    QueryPerfiles.cerrarConvexionesQuery();
    print("borrados");

     ControladorAjustes.instancia.obtenerLocalizacion().then(
                 
                (value) async => ControladorAjustes.instancia.cargaPerfiles());
               // Perfiles.perfilesCitas.estadoLista=EstadoListaPerfiles.cargandoLista;

print("borrados");
  }
}
  Padding deslizadorPuntuacion(
    Function soltarLike,
    int indice,
  ) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        child: SliderTheme(
          data: SliderThemeData(
              trackHeight: ScreenUtil().setHeight(90),
              activeTrackColor: Colors.transparent,
              disabledActiveTrackColor: Colors.pink,
              disabledInactiveTrackColor: Colors.red,
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
              disabledActiveTickMarkColor: Colors.transparent,
              disabledInactiveTickMarkColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              disabledThumbColor: Colors.transparent,
              valueIndicatorShape: SliderComponentShape.noOverlay,
              thumbColor: Colors.deepPurple,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 30,
              ),
              overlappingShapeStrokeColor: Colors.red,
              overlayColor: Colors.pink),
          child: Slider(
            value: Perfiles.perfilesCitas.listaPerfiles != null
                ? Perfiles.perfilesCitas
                    .listaPerfiles[PerfilesGenteCitas.indicePerfil].valoracion
                : 5,
            label: "Holita",
            onChangeStart: (val) {
              print(val);
              leGusta = true;
            },
            onChanged: (valor) {
              if(this.mounted){
                      setState(() {
                Perfiles
                    .perfilesCitas
                    .listaPerfiles[PerfilesGenteCitas.indicePerfil]
                    .valoracion = valor;
              });

              }
        
            },
            onChangeEnd: (valor) {
              Future.delayed(Duration(milliseconds: 250)).then((value) {
                if (EstadoConexionInternet.estadoConexion.conexion ==
                    EstadoConexion.conectado) {
                  controladorSwipe.next(animation: true);
                  llamarMasPerfiles(indice);

                  if (Perfiles.perfilesCitas.listaPerfiles.length ==
                      PerfilesGenteCitas.indicePerfil + 1) {
                    Perfiles.perfilesCitas.estadoLista=EstadoListaPerfiles.listaVacia;
               setState(() {
                                
                              });

                        
                 
                    Perfiles.perfilesCitas
                        .listaPerfiles[PerfilesGenteCitas.indicePerfil]
                        .crearDatosValoracion();
                  }
                  if (Perfiles.perfilesCitas.listaPerfiles.length >
                      PerfilesGenteCitas.indicePerfil + 1) {
                   
                    Perfiles.perfilesCitas
                        .listaPerfiles[PerfilesGenteCitas.indicePerfil]
                        .crearDatosValoracion();
                  }

                  leGusta = false;
                } else {
                  Perfiles
                      .perfilesCitas
                      .listaPerfiles[PerfilesGenteCitas.indicePerfil]
                      .valoracion = 5;
                     if(this.mounted){
                             setState(() {});

                        }
                 
                  throw Exception("Sin internet");
                }
              });
            },
            min: 0,
            max: 10,
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class BotonAnimadoRecompensas extends StatefulWidget {
  final Function recompensaDiaria;
  final Function recompensaPorReferencia;
  final Function recompensaPorVerificacion;

  BotonAnimadoRecompensas(
      {@required this.recompensaDiaria,
      @required this.recompensaPorReferencia,
      @required this.recompensaPorVerificacion});
  @override
  _BotonAnimadoRecompensasState createState() =>
      _BotonAnimadoRecompensasState();
}

class _BotonAnimadoRecompensasState extends State<BotonAnimadoRecompensas>
    with SingleTickerProviderStateMixin {
  Animation<Color> animacionColor;
  AnimationController controladooranimacionColor;
  double tiempo;

  @override
  void initState() {
    controladooranimacionColor = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        animationBehavior: AnimationBehavior.normal);
    animacionColor =
        ColorTween(begin: Color.fromRGBO(20, 20, 20, 100), end: Colors.purple)
            .animate(controladooranimacionColor);
    controladooranimacionColor.forward();
    controladooranimacionColor.repeat(reverse: true);
    controladooranimacionColor.addListener(() {
      if (BaseAplicacion.indicePagina == 0) {

        if(this.mounted){
              setState(() {});

        }
    
      }
    });
    super.initState();
  }

  void dispose() {
    controladooranimacionColor.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(Usuario.esteUsuario!=null){
      if(Usuario.esteUsuario.segundosRestantesRecompensa>86400){
        Usuario.esteUsuario.segundosRestantesRecompensa=86400;
      }
      if(Usuario.esteUsuario.segundosRestantesRecompensa!=null&&Usuario.esteUsuario.tiempoEstimadoRecompensa!=null){
double  diferenciaActualYTiemporestante=    86400  -  (Usuario.esteUsuario.segundosRestantesRecompensa.toDouble());


   tiempo =
    diferenciaActualYTiemporestante/
            86400;
      }
    }
 
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return ChangeNotifierProvider.value(
                      value: Usuario.esteUsuario,
                      child: Consumer<Usuario>(
                        builder: (context, myType, child) {
                          return Center(
                            child: Container(
                              height: ScreenUtil.screenHeight,
                              width: ScreenUtil.screenWidth,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                              child: Material(
                                color: Color.fromRGBO(20, 20, 20, 50),
                                child: Column(children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 2,
                                    child: Container(
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text("Recompensas",
                                                style: GoogleFonts.lato(
                                                    color: Colors.white70,
                                                    fontSize:
                                                        ScreenUtil().setSp(75),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Icon(LineAwesomeIcons.coins,
                                                color: Colors.white70,
                                                size: 120.sp)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 12,
                                    child: Container(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: LayoutBuilder(
                                        builder: (BuildContext context,
                                            BoxConstraints limites) {
                                          return Container(
                                            width: limites.biggest.width,
                                            height: limites.biggest.height,
                                            child: ListView(children: [
                                              Usuario.esteUsuario
                                                          .tiempoEstimadoRecompensa !=
                                                      0
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: widget
                                                          .recompensaDiaria(
                                                              limites, context),
                                                    )
                                                  : Container(
                                                      height: 0,
                                                      width: 0,
                                                    ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: widget
                                                    .recompensaPorReferencia(
                                                        limites, context),
                                              ),
                                              Usuario.esteUsuario.verificado ==
                                                          "verificado" ||
                                                      Usuario.esteUsuario
                                                              .verificado ==
                                                          "enProceso"
                                                  ? Container(
                                                      height: 0,
                                                      width: 0,
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: widget
                                                          .recompensaPorVerificacion(
                                                              limites, context),
                                                    )
                                            ]),
                                          );
                                        },
                                      ),
                                    )),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(1))),
                                      width: ScreenUtil.screenWidth,
                                      child: FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Icon(Icons.arrow_back,
                                                    color: Colors.white),
                                                Text(
                                                  "Atras",
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.lato(
                                                      fontSize: 50.sp,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  )
                                ]),
                              ),
                            ),
                          );
                        },
                      ));
                },
              );
            }),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:  Usuario.esteUsuario.tiempoEstimadoRecompensa!=0&&Usuario.esteUsuario.segundosRestantesRecompensa==0
                  ? animacionColor.value
                  : Colors.transparent),
          child: CircularPercentIndicator(
            circularStrokeCap: CircularStrokeCap.round,
            percent: Usuario.esteUsuario.segundosRestantesRecompensa > 0
                ? tiempo
                : 1,
            progressColor: Usuario.esteUsuario.segundosRestantesRecompensa == 0
                ? Colors.transparent
                : Colors.yellow[600],
            backgroundColor: Colors.transparent,
            radius: 120.w,
            center: Icon(
              LineAwesomeIcons.coins,
              color: Colors.white,
              size: 80.sp,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PantallaDenunciaVisorPerfiles extends StatefulWidget {
  final String idDenunciado;
  TipoDenuncia tipoDenuncia;
  ControladorDenuncias denunciaUsuario;
  ZonaDenuncia zonaDenuncia;
  bool denunciaEnviada = false;
  PantallaDenunciaVisorPerfiles(
      {@required this.idDenunciado, @required this.tipoDenuncia}) {
    denunciaUsuario = new ControladorDenuncias.visorPerfiles(
        idDenunciado: idDenunciado,
        zonaDenuncia: ZonaDenuncia.visorPerfiles,
        fechaDenuncia: DateTime.now(),
        tipologiaDenuncia: this.tipoDenuncia,
        detallesDenuncia: "");
  }

  @override
  _PantallaDenunciaVisorPerfilesState createState() =>
      _PantallaDenunciaVisorPerfilesState();
}

class _PantallaDenunciaVisorPerfilesState
    extends State<PantallaDenunciaVisorPerfiles> {
  TextEditingController controladorTextoDenuncias = new TextEditingController();

  FocusNode nodoTexto = new FocusNode();
  Future<bool> salirDenuncia(BuildContext context) async {
    bool salirPantalla = await showDialog(
        context: context,
        useSafeArea: true,
        barrierDismissible: false,
        builder: (BuildContext context) => new AlertDialog(
              title: Text("¿Salir?"),
              content: Container(
                height: 300.h,
                width: 500.w,
                decoration: BoxDecoration(color: Colors.white),
                child: Text(
                  "Tu denuncia no se ha enviado y si sales de esta pantalla se borrará la denuncia.\n\n¿Quieres salir?",
                  textAlign: TextAlign.start,
                  style: GoogleFonts.lato(fontSize: 45.sp),
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(" Si, Salir")),
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("No"))
              ],
            ));
    return salirPantalla;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        nodoTexto.unfocus();

        if (controladorTextoDenuncias.text.isEmpty) {
          //  salirPantalla=true;
          return true;
        } else {
          return salirDenuncia(context);
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.deepPurple[900],
          appBar: AppBar(
            elevation: 0,
            title: Text("Denunciar"),
            backgroundColor: Colors.deepPurple[900],
          ),
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: !widget.denunciaEnviada
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(children: [
                          Container(
                              height: 250.h,
                              decoration: BoxDecoration(
                                  color: Colors.deepPurple[900],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Icon(
                                      LineAwesomeIcons.user_shield,
                                      size: 120.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        "Explicanos que infracción crees que ha cometido el usuario, tu denuncia será revisada por un moderador lo antes posible",
                                        maxLines: 3,
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(45),
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )),
                          Divider(
                            height: 100.h,
                          ),
                          Text("Porfavor, danos mas detalles",
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(60),
                                  fontWeight: FontWeight.bold)),
                          Divider(
                            height: 100.sp,
                          ),
                          TextField(
                            textInputAction: TextInputAction.done,
                            focusNode: nodoTexto,
                            controller: controladorTextoDenuncias,
                            onChanged: (value) {
                              widget.denunciaUsuario.detallesDenuncia = value;
                            },
                            style: GoogleFonts.lato(fontSize: 45.sp),
                            decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: Colors.white),
                                    gapPadding: 10)),
                            maxLines: 6,
                            maxLength: 300,
                          )
                        ]),
                        GestureDetector(
                          onTap: () {
                            ControladorDenuncias.enviarDenuncia(
                                    widget.denunciaUsuario)
                                .then((value) {
                              widget.denunciaEnviada = value;
                              setState(() {});
                            });
                          },
                          child: Container(
                            height: 100.h,
                            width: ScreenUtil.screenWidth,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Colors.greenAccent[400]),
                            child: Center(
                                child: Text("Denunciar",
                                    style: GoogleFonts.lato(fontSize: 45.sp))),
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: Container(
                          height: 500.h,
                          decoration: BoxDecoration(
                              color: Colors.deepPurple[900],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            children: [
                              Text("Denuncia Enviada",
                                  maxLines: 3,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(45),
                                      fontWeight: FontWeight.bold)),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Icon(
                                  LineAwesomeIcons.check_circle,
                                  size: 120.sp,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 100.h,
                                  width: ScreenUtil.screenWidth / 2,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Colors.greenAccent[400]),
                                  child: Center(
                                      child: Text("Hecho",
                                          style: GoogleFonts.lato(
                                              fontSize: 45.sp))),
                                ),
                              )
                            ],
                          )),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class PantallaDeVerificacion extends StatefulWidget {
  @override
  _PantallaDeVerificacionState createState() => _PantallaDeVerificacionState();
}

class _PantallaDeVerificacionState extends State<PantallaDeVerificacion> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.deepPurple,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Verifica que eres tú y gana 2500 creditos",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 60.sp),
              ),
              Divider(height: 50.h),
              Text(
                "Imita las posturas que te mostramos a continuación, asi aseguramos  que las fotos son recientes, compararemos estas fotos con las de tu perfil y listo\n\n",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                textAlign: TextAlign.start,
              ),
              Text(
                "**Las fotos se eliminan una vez acabamos**",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 40.sp),
              ),
              Divider(
                height: 100.h,
              ),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints limites) {
                  return GestureDetector(
                    onTap: () {
                      final aleatorio = new Random();
                      int numeroFoto = aleatorio.nextInt(6) + 1;
                      while (numeroFoto == 0) {
                        numeroFoto = aleatorio.nextInt(6) + 1;
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PantallaPrimeraFotoVerificacion(
                                    fotoVerificacion: "verificacion$numeroFoto",
                                  )));
                    },
                    child: Container(
                      height: 100.h,
                      width: limites.biggest.width,
                      decoration: BoxDecoration(
                          color: Colors.deepPurple[900],
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Center(
                          child: Text(
                        "Empezar",
                        style: GoogleFonts.lato(
                            color: Colors.white, fontSize: 40.sp),
                      )),
                    ),
                  );
                },
              )
            ],
          ))),
        ),
      ),
    );
  }
}

class PantallaCompartir extends StatefulWidget {
  @override
  _PantallaCompartirState createState() => _PantallaCompartirState();
}

class _PantallaCompartirState extends State<PantallaCompartir> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.deepPurple,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Invita y gana 2500 creditos",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 60.sp),
              ),
              Divider(height: 50.h),
              Text(
                "Invita a través del link a tus amigos y gana 2500 creditos cuando se instalen y se verifiquen en la aplicación, y gana 1000 creditos por su primera compra\n\n",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                textAlign: TextAlign.start,
              ),
              Text(
                "**Deben verificarse para que obtengas la recompensa**",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 40.sp),
              ),
              Divider(
                height: 100.h,
              ),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints limites) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PantallaPrimeraFotoVerificacion())),
                    child: Container(
                      height: 100.h,
                      width: limites.biggest.width,
                      decoration: BoxDecoration(
                          color: Colors.deepPurple[900],
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Center(
                          child: Text(
                        "Empezar",
                        style: GoogleFonts.lato(
                            color: Colors.white, fontSize: 40.sp),
                      )),
                    ),
                  );
                },
              )
            ],
          ))),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PantallaPrimeraFotoVerificacion extends StatefulWidget {
  final String fotoVerificacion;
  final ImagePicker imagePicker = new ImagePicker();
  static Uint8List imagenVerificacion;

  PantallaPrimeraFotoVerificacion({@required this.fotoVerificacion});
  @override
  _PantallaPrimeraFotoVerificacionState createState() =>
      _PantallaPrimeraFotoVerificacionState();
}

class _PantallaPrimeraFotoVerificacionState
    extends State<PantallaPrimeraFotoVerificacion> {
  @override
  void initState() {
    PantallaPrimeraFotoVerificacion.imagenVerificacion = null;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    PantallaPrimeraFotoVerificacion.imagenVerificacion = null;
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints limites) {
            return Column(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: PantallaPrimeraFotoVerificacion
                                    .imagenVerificacion ==
                                null
                            ? Text(
                                "Imita la pose de la foto",
                                style: GoogleFonts.lato(
                                    color: Colors.white, fontSize: 60.sp),
                              )
                            : Text(
                                "¿ Son semeajntes ?",
                                style: GoogleFonts.lato(
                                    color: Colors.white, fontSize: 60.sp),
                              )),
                  ),
                ),
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                              image: AssetImage(
                                  "assets/${widget.fotoVerificacion}.jpg"),
                              fit: BoxFit.contain)),
                    ),
                  ),
                ),
                Flexible(
                    flex: 10,
                    fit: FlexFit.tight,
                    child: Container(
                        color: Colors.deepPurple,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints limitesB) {
                          return Container(
                            height: limitesB.biggest.height,
                            width: limitesB.biggest.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 10,
                                    fit: FlexFit.tight,
                                    child: Container(
                                        child: PantallaPrimeraFotoVerificacion
                                                    .imagenVerificacion ==
                                                null
                                            ? Text(
                                                "Pulsa el boton empezar para hacerte una foto con la camara frontal imitando la pose de la imagen, solo necesitamos verte de hombros hasta la cabeza",
                                                style: GoogleFonts.lato(
                                                    color: Colors.white,
                                                    fontSize: 40.sp),
                                              )
                                            : LayoutBuilder(builder:
                                                (BuildContext context,
                                                    BoxConstraints limitesz) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height:
                                                        limitesz.biggest.height,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        image: DecorationImage(
                                                            image: MemoryImage(
                                                                PantallaPrimeraFotoVerificacion
                                                                    .imagenVerificacion),
                                                            fit: BoxFit
                                                                .contain)),
                                                  ),
                                                );
                                              })),
                                  ),
                                  PantallaPrimeraFotoVerificacion
                                              .imagenVerificacion ==
                                          null
                                      ? Flexible(
                                          flex: 1,
                                          fit: FlexFit.tight,
                                          child: LayoutBuilder(
                                            builder: (BuildContext context,
                                                BoxConstraints limites) {
                                              return GestureDetector(
                                                onTap: () {
                                                  widget.imagePicker
                                                      .getImage(
                                                          source: ImageSource
                                                              .camera)
                                                      .then((valor) async {
                                                    File imagenRecortada = await ImageCropper
                                                        .cropImage(
                                                            sourcePath:
                                                                valor.path,
                                                            maxHeight: 1280,
                                                            maxWidth: 720,
                                                            aspectRatio:
                                                                CropAspectRatio(
                                                                    ratioX: 2,
                                                                    ratioY: 3),
                                                            compressQuality: 70,
                                                            androidUiSettings: AndroidUiSettings(
                                                                toolbarTitle:
                                                                    'Cropper',
                                                                toolbarColor: Colors
                                                                    .deepOrange,
                                                                toolbarWidgetColor:
                                                                    Colors
                                                                        .white,
                                                                initAspectRatio:
                                                                    CropAspectRatioPreset
                                                                        .ratio16x9,
                                                                lockAspectRatio:
                                                                    false),
                                                            iosUiSettings:
                                                                IOSUiSettings(
                                                              minimumAspectRatio:
                                                                  1.0,
                                                            ));

                                                    imagenRecortada
                                                        .readAsBytes()
                                                        .then((valor) {
                                                      setState(() {
                                                        PantallaPrimeraFotoVerificacion
                                                                .imagenVerificacion =
                                                            valor;
                                                      });
                                                    });
                                                  });
                                                },
                                                child: Container(
                                                  height: 100.h,
                                                  width: limites.biggest.width,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .deepPurple[900],
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                                  child: Center(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                          "Hacer foto",
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      40.sp),
                                                        ),
                                                        Icon(
                                                          LineAwesomeIcons
                                                              .camera,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    ),
                                                  )),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Flexible(
                                          flex: 1,
                                          fit: FlexFit.tight,
                                          child: LayoutBuilder(
                                            builder: (BuildContext context,
                                                BoxConstraints limites) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      widget.imagePicker
                                                          .getImage(
                                                              source:
                                                                  ImageSource
                                                                      .camera)
                                                          .then((valor) async {
                                                        File imagenRecortada = await ImageCropper
                                                            .cropImage(
                                                                sourcePath:
                                                                    valor.path,
                                                                maxHeight: 1280,
                                                                maxWidth: 720,
                                                                aspectRatio:
                                                                    CropAspectRatio(
                                                                        ratioX:
                                                                            2,
                                                                        ratioY:
                                                                            3),
                                                                compressQuality:
                                                                    70,
                                                                androidUiSettings: AndroidUiSettings(
                                                                    toolbarTitle:
                                                                        'Cropper',
                                                                    toolbarColor:
                                                                        Colors
                                                                            .deepOrange,
                                                                    toolbarWidgetColor:
                                                                        Colors
                                                                            .white,
                                                                    initAspectRatio:
                                                                        CropAspectRatioPreset
                                                                            .ratio16x9,
                                                                    lockAspectRatio:
                                                                        false),
                                                                iosUiSettings:
                                                                    IOSUiSettings(
                                                                  minimumAspectRatio:
                                                                      1.0,
                                                                ));

                                                        imagenRecortada
                                                            .readAsBytes()
                                                            .then((valor) {
                                                          setState(() {
                                                            PantallaPrimeraFotoVerificacion
                                                                    .imagenVerificacion =
                                                                valor;
                                                          });
                                                        });
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .deepPurple[900],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      child: Center(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              "Repetir foto",
                                                              style: GoogleFonts
                                                                  .lato(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          40.sp),
                                                            ),
                                                            Icon(
                                                              LineAwesomeIcons
                                                                  .camera,
                                                              color:
                                                                  Colors.white,
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      ControladorVerificacion
                                                          verificacion =
                                                          new ControladorVerificacion
                                                                  .crear(
                                                              fechaSolicitudVerificacion:
                                                                  DateTime
                                                                      .now(),
                                                              idSolicitudVerificacion:
                                                                  GeneradorCodigos
                                                                      .instancia
                                                                      .crearCodigo(),
                                                              imagen1Bytes:
                                                                  PantallaPrimeraFotoVerificacion
                                                                      .imagenVerificacion,
                                                              codigoImagenObjetivo1:
                                                                  widget
                                                                      .fotoVerificacion);
                                                      verificacion
                                                          .cargarEnAlmacenamiento()
                                                          .then((value) {
                                                        verificacion
                                                            .enviarSolicitudVerificacion();
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .deepPurple[900],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      child: Center(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              "Enviar",
                                                              style: GoogleFonts
                                                                  .lato(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          40.sp),
                                                            ),
                                                            Icon(
                                                              LineAwesomeIcons
                                                                  .check,
                                                              color:
                                                                  Colors.white,
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        })))
              ],
            );
          },
        ),
      ),
    );
  }
}
