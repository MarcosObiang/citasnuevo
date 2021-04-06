import 'dart:core';

import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/TiempoAplicacion.dart';
import 'package:citasnuevo/InterfazUsuario/Ajustes/EditarUsuario.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'sign_up_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

///**************************************************************************************************************************************************************
/// EN ESTE ARCHIVO DART ENCONTRAREMOS LOS ELEMENTOS QUE COMPONEN LA PANTALLA DE REGISTRO DE LA APLICACION
///
///
/// *************************************************************************************************************************************************************

///**************************************************************************************************************************************************************
///  WIDGET TEXTO REGISTRO: Campo de texto donde el usuario introduce texto y recibe estos parametros(Icon icon,String nombre_de_campo,int numero)
///
///  ICONO: Icono situado encima de la entrada de texto
///
///  NOMBRE DE CAMPO: Texto que aparece al lado del icono que indica el dato a introducir
///
///  NUMERO:El numero indica donde debe guardar el texto introducido para que sea procesado de la manera conveniente
///
///
///  0 Nombre,1 Alias, 2 Clave, 3 Confirmar clave, 4 Email, 5 Virtudes, 6 defectos, 7 Te gusta, 8 No te gustan, 9 Descripcion, 10 Que te gusta de la gente, 11 No te gusta de la gente
/// *************************************************************************************************************************************************************
class EntradaTexto extends StatefulWidget {
  final Icon icon;
  final int altura;
  final String nombre_campo;
  final int indice;
  final bool texto_oscuro;
  final int lineas;
  final int caracteres;

  EntradaTexto(this.icon, this.nombre_campo, this.indice, this.texto_oscuro,
      this.altura, this.lineas, this.caracteres);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EntradaTextoState(
        icon, nombre_campo, indice, texto_oscuro, altura, lineas, caracteres);
  }
}

class EntradaTextoState extends State<EntradaTexto> {
  bool invisible = true;
  bool aux = true;
  Icon icon;
  String nombre_campo;
  int indice;
  bool texto_oscuro;
  int altura;
  int lineas;
  int caracteres;
  TextEditingController controladorTexto = new TextEditingController();

  @override
  void initState() {
    controladorTexto.text = Usuario.esteUsuario.nombre;
    super.initState();
  }

  EntradaTextoState(this.icon, this.nombre_campo, this.indice,
      this.texto_oscuro, this.altura, this.lineas, this.caracteres);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          color: Colors.white,
        ),
        child: texto());
  }

  Widget texto() {
    return TextField(
      maxLines: lineas,
      maxLength: caracteres,
      textInputAction: TextInputAction.done,
      controller: controladorTexto,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.only(bottom: 0),
        counter: Offstage(),
        labelText: "Nombre",
        labelStyle:
            TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(60)),
        icon: icon,
      ),
      obscureText: false,
      onChanged: (String val) {
        setState(() {
          print(val);
          if (indice == 0) {
            Usuario.esteUsuario.nombre = val;
          }
        });
      },
      onSubmitted: (String palabra) {
        Usuario.esteUsuario.nombre = palabra;
      },
    );
  }
}

class CreadorDescripcion extends StatefulWidget {
  @override
  _CreadorDescripcionState createState() => _CreadorDescripcionState();
}

class _CreadorDescripcionState extends State<CreadorDescripcion> {
  TextEditingController controladorEditorDescripcion =
      new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    controladorEditorDescripcion.text = Usuario.esteUsuario.observaciones;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        textInputAction: TextInputAction.done,
        maxLines: 9,
        controller: controladorEditorDescripcion,
        decoration: InputDecoration(
            labelText: "Descripcion",
            floatingLabelBehavior: FloatingLabelBehavior.always),
        onChanged: (val) {
          Usuario.esteUsuario.observaciones = val;
        },
      ),
    );
  }
}

///**************************************************************************************************************************************************************
///  WIDGET BOTON NACIMMIENTO: Boton que debe ser presionado para acceder al menu que nos deja elegir la fecha de nacimiento(String texto)
///
///  TEXTO: Recibe una cadena de caracteres con la traduccion de cumpleaños al idioma deseado
///
/// *************************************************************************************************************************************************************

class BotonNacimiento extends StatefulWidget {
  DateTime dato;
  int caracteresIntroducidos = 0;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BotonNacimientoState();
  }

  BotonNacimiento(this.dato);
}

class BotonNacimientoState extends State<BotonNacimiento> {
  TextEditingController controladorTextoDia = new TextEditingController();
  TextEditingController controladorTextoMes = new TextEditingController();
  TextEditingController controladorTextoAnio = new TextEditingController();
  FocusNode nodoDia;
  FocusNode nodoMes;
  FocusNode nodoAnio;

  String texto_boton_edad;
  DateTime date;
  static int age;

  final f = new DateFormat('dd-MM-yyyy');
  @override
  void initState() {
    // TODO: implement initState
    nodoDia = new FocusNode();
    nodoMes = new FocusNode();
    nodoAnio = new FocusNode();

    super.initState();
  }

  void dispose() {
    nodoAnio.dispose();
    nodoDia.dispose();
    nodoMes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.w,
      height: 100.h,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(3))),
      child: GestureDetector(
          onTap: () async {
            Usuario.esteUsuario.fechaNacimiento =
                await DatePicker.showSimpleDatePicker(
              context,
              reverse: true,
              initialDate: TiempoAplicacion
                  .tiempoAplicacion.marcaTiempoAplicacion
                  .subtract(Duration(days: 365 * 18)),
              firstDate: TiempoAplicacion.tiempoAplicacion.marcaTiempoAplicacion
                  .subtract(Duration(days: 365 * 90)),
              dateFormat: "dd-MMMM-yyyy",
              locale: DateTimePickerLocale.en_us,
              looping: false,
            );
            Usuario.esteUsuario.validadorFecha();
            Usuario.esteUsuario.notifyListeners();
          },
          child: Container(
            child: Center(
                child: Usuario.esteUsuario.fechaNacimiento == null
                    ? Text(
                        "Pulsa para seleccionar",
                        style: GoogleFonts.lato(fontSize: 60.sp),
                      )
                    : Text(
                        f.format(
                          Usuario.esteUsuario.fechaNacimiento,
                        ),
                        style: GoogleFonts.lato(fontSize: 50.sp))),
          )),
    );
  }
}

///**************************************************************************************************************************************************************
///  WIDGET Campo Edad: Campo de texto en el que aparece la edad
/// *************************************************************************************************************************************************************

///**************************************************************************************************************************************************************
///  WIDGET AGE FIELD : Campo de texto en el que aparece edad correspondiente a esa fecha de nacimineto
/// *************************************************************************************************************************************************************
class MostradorEdad extends StatefulWidget {
  int dato;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MostradorEdadState();
  }

  MostradorEdad(this.dato);
}

class MostradorEdadState extends State<MostradorEdad> {
  static ValueNotifier<int> edad_final = ValueNotifier<int>(null);
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 150.w,
          height: 150.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Usuario.esteUsuario.edad == 0
                ? Text("")
                : Text(
                    Usuario.esteUsuario.edad.toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(70),
                        fontWeight: FontWeight.bold,
                        color: Usuario.esteUsuario.edad < 18
                            ? Colors.red
                            : Colors.green),
                  ),
          ),
        ),
      ],
    );
  }
}

///**************************************************************************************************************************************************************
///  WIDGET CAMPO SEXO : Consiste en un menu desplegable que muesta las opciones de sexo del usuario y recibe estos parametros(String field name, String male_sex_name,
///  String female_sex_name)
///
/// STRING NOMBRE CAMPO: Recibe una cadena de caracteres con la traduccion de SEXO adecuada al idioma traducido
///
/// STRING HOMBRE: Recibe una cadena de caracteres con la traduccion adecuada de HOMBRE
///
/// STRING MUJER: Recibe una cadena de caracteres con la traduccion adecuada de MUJER
///
/// *************************************************************************************************************************************************************
class CampoSexo extends StatefulWidget {
  String sex;
  static String nombreCampo = "Sexo";
  static String hombre = "Hombre";
  static String mujer = "Mujer";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CampoSexoState();
  }
}

class CampoSexoState extends State<CampoSexo> {
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Sexo",
                  style: GoogleFonts.lato(fontSize: 50.sp),
                ),
                Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Row(children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Usuario.esteUsuario.setSexoMujer = false;
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: !Usuario.esteUsuario.getSexoMujer
                                    ? Colors.green[900]
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10))),
                            child: Center(
                                child: Text("Hombre",
                                    style: GoogleFonts.lato(
                                      fontSize: 40.sp,
                                      color: !Usuario.esteUsuario.getSexoMujer
                                          ? Colors.white
                                          : Colors.black,
                                    )))),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Usuario.esteUsuario.setSexoMujer = true;
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Usuario.esteUsuario.getSexoMujer
                                    ? Colors.green[900]
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: Center(
                                child: Text("Mujer",
                                    style: GoogleFonts.lato(
                                      fontSize: 40.sp,
                                      color: Usuario.esteUsuario.getSexoMujer
                                          ? Colors.white
                                          : Colors.black,
                                    )))),
                      ),
                    )
                  ]),
                )
              ]),
        ),
      ),
    );
  }
}

///**************************************************************************************************************************************************************
///  WIDGET DATE FIELD : Consiste en un menu desplegable que muesta las opciones de preferencias sexuales del usuario(String field name, String male_sex_name,
///  String female_sex_name, String both_name)
///
/// STRING NAME: Recibe una cadena de caracteres con la traduccion de SEXO adecuada al idioma traducido
///
/// STRING MALE_SEX_NAME: Recibe una cadena de caracteres con la traduccion adecuada de HOMBRE
///
/// STRING FEMALE_SEX_NAME: Recibe una cadena de caracteres con la traduccion adecuada de MUJER
///
/// STRING BOTH: Recibe una cadena de caracters con la traduccion adecuada de AMBOS
///
/// *************************************************************************************************************************************************************

class CampoPreferenciaSexual extends StatefulWidget {
  static String nombreCampo = "Prefiero";
  static String hombre = "Hombre";
  static String mujer = "Mujer";
  static String bisexual = "Ambos";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CampoPreferenciaSexualState();
  }
}

class CampoPreferenciaSexualState extends State<CampoPreferenciaSexual> {
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Busco",
                style: GoogleFonts.lato(fontSize: 50.sp),
              ),
              Container(
                height: 100.h,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Usuario.esteUsuario.setPreferenciaSexual = 0;
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color:
                                  Usuario.esteUsuario.getPreferenciaSexual == 0
                                      ? Colors.green[900]
                                      : Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10))),
                          child: Center(
                              child: Text("Hombre",
                                  style: GoogleFonts.lato(
                                    fontSize: 35.sp,
                                    color: Usuario.esteUsuario
                                                .getPreferenciaSexual ==
                                            0
                                        ? Colors.white
                                        : Colors.black,
                                  )))),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Usuario.esteUsuario.setPreferenciaSexual = 1;
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: Usuario.esteUsuario.getPreferenciaSexual == 1
                                ? Colors.green[900]
                                : Colors.white,
                          ),
                          child: Center(
                              child: Text("Ambos",
                                  style: GoogleFonts.lato(
                                    fontSize: 35.sp,
                                    color: Usuario.esteUsuario
                                                .getPreferenciaSexual ==
                                            1
                                        ? Colors.white
                                        : Colors.black,
                                  )))),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Usuario.esteUsuario.setPreferenciaSexual = 2;
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color:
                                  Usuario.esteUsuario.getPreferenciaSexual == 2
                                      ? Colors.green[900]
                                      : Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: Center(
                              child: Text("Mujer",
                                  style: GoogleFonts.lato(
                                    fontSize: 35.sp,
                                    color: Usuario.esteUsuario
                                                .getPreferenciaSexual ==
                                            2
                                        ? Colors.white
                                        : Colors.black,
                                  )))),
                    ),
                  )
                ]),
              )
            ]),
      ),
    );
  }
}

///**************************************************************************************************************************************************************
///  CLASSE ITEM: creamos un objeto de la clase ITEM:  En los widgets sex field y date field los desplegables estan compuestos de objetos de clase item que reciben estos
///  parametros(Icon first_icon ,String name, Icon second_icon)
///
/// ICON FIRST_ICON: icono que se encuentra a la izquierda del texto
///
/// STRING NAME: nombre del sexo al que se refiere traducido y se situa en el centro de dos iconos
///
/// ICON SECOND_ICON: icono que se encuentra a la derecha del texto
///
///*************************************************************************************************************************************************************

///**************************************************************************************************************************************************************
///  WIDGET SIGN IN BUTTON: Boton encargado de hacer llamar a la funcion que envia los datos introducidos por el usuario en la pantalla de registro
///
///*************************************************************************************************************************************************************

class ModificadorVeganismo extends StatefulWidget {
  @override
  _ModificadorVeganismoState createState() => _ModificadorVeganismoState();
}

class _ModificadorVeganismoState extends State<ModificadorVeganismo> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          color: Usuario.esteUsuario.vegetarianoOvegano == null
              ? Colors.white
              : Colors.green,
          height: 200.h,
          child: FlatButton(
            onPressed: () {},
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.leaf)),
                Flexible(
                    flex: 10, fit: FlexFit.tight, child: Text("Veganismo")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.vegetarianoOvegano == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.vegetarianoOvegano}"))
              ],
            ),
          )),
    );
  }
}

class PantallaEdicionPerfil extends StatefulWidget {
  static List<String> listaDeImagenesUsuario = [
    Usuario.esteUsuario.imagenUrl1["Imagen"],
    Usuario.esteUsuario.imagenUrl2["Imagen"],
    Usuario.esteUsuario.imagenUrl3["Imagen"],
    Usuario.esteUsuario.imagenUrl4["Imagen"],
    Usuario.esteUsuario.imagenUrl5["Imagen"],
    Usuario.esteUsuario.imagenUrl6["Imagen"],
  ];

  static ScrollController controladorScroll;
  @override
  _PantallaEdicionPerfilState createState() => _PantallaEdicionPerfilState();
}

class _PantallaEdicionPerfilState extends State<PantallaEdicionPerfil> {
  int pos;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: Usuario.esteUsuario,
        child: Consumer<Usuario>(
          builder: (context, myType, child) {
            return Material(
              child: SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
            
                  body: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Añade tus fotos",
                                  style: TextStyle(fontSize: 70.sp),
                                ),
                                Icon(LineAwesomeIcons.camera, size: 90.sp),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 10,
                          fit: FlexFit.tight,
                          child: Container(
                            color: Colors.white,
                            height: 800.h,
                            child: Center(
                              child: DragAndDropGridView(
                                dragStartBehavior: DragStartBehavior.start,
                                isCustomChildWhenDragging: false,
                                physics: NeverScrollableScrollPhysics(),
                                onReorder: (indiceViejo, indiceNuevo) {
                                  setState(() {
                                    if (Usuario.esteUsuario
                                            .fotosPerfil[indiceViejo] !=
                                        null) {
                                      File temporal = Usuario
                                          .esteUsuario.fotosPerfil[indiceNuevo];
                                      Usuario.esteUsuario
                                              .fotosPerfil[indiceNuevo] =
                                          Usuario.esteUsuario
                                              .fotosPerfil[indiceViejo];
                                      Usuario.esteUsuario
                                          .fotosPerfil[indiceViejo] = temporal;
                                    }

                                    pos = null;
                                  });
                                },
                                onWillAccept: (indiceViejo, indiceNuevo) {
                                  setState(() {
                                    pos = indiceNuevo;
                                  });

                                  if (Usuario.esteUsuario
                                          .fotosPerfil[indiceNuevo] !=
                                      null) {
                                    return true;
                                  } else {
                                    return false;
                                  }
                                },
                                controller:
                                    PantallaEdicionPerfil.controladorScroll,
                                itemCount:
                                    Usuario.esteUsuario.fotosPerfil.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0,
                                  crossAxisCount: 3,
                                  childAspectRatio: 1 / 1.8,
                                ),
                                itemBuilder: (context, indice) {
                                  return Opacity(
                                    opacity: pos != null
                                        ? pos == indice
                                            ? 0.4
                                            : 1
                                        : 1,
                                    child: FotosPerfilNuevas(
                                      indice,
                                      Usuario.esteUsuario.fotosPerfil[indice],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Text(
                            "*Presiona y arrastra para cambiar el orden de las imagenes*",
                            style: TextStyle(fontSize: 40.sp),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          fit: FlexFit.loose,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AtributosDestacadosUsuario())),
                            child: Container(
                              height: 150.h,
                              width: 600.w,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                  color: Colors.green),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Siguiente",
                                    style: TextStyle(fontSize: 70.sp),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}

class FotosPerfilNuevas extends StatefulWidget {
  int box;
  File imagen;

  FotosPerfilNuevas(this.box, this.imagen);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FotosPerfilStateNuevas(this.box, this.imagen);
  }
}

class FotosPerfilStateNuevas extends State<FotosPerfilNuevas> {
  @override
  File imagenFinal;
  File imagen;

  static List<File> pictures = Usuario.esteUsuario.fotosPerfil;
  int box;
  int indice;
  int calculadorIndice() {
    return box + 6;
  }

  FotosPerfilStateNuevas(this.box, this.imagen);
  void opcionesImagenPerfil() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Añadir Imagen"),
            content: Text("¿Seleccione la fuente de la imagen?"),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        abrirGaleria(context);
                      },
                      child: Row(
                        children: <Widget>[Text("Galeria"), Icon(Icons.image)],
                      )),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        abrirCamara(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Text("Camara"),
                          Icon(Icons.camera_enhance)
                        ],
                      )),
                ],
              )
            ],
          );
        });
  }

  abrirGaleria(BuildContext context) async {
    var archivoImagen =
        await ImagePicker().getImage(source: ImageSource.gallery);
    File imagenRecortada = await ImageCropper.cropImage(
        sourcePath: archivoImagen.path,
        maxHeight: 1280,
        maxWidth: 720,
        aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
        compressQuality: 70,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imagenRecortada != null) {}

    this.setState(() {
      imagenFinal = imagenRecortada;
      pictures[box] = imagenFinal;
      Usuario.esteUsuario.fotosPerfil = pictures;

      print("${imagenRecortada.lengthSync()} Tamaño Recortado");
      print(box);
    });
  }

  abrirCamara(BuildContext context) async {
    var archivoImagen =
        await ImagePicker().getImage(source: ImageSource.camera);
    File imagenRecortada = await ImageCropper.cropImage(
        sourcePath: archivoImagen.path,

        // aspectRatio: CropAspectRatio(ratioX: 9,ratioY: 16),
        maxHeight: 1280,
        maxWidth: 720,
        compressQuality: 70,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imagenRecortada != null) {}

    this.setState(() {
      imagenFinal = imagenRecortada;
      pictures[box] = imagenFinal;
      Usuario.esteUsuario.fotosPerfil = pictures;

      PantallaEdicionPerfil.listaDeImagenesUsuario[box] = null;

      print("${imagenRecortada.lengthSync()} Tamaño Recortado");
      print(box);
    });
  }

  eliminarImagen(BuildContext context) {
    this.setState(() {
      Usuario.esteUsuario.fotosPerfil[box] = null;
      print("object");
      if (Usuario.esteUsuario.fotosPerfil[box] == null) {
        print("vacio en $box");
      }
      Usuario.esteUsuario.notifyListeners();
    });
  }

  Widget build(BuildContext context) {
    imagen = widget.imagen ?? pictures[box];
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: ScreenUtil().setHeight(420),
        width: ScreenUtil().setWidth(420),
        decoration: imagen == null
            ? BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.grey,
              )
            : BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white30,
                image: DecorationImage(
                    image: FileImage(imagen), fit: BoxFit.cover)),
        child: GestureDetector(
          onTap: () => opcionesImagenPerfil(),
          //  onLongPress: () => eliminarImagen(context),
        ),
      ),
    );
  }
}

class AtributosDestacadosUsuario extends StatefulWidget {
  @override
  _AtributosDestacadosUsuarioState createState() =>
      _AtributosDestacadosUsuarioState();
}

class _AtributosDestacadosUsuarioState
    extends State<AtributosDestacadosUsuario> {
  @override
  Widget build(BuildContext context) {
    return Provider<Usuario>(
      create: (_) => Usuario.esteUsuario,
      child: ChangeNotifierProvider.value(
        value: Usuario.esteUsuario,
        child: SafeArea(
          child: Scaffold(
            body: Container(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      "Caracteristicas",
                      style: TextStyle(
                          fontSize: 60.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Flexible(
                      flex: 18,
                      fit: FlexFit.tight,
                      child: Consumer<Usuario>(
                        builder: (context, myType, child) {
                          return ListaDeCaracteristicasUsuarioEditar();
                        },
                      )),
                  Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PantallaRegistroFinal())),
                        child: Container(
                          height: 150.h,
                          width: 600.w,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              color: Colors.green),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                "Siguiente",
                                style: TextStyle(fontSize: 50.sp),
                              ),
                            ),
                          ),
                        ),
                      ))
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class ListaCaracteristicasEditar extends StatefulWidget {
  @override
  _ListaCaracteristicasEditarState createState() =>
      _ListaCaracteristicasEditarState();
}

class _ListaCaracteristicasEditarState
    extends State<ListaCaracteristicasEditar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            /*Text("Trabajo y Formacion"),
            ModificadorFormacion(),
            ModificadorTrabajo(),*/
            Divider(
              height: ScreenUtil().setHeight(100),
            ),
            EditorOrientacionSexual(),
            EditorAltura(),
            EditorComplexion(),
            EditorAlcohol(),
            EditorTabaco(),
            EditorMascotas(),
            EditorObjetivoRelaciones(),
            EditorHijos(),
            EditorPolitica(),
            EditorVivirCon(),
          ],
        ),
      ),
    );
  }
}

class PantallaRegistroFinal extends StatefulWidget {
  @override
  _PantallaRegistroFinalState createState() => _PantallaRegistroFinalState();
}

class _PantallaRegistroFinalState extends State<PantallaRegistroFinal> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cuentanos sobre ti",
                        style: TextStyle(fontSize: 80.sp),
                      ),
                      Icon(
                        LineAwesomeIcons.pen,
                        size: 70.sp,
                      )
                    ]),
                Divider(
                  height: 200.h,
                ),
                CreadorDescripcion(),
                FlatButton(
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PantallaSolicitudUbicacion()));
                    },
                    child: Text("Registrarse"))
              ],
            )),
          ),
        ),
      ),
    );
  }
}
