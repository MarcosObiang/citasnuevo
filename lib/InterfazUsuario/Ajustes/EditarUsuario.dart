import 'dart:io';
import 'dart:ui';

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_methods.dart';
import 'package:citasnuevo/InterfazUsuario/Ajustes/AjustesHotty.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';

class BotonEditarPerfil extends StatefulWidget {
  @override
  _BotonEditarPerfilState createState() => _BotonEditarPerfilState();
}

class _BotonEditarPerfilState extends State<BotonEditarPerfil> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints limites) {
                      return Container(
                        width: limites.maxHeight,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(Usuario
                                    .esteUsuario.fotosUsuarioActualizar[0]))),
                      );
                    }),
                  ),
                  Flexible(
                    flex: 5,
                    fit: FlexFit.tight,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  "${Usuario.esteUsuario.nombre}, ${Usuario.esteUsuario.edad}",
                                  style: TextStyle(fontSize: 40.sp),
                                ),
                                Usuario.esteUsuario.verificado != "verificado"
                                    ? Container(
                                        height: 0,
                                        width: 0,
                                      )
                                    : Icon(LineAwesomeIcons.check)
                              ],
                            ),
                          ),
                          Container(
                            width: 600.w,
                            child: GestureDetector(
                              onTap: () {
                                Usuario.esteUsuario = Usuario.esteUsuario;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            PantallaEdicionPerfil()));
                              },
                              child: Container(
                                height: 100.h,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text("Editar perfil"),
                                    Icon(Icons.mode_edit),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BotonAjustesAplicacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      child: IconButton(
        color: Colors.green,
        icon: Icon(Icons.settings),
        onPressed: () {},
      ),
    );
  }
}

class BotonesTiendaAplicacion extends StatefulWidget {
  @override
  _BotonesTiendaAplicacionState createState() =>
      _BotonesTiendaAplicacionState();
}

class _BotonesTiendaAplicacionState extends State<BotonesTiendaAplicacion>
   {
  TabController controladorTabuladorPrecions;

  @override
  void initState() {
    // TODO: implement initState

 

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
     
   children:[     Flexible(
          flex: 15,
          fit: FlexFit.tight,
          child:
              Column(
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.deepPurple[900],
                        ),
                        height: 100.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Monedas infinitas",
                                  style: GoogleFonts.lemon(
                                      fontSize: 60.sp, color: Colors.white),
                                ),
                                     Text(
                                  "Hotty Premium",
                                  style: GoogleFonts.lemon(
                                     color: Colors.white),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(shape:BoxShape.circle,color:Colors.red),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text("${9.99} ",
                                            style: GoogleFonts.lemon(
                                                fontSize: 40.sp, color: Colors.white)),
                                        Icon(
                                          Icons.euro,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                       Text(
                                      " mes",
                                      style: GoogleFonts.lemon(
                                         color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 8,
                    child: Container(
                        width: ScreenUtil.screenWidth,
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5 / 1,
                          children: [
                            botonComprasCreditos(0.99, 1000, 1),
                            botonComprasCreditos(1.99, 2000, 1),
                            botonComprasCreditos(2.99, 3500, 1),
                            botonComprasCreditos(3.99, 5000, 1),
                          ],
                        )),
                  )
                ],
              ),
        ),
      ],
    );
  }

  Padding botonComprasCreditos(
      double precioPaqueteCreditos, int cantidadCreditos, int orden) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.green[200],
        ),
        child: FlatButton(
          onPressed: () {},
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 7,
                    child: orden == 1
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(LineAwesomeIcons.coins, size: 70.sp))
                        : orden == 2
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(LineAwesomeIcons.coins, size: 70.sp),
                                  Icon(LineAwesomeIcons.coins, size: 70.sp)
                                ],
                              )
                            : orden == 3
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(LineAwesomeIcons.coins, size: 70.sp),
                                      Row(
                                        children: [
                                          Icon(LineAwesomeIcons.coins,
                                              size: 70.sp),
                                          Icon(LineAwesomeIcons.coins,
                                              size: 70.sp),
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(LineAwesomeIcons.coins,
                                              size: 70.sp),
                                          Icon(LineAwesomeIcons.coins,
                                              size: 70.sp),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(LineAwesomeIcons.coins,
                                              size: 70.sp),
                                          Icon(LineAwesomeIcons.coins,
                                              size: 70.sp),
                                        ],
                                      ),
                                    ],
                                  ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 5,
                    child: Text("$cantidadCreditos Creditos",
                        style: GoogleFonts.lato(
                            fontSize: 45.sp, fontWeight: FontWeight.bold)),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 3,
                    child: Row(
                      children: [
                        Text(
                          "$precioPaqueteCreditos",
                          style: GoogleFonts.lato(
                              fontSize: 50.sp, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.euro, size: 40.sp),
                      ],
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}

class BotonFiltros extends StatefulWidget {
  @override
  _BotonFiltrosState createState() => _BotonFiltrosState();
}

class _BotonFiltrosState extends State<BotonFiltros> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Ajustes()));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.green,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Ajustes",
                style: GoogleFonts.lato(
                    fontSize: 60.sp, fontWeight: FontWeight.bold)),
            Icon(Icons.settings)
          ]),
        ),
      ),
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
    return WillPopScope(
      onWillPop: () async {
        // Usuario.esteUsuario.editarPerfilUsuario(Usuario.esteUsuario.idUsuario);
    
        return true;
      },
      child: ChangeNotifierProvider.value(
          value: Usuario.esteUsuario,
          child: Consumer<Usuario>(
            builder: (context, myType, child) {
              return Material(
                child: SafeArea(
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
               
                    appBar: AppBar(
                      title: Text("Edita tu perfil"),
                    ),
                    body: Container(
                      height: 3000.h,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 50, bottom: 70, left: 10, right: 10),
                          child: Column(children: [
                            Column(
                              children: [
                                Container(
                                  color: Colors.transparent,
                                  height: 1000.h,
                                  child: DragAndDropGridView(
                                    dragStartBehavior: DragStartBehavior.start,
                                    isCustomChildWhenDragging: false,
                                    physics: NeverScrollableScrollPhysics(),
                                    onReorder: (indiceViejo, indiceNuevo) {
                                      setState(() {
                                        if (Usuario.esteUsuario
                                                    .fotosUsuarioActualizar[
                                                indiceViejo] !=
                                            null) {
                                          File temporal = Usuario.esteUsuario
                                                  .fotosUsuarioActualizar[
                                              indiceNuevo];
                                          Usuario.esteUsuario
                                                  .fotosUsuarioActualizar[
                                              indiceNuevo] = Usuario.esteUsuario
                                                  .fotosUsuarioActualizar[
                                              indiceViejo];
                                          Usuario.esteUsuario
                                                  .fotosUsuarioActualizar[
                                              indiceViejo] = temporal;
                                        }

                                        pos = null;
                                      });
                                    },
                                    onWillAccept: (indiceViejo, indiceNuevo) {
                                      setState(() {
                                        pos = indiceNuevo;
                                      });

                                      if (Usuario.esteUsuario
                                                  .fotosUsuarioActualizar[
                                              indiceNuevo] !=
                                          null) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    },
                                    controller:
                                        PantallaEdicionPerfil.controladorScroll,
                                    itemCount: Usuario.esteUsuario
                                        .fotosUsuarioActualizar.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1 / 1.60,
                                    ),
                                    itemBuilder: (context, indice) {
                                      return Opacity(
                                        opacity: pos != null
                                            ? pos == indice
                                                ? 0.4
                                                : 1
                                            : 1,
                                        child: FotosPerfil(
                                          indice,
                                          Usuario.esteUsuario
                                              .fotosUsuarioActualizar[indice],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Divider(height: 80.h),
                                Text(
                                    "*Presiona y arrastra para cambiar el orden de las imagenes*"),
                                EditorDescripcion(),
                                Container(
                                    height: 1000.h,
                                    child:
                                        ListaDeCaracteristicasUsuarioEditar()),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}

class ListaDeCaracteristicasUsuarioEditar extends StatefulWidget {
  @override
  _ListaDeCaracteristicasUsuarioEditarState createState() =>
      _ListaDeCaracteristicasUsuarioEditarState();
}

class _ListaDeCaracteristicasUsuarioEditarState
    extends State<ListaDeCaracteristicasUsuarioEditar> {
  ScrollController controladorScroll =
      new ScrollController(keepScrollOffset: true);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: controladorScroll,
          thickness: 20.w,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 15),
            child: ListView(
              children: <Widget>[
                /*Text("Trabajo y Formacion"),
                ModificadorFormacion(),
                ModificadorTrabajo(),*/

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
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
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
        SizedBox(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Center(
              child: widget.dato == null
                  ? Text("")
                  : Text(
                      widget.dato.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(70),
                          fontWeight: FontWeight.bold,
                          color: widget.dato < 18 ? Colors.red : Colors.green),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class BotonNacimiento extends StatefulWidget {
  DateTime dato;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BotonNacimientoState();
  }

  BotonNacimiento(this.dato);
}

class BotonNacimientoState extends State<BotonNacimiento> {
  String texto_boton_edad;
  DateTime date;
  static int age;
  final f = new DateFormat('dd-MM-yyyy');

  static int GetAge() {
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3))),
          child: FlatButton(
            onPressed: () {
              setState(() {
                showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now())
                    .then((data) {
                  if (data != null) {
                    int dato = nacimiento_usuario().edad(data);
                    Usuario.esteUsuario.fechaNacimiento = data;
                    date = data;
                    Usuario.esteUsuario.edad = dato;
                    Usuario.esteUsuario.notifyListeners();
                  }

                  print(data);
                  return data;
                });
              });
            },
            child: Text(
              Usuario.esteUsuario.fechaNacimiento == null ||
                      Usuario.esteUsuario.fechaNacimiento.day == null ||
                      Usuario.esteUsuario.fechaNacimiento.month == null ||
                      Usuario.esteUsuario.fechaNacimiento.year == null
                  ? "Fecha de Nacimimento"
                  : f.format(Usuario.esteUsuario.fechaNacimiento),
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40),
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class FotoUsuario extends StatefulWidget {
  String urlImagen;

  FotoUsuario({@required this.urlImagen});

  @override
  _FotoUsuarioState createState() => _FotoUsuarioState();
}

class _FotoUsuarioState extends State<FotoUsuario> {
  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      feedback: Container(
        height: 300.h,
        width: 300.w,
        decoration: widget.urlImagen != null
            ? BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
                image: DecorationImage(
                    image: NetworkImage(widget.urlImagen), fit: BoxFit.cover),
                boxShadow: [
                    BoxShadow(
                        blurRadius: 20.sp,
                        color: Colors.transparent,
                        spreadRadius: 20.sp)
                  ])
            : BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
              ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.9),
          image: DecorationImage(
              image: NetworkImage(widget.urlImagen), fit: BoxFit.cover),
        ),
      ),
      onDragStarted: () => print("arrastre"),
    );
  }
}

class FotosPerfil extends StatefulWidget {
  int box;
  File Imagen;

  FotosPerfil(this.box, this.Imagen);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FotosPerfilState(this.box, this.Imagen);
  }
}

class FotosPerfilState extends State<FotosPerfil> {
  @override
  File imagenFinal;
  File imagen;

  static List<File> pictures = Usuario.esteUsuario.fotosUsuarioActualizar;
  int box;
  int indice;
  int calculadorIndice() {
    return box + 6;
  }

  FotosPerfilState(this.box, this.imagen);
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
        compressQuality: 90,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )).catchError((error) {
      print(error);
    });
    if (imagenRecortada != null) {}

    this.setState(() {
      imagenFinal = imagenRecortada;
      pictures[box] = imagenFinal;
      Usuario.esteUsuario.fotosUsuarioActualizar = pictures;

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
        maxHeight: 1000,
        maxWidth: 720,
        compressQuality: 90,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )).catchError((error) {
      print(error);
    });
    if (imagenRecortada != null) {}

    this.setState(() {
      imagenFinal = imagenRecortada;
      pictures[box] = imagenFinal;
      Usuario.esteUsuario.fotosUsuarioActualizar = pictures;

      PantallaEdicionPerfil.listaDeImagenesUsuario[box] = null;

      print("${imagenRecortada.lengthSync()} Tamaño Recortado");
      print(box);
    });
  }

  eliminarImagen(BuildContext context) {
    this.setState(() {
      Usuario.esteUsuario.fotosUsuarioActualizar[box] = null;
      print("object");
      if (Usuario.esteUsuario.fotosUsuarioActualizar[box] == null) {
        print("vacio en $box");
      }
      Usuario.esteUsuario.notifyListeners();
    });
  }

  Widget build(BuildContext context) {
    imagen = widget.Imagen ?? pictures[box];
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(8.0),
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

class EditorNombre extends StatefulWidget {
  @override
  _EditorNombreState createState() => _EditorNombreState();
}

class _EditorNombreState extends State<EditorNombre> {
  TextEditingController controladorEditorNombre = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    controladorEditorNombre.text = Usuario.esteUsuario.nombre;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controladorEditorNombre,
        decoration: InputDecoration(
            labelText: "Nombre",
            floatingLabelBehavior: FloatingLabelBehavior.always),
        onChanged: (val) {
          Usuario.esteUsuario.nombre = val;
        },
      ),
    );
  }
}

class EditorDescripcion extends StatefulWidget {
  @override
  _EditorDescripcionState createState() => _EditorDescripcionState();
}

class _EditorDescripcionState extends State<EditorDescripcion> {
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
        maxLines: 5,
        controller: controladorEditorDescripcion,
        textInputAction: TextInputAction.done,
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

class EditorAltura extends StatefulWidget {
  @override
  _EditorAlturaState createState() => _EditorAlturaState();
}

class _EditorAlturaState extends State<EditorAltura> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.altura == null
                  ? Colors.white
                  : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.ruler_vertical)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Altura")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(
                      Usuario.esteUsuario.altura == null
                          ? "Responder"
                          : "${Usuario.esteUsuario.altura.toStringAsFixed(2)} m",
                    ))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    double altura = Usuario.esteUsuario.altura ?? 1.20;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Provider<Usuario>(
          create: (_) => Usuario.esteUsuario,
          builder: (context, child) {
            return ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Material(
                child: Container(
                  height: ScreenUtil.screenHeight / 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: Row(
                              children: <Widget>[
                                Icon(LineAwesomeIcons.ruler_vertical),
                                Text(
                                  "Altura",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60)),
                                ),
                              ],
                            )),
                            FlatButton(
                                onPressed: () {
                                  Usuario.esteUsuario.altura = null;
                                  Usuario.esteUsuario.notifyListeners();
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    Text("Eliminar",
                                        style: TextStyle(color: Colors.red))
                                  ],
                                )),
                          ],
                        ),
                      ),
                      Consumer<Usuario>(
                        builder: (context, myType, child) {
                          return Slider(
                              min: 1.0,
                              max: 2.5,
                              value: altura,
                              onChanged: (value) {
                                setState(() {
                                  Usuario.esteUsuario.altura = value;
                                  altura = value;
                                });

                                print(value);

                                Usuario.esteUsuario.notifyListeners();
                              });
                        },
                      ),
                      Consumer<Usuario>(
                        builder: (context, myType, child) {
                          return Text(
                            "${altura.toStringAsFixed(2)} m",
                            style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            child: FlatButton(
                                onPressed: () {
                                  Usuario.esteUsuario.altura =
                                      double.parse(altura.toStringAsFixed(2));
                                  print(Usuario.esteUsuario.altura);
                                  Navigator.pop(context);
                                  Usuario.esteUsuario.notifyListeners();
                                },
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class EditorOrientacionSexual extends StatefulWidget {
  @override
  _EditorOrientacionSexualState createState() =>
      _EditorOrientacionSexualState();
}

class _EditorOrientacionSexualState extends State<EditorOrientacionSexual> {
  bool hetero = false;
  bool gay = false;
  bool lesbiana = false;
  bool bisexual = false;
  bool asexual = false;
  bool demisexual = false;
  bool queer = false;
  bool pansexual = false;
  bool pregunatme = false;

  void mostrarValor() {
    if (Usuario.esteUsuario.getOrientacionSexual == 0) {
      hetero = false;
      gay = false;
      lesbiana = false;
      bisexual = false;
      asexual = false;
      demisexual = false;
      queer = false;
      pansexual = false;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 1) {
      hetero = true;
      gay = false;
      lesbiana = false;
      bisexual = false;
      asexual = false;
      demisexual = false;
      queer = false;
      pansexual = false;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 2) {
      hetero = false;
      gay = true;
      lesbiana = false;
      bisexual = false;
      asexual = false;
      demisexual = false;
      queer = false;
      pansexual = false;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 3) {
      hetero = false;
      gay = false;
      lesbiana = true;
      bisexual = false;
      asexual = false;
      demisexual = false;
      queer = false;
      pansexual = false;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 4) {
      hetero = false;
      gay = false;
      lesbiana = false;
      bisexual = true;
      asexual = false;
      demisexual = false;
      queer = false;
      pansexual = false;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 5) {
      hetero = false;
      gay = false;
      lesbiana = false;
      bisexual = false;
      asexual = true;
      demisexual = false;
      queer = false;
      pansexual = false;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 6) {
      hetero = false;
      gay = false;
      lesbiana = false;
      bisexual = false;
      asexual = false;
      demisexual = true;
      queer = false;
      pansexual = false;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 7) {
      hetero = false;
      gay = false;
      lesbiana = false;
      bisexual = false;
      asexual = false;
      demisexual = false;
      queer = true;
      pansexual = false;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 8) {
      hetero = false;
      gay = false;
      lesbiana = false;
      bisexual = false;
      asexual = false;
      demisexual = false;
      queer = false;
      pansexual = true;
      pregunatme = false;
    }
    if (Usuario.esteUsuario.getOrientacionSexual == 9) {
      hetero = false;
      gay = false;
      lesbiana = false;
      bisexual = false;
      asexual = false;
      demisexual = false;
      queer = false;
      pansexual = false;
      pregunatme = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    mostrarValor();
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.getOrientacionSexual == 0
                  ? Colors.white
                  : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.venus_mars)),
                Flexible(
                    flex: 10,
                    fit: FlexFit.tight,
                    child: Text("Orientacion sexual")),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Text(
                      Usuario.esteUsuario.getOrientacionSexual == 0
                          ? "Responder"
                          : "${Usuario.esteUsuario.orientacionesSexuales[Usuario.esteUsuario.getOrientacionSexual]}",
                    ))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Provider<Usuario>(
          create: (_) => Usuario.esteUsuario,
          builder: (context, child) {
            return ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Material(
                child: Container(
                    height: ScreenUtil.screenHeight,
                    child: Consumer<Usuario>(
                      builder: (context, myType, child) {
                        return botonesOrientacionSexual(context);
                      },
                    )),
              ),
            );
          },
        );
      },
    );
  }

  Column botonesOrientacionSexual(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
           flex: 2,
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    child: Row(
                  children: <Widget>[
                    Icon(LineAwesomeIcons.venus_mars),
                    Text(
                      "Orientacion Sexual",
                      style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                    ),
                  ],
                )),
                FlatButton(
                    onPressed: () {
                      Usuario.esteUsuario.setPreferenciaSexual = 0;

                      Navigator.pop(context);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        Text("Eliminar", style: TextStyle(color: Colors.red))
                      ],
                    )),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 9,
          fit: FlexFit.tight,
          child: ListView(
            children: [
              CheckboxListTile(
                  title: Text("Heterosexual"),
                  value: hetero,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 1;
                    mostrarValor();
                  }),
              CheckboxListTile(
                  title: Text("Gay"),
                  value: gay,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 2;
                     mostrarValor();
                  }),
              CheckboxListTile(
                  title: Text("Lesbiana"),
                  value: lesbiana,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 3;
                     mostrarValor();
                  }),
              CheckboxListTile(
                  title: Text("Bisexual"),
                  value: bisexual,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 4;
                     mostrarValor();
                  }),
              CheckboxListTile(
                  title: Text("Asexual"),
                  value: asexual,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 5;
                     mostrarValor();
                  }),
              CheckboxListTile(
                  title: Text("Demisexual"),
                  value: demisexual,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 6;
                     mostrarValor();
                  }),
              CheckboxListTile(
                  title: Text("Queer"),
                  value: queer,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 7;
                     mostrarValor();
                  }),
              CheckboxListTile(
                  title: Text("Pansexual"),
                  value: pansexual,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 8;
                     mostrarValor();
                  }),
              CheckboxListTile(
                  title: Text("Preguntame"),
                  value: pregunatme,
                  onChanged: (valor) {
                    Usuario.esteUsuario.setOrientacionSexual = 9;
                    mostrarValor();
                  }),
            ],
          ),
        ),
        Flexible(
           flex: 2,
          fit: FlexFit.tight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.red),
                    )),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Aceptar",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        )
      ],
    );
  }
}

class EditorComplexion extends StatefulWidget {
  @override
  _EditorComplexionState createState() => _EditorComplexionState();
}

class _EditorComplexionState extends State<EditorComplexion> {
  String valorMostrar;
  void valorUsuario() {
    if (Usuario.esteUsuario.getComplexion == 0) {}
    if (Usuario.esteUsuario.getComplexion == 1) {
      valorMostrar = "Normal";
    }
    if (Usuario.esteUsuario.getComplexion == 2) {
      valorMostrar = "Atletica";
    }
    if (Usuario.esteUsuario.getComplexion == 3) {
      valorMostrar = "Musculosa";
    }

    if (Usuario.esteUsuario.getComplexion == 4) {
      valorMostrar = "Talla grande";
    }
    if (Usuario.esteUsuario.getComplexion == 5) {
      valorMostrar = "Delgada";
    }
  }

  @override
  Widget build(BuildContext context) {
    valorUsuario();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.getComplexion == 0
                  ? Colors.white
                  : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.snowboarding)),
                Flexible(
                    flex: 10, fit: FlexFit.tight, child: Text("Complexion")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.getComplexion == 0
                        ? "Responder"
                        : "$valorMostrar"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool atletico = false;
    bool normal = false;
    bool kiloDeMas = false;
    bool musculosa = false;
    bool tallaGrande = false;
    bool delgada = false;

    if (Usuario.esteUsuario.getComplexion == 0) {
      atletico = false;
      normal = false;
      kiloDeMas = false;
      musculosa = false;
      tallaGrande = false;
      delgada = false;
    }
    if (Usuario.esteUsuario.getComplexion == 1) {
      normal = true;
    }
    if (Usuario.esteUsuario.getComplexion == 2) {
      atletico = true;
    }
    if (Usuario.esteUsuario.getComplexion == 3) {
      musculosa = true;
    }

    if (Usuario.esteUsuario.getComplexion == 4) {
      tallaGrande = true;
    }
    if (Usuario.esteUsuario.getComplexion == 5) {
      delgada = true;
    }

    showDialog(
       
        context: context,
        builder: (context) {
          return 
               StatefulBuilder(builder: (context,child){
                return   ChangeNotifierProvider.value(
                  value:Usuario.esteUsuario,
                  child: Material(
                    child: cuerpo(context, normal, atletico, kiloDeMas, musculosa,
                      tallaGrande, delgada),
                  ),
                );
              },);
          
          
        });
  }

  Container cuerpo(BuildContext context, bool normal, bool atletico,
      bool kiloDeMas, bool musculosa, bool tallaGrande, bool delgada) {
    return Container(
        height: ScreenUtil.screenHeight / 5,
        child: Consumer<Usuario>(
          builder: (context, myType, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          child: Row(
                        children: <Widget>[
                          Icon(LineAwesomeIcons.skiing),
                          Text(
                            "Complexion",
                            style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                          ),
                        ],
                      )),
                      FlatButton(
                          onPressed: () {
                            Usuario.esteUsuario.setComplexion = 0;

                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                              Text("Borrar",
                                  style: TextStyle(color: Colors.red))
                            ],
                          )),
                    ],
                  ),
                ),
                CheckboxListTile(
                    value: normal,
                    title: Text("Normal"),
                    onChanged: (bool value) {
                      normal = value;

                      atletico = false;

                      kiloDeMas = false;
                      musculosa = false;
                      tallaGrande = false;
                      delgada = false;
                      Usuario.esteUsuario.setComplexion = 1;
                      setState(() {
                                              
                                            });
                    }),
                CheckboxListTile(
                    value: atletico,
                    title: Text("Atletico"),
                    onChanged: (bool value) {
                      atletico = value;

                      normal = false;
                      kiloDeMas = false;
                      musculosa = false;
                      tallaGrande = false;
                      delgada = false;
                      Usuario.esteUsuario.setComplexion = 2;
                    }),
                CheckboxListTile(
                    value: musculosa,
                    title: Text("Musculosa"),
                    onChanged: (bool value) {
                      musculosa = value;
                      atletico = false;
                      normal = false;
                      kiloDeMas = false;

                      tallaGrande = false;
                      delgada = false;
                      Usuario.esteUsuario.setComplexion = 3;
                    }),
                CheckboxListTile(
                    value: tallaGrande,
                    title: Text("Talla Grande"),
                    onChanged: (bool value) {
                      tallaGrande = value;
                      atletico = false;
                      normal = false;
                      kiloDeMas = false;
                      musculosa = false;

                      delgada = false;
                      Usuario.esteUsuario.setComplexion = 4;
                    }),
                CheckboxListTile(
                    value: delgada,
                    title: Text("Delgado"),
                    onChanged: (bool value) {
                      delgada = value;
                      atletico = false;
                      normal = false;
                      kiloDeMas = false;
                      musculosa = false;
                      tallaGrande = false;
                      Usuario.esteUsuario.setComplexion = 5;
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.red),
                          )),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Usuario.esteUsuario.notifyListeners();
                          },
                          child: Text(
                            "Aceptar",
                            style: TextStyle(color: Colors.white),
                          )),
                    )
                  ],
                )
              ],
            );
          },
        ));
  }
}

class EditorAlcohol extends StatefulWidget {
  @override
  _EditorAlcoholState createState() => _EditorAlcoholState();
}

class _EditorAlcoholState extends State<EditorAlcohol> {
  String valorMostrar;
  void valorUsuario() {
    if (Usuario.esteUsuario.alcohol == 1) {
      valorMostrar = "En sociedad";
    }
    if (Usuario.esteUsuario.alcohol == 2) {
      valorMostrar = "No bebo";
    }
    if (Usuario.esteUsuario.alcohol == 3) {
      valorMostrar = "Bebo";
    }

    if (Usuario.esteUsuario.alcohol == 4) {
      valorMostrar = "En contra del alcohol";
    }
  }

  @override
  Widget build(BuildContext context) {
    valorUsuario();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.alcohol == 0
                  ? Colors.white
                  : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.beer)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Alcohol")),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.alcohol == 0
                        ? "Responder"
                        : "$valorMostrar"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool sociedad = false;
    bool noBebo = false;
    bool beboMucho = false;

    bool enContraDeLaBebida = false;

    if (Usuario.esteUsuario.alcohol == 0) {
      sociedad = false;
      noBebo = false;
      beboMucho = false;

      enContraDeLaBebida = false;
    }
    if (Usuario.esteUsuario.alcohol == 1) {
      sociedad = true;
    }
    if (Usuario.esteUsuario.alcohol == 2) {
      noBebo = true;
    }
    if (Usuario.esteUsuario.alcohol == 3) {
      beboMucho = true;
    }
    if (Usuario.esteUsuario.alcohol == 4) {
      enContraDeLaBebida = true;
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context,child){
              return   ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Material(
                child: Container(
                  height: ScreenUtil.screenHeight / 7,
                  child: cuerpo(
                      context, sociedad, noBebo, beboMucho, enContraDeLaBebida),
                ),
              ),
            );
            },
      
          );
        });
  }

  Consumer cuerpo(BuildContext context, bool sociedad, bool noBebo,
      bool beboMucho, bool enContraDeLaBebida) {
    return Consumer<Usuario>(
      builder: (context, myType, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      child: Row(
                    children: <Widget>[
                      Icon(LineAwesomeIcons.beer),
                      Text(
                        "Alcohol",
                        style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                      ),
                    ],
                  )),
                  FlatButton(
                      onPressed: () {
                        Usuario.esteUsuario.complexion = null;
                        Usuario.esteUsuario.notifyListeners();
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          Text("Borrar", style: TextStyle(color: Colors.red))
                        ],
                      )),
                ],
              ),
            ),
            CheckboxListTile(
                value: sociedad,
                title: Text("En Sociedad"),
                onChanged: (bool value) {
                  sociedad = value;
                  noBebo = false;

                  beboMucho = false;

                  enContraDeLaBebida = false;

                  Usuario.esteUsuario.alcohol = 1;
                  Usuario.esteUsuario.notifyListeners();
                }),
            CheckboxListTile(
                value: noBebo,
                title: Text("No Bebo"),
                onChanged: (bool value) {
                  noBebo = value;

                  sociedad = false;
                  beboMucho = false;

                  enContraDeLaBebida = false;

                  Usuario.esteUsuario.alcohol = 2;
                  Usuario.esteUsuario.notifyListeners();
                }),
            CheckboxListTile(
                value: beboMucho,
                title: Text("Bebo"),
                onChanged: (bool value) {
                  beboMucho = value;
                  sociedad = false;
                  noBebo = false;

                  enContraDeLaBebida = false;

                  Usuario.esteUsuario.alcohol = 3;
                  Usuario.esteUsuario.notifyListeners();
                }),
            CheckboxListTile(
                value: enContraDeLaBebida,
                title: Text("En Contra del Alcohol"),
                onChanged: (bool value) {
                  enContraDeLaBebida = value;
                  sociedad = false;
                  noBebo = false;

                  beboMucho = false;

                  Usuario.esteUsuario.alcohol = 4;
                  Usuario.esteUsuario.notifyListeners();
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.red),
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  child: FlatButton(
                      onPressed: () {
                        print(Usuario.esteUsuario.altura);
                        Navigator.pop(context);
                        Usuario.esteUsuario.notifyListeners();
                      },
                      child: Text(
                        "Aceptar",
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            )
          ],
        );
      },
    );
  }
}

class EditorTabaco extends StatefulWidget {
  @override
  _EditorTabacoState createState() => _EditorTabacoState();
}

class _EditorTabacoState extends State<EditorTabaco> {
  String valorMostrar;
  void valorUsuario() {
    if (Usuario.esteUsuario.tabaco == 1) {
      valorMostrar = "Fumo";
    }
    if (Usuario.esteUsuario.tabaco == 2) {
      valorMostrar = "No fumo";
    }
    if (Usuario.esteUsuario.tabaco == 3) {
      valorMostrar = "Fumador social";
    }

    if (Usuario.esteUsuario.tabaco == 4) {
      valorMostrar = "Odio el tabaco";
    }
  }

  @override
  Widget build(BuildContext context) {
    valorUsuario();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color:
                  Usuario.esteUsuario.tabaco == 0 ? Colors.white : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.smoking)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Tabaco")),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.tabaco == 0
                        ? "Responder"
                        : "$valorMostrar"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool fumo = false;
    bool noFumo = false;
    bool fumoSociedad = false;

    bool odioTabaco = false;

    if (Usuario.esteUsuario.tabaco == 0) {
      fumo = false;
      noFumo = false;
      fumoSociedad = false;

      odioTabaco = false;
    }
    if (Usuario.esteUsuario.tabaco == 1) {
      fumo = true;
    }
    if (Usuario.esteUsuario.tabaco == 2) {
      noFumo = true;
    }
    if (Usuario.esteUsuario.tabaco == 3) {
      fumoSociedad = true;
    }
    if (Usuario.esteUsuario.tabaco == 4) {
      odioTabaco = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
      builder:(context,child){
        return  ChangeNotifierProvider.value(
            value: Usuario.esteUsuario,
            child: Material(
              child: Container(
                height: ScreenUtil.screenHeight / 7,
                child: cuerpo(context, fumo, noFumo, fumoSociedad, odioTabaco),
              ),
            ),
          );
      }
         
        );
      },
    );
  }

  Consumer cuerpo(BuildContext context, bool fumo, bool noFumo,
      bool fumoSociedad, bool odioTabaco) {
    return Consumer<Usuario>(
      builder: (context, myType, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      child: Row(
                    children: <Widget>[
                      Icon(LineAwesomeIcons.smoking),
                      Text(
                        "Tabaco",
                        style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                      ),
                    ],
                  )),
                  FlatButton(
                      onPressed: () {
                        Usuario.esteUsuario.tabaco = 0;
                        Usuario.esteUsuario.notifyListeners();
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          Text("Borrar", style: TextStyle(color: Colors.red))
                        ],
                      )),
                ],
              ),
            ),
            CheckboxListTile(
                value: fumo,
                title: Text("Fumo"),
                onChanged: (bool value) {
                  fumo = value;
                  noFumo = false;

                  fumoSociedad = false;

                  odioTabaco = false;

                  Usuario.esteUsuario.tabaco = 1;
                  Usuario.esteUsuario.notifyListeners();
                }),
            CheckboxListTile(
                value: noFumo,
                title: Text("No Fumo"),
                onChanged: (bool value) {
                  noFumo = value;

                  fumo = false;
                  fumoSociedad = false;

                  odioTabaco = false;

                  Usuario.esteUsuario.tabaco = 2;
                  Usuario.esteUsuario.notifyListeners();
                }),
            CheckboxListTile(
                value: fumoSociedad,
                title: Text("Fumador Social"),
                onChanged: (bool value) {
                  fumoSociedad = value;
                  fumo = false;
                  noFumo = false;

                  odioTabaco = false;

                  Usuario.esteUsuario.tabaco = 3;
                  Usuario.esteUsuario.notifyListeners();
                }),
            CheckboxListTile(
                value: odioTabaco,
                title: Text("Odio el Tabaco"),
                onChanged: (bool value) {
                  odioTabaco = value;
                  fumo = false;
                  noFumo = false;

                  fumoSociedad = false;

                  Usuario.esteUsuario.tabaco = 4;
                  Usuario.esteUsuario.notifyListeners();
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.red),
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Usuario.esteUsuario.notifyListeners();
                      },
                      child: Text(
                        "Aceptar",
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            )
          ],
        );
      },
    );
  }
}

class EditorMascotas extends StatefulWidget {
  @override
  _EditorMascotasState createState() => _EditorMascotasState();
}

class _EditorMascotasState extends State<EditorMascotas> {
  String valorMostrar;
  void valorUsuario() {
    if (Usuario.esteUsuario.mascotas == 1) {
      valorMostrar = "Perros";
    }
    if (Usuario.esteUsuario.mascotas == 2) {
      valorMostrar = "Gatos";
    }
    if (Usuario.esteUsuario.mascotas == 3) {
      valorMostrar = "No tengo";
    }

    if (Usuario.esteUsuario.mascotas == 4) {
      valorMostrar = "Me gustaria";
    }
  }

  @override
  Widget build(BuildContext context) {
    valorUsuario();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.mascotas == 0
                  ? Colors.white
                  : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.dog)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Mascotas")),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.mascotas == 0
                        ? "Responder"
                        : "$valorMostrar"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool perro = false;
    bool gato = false;
    bool nunca = false;

    bool meGustaria = false;

    if (Usuario.esteUsuario.mascotas == 0) {
      perro = false;
      gato = false;
      nunca = false;

      meGustaria = false;
    }
    if (Usuario.esteUsuario.mascotas == 1) {
      perro = true;
    }
    if (Usuario.esteUsuario.mascotas == 2) {
      gato = true;
    }
    if (Usuario.esteUsuario.mascotas == 3) {
      nunca = true;
    }
    if (Usuario.esteUsuario.mascotas == 4) {
      meGustaria = true;
    }

    showDialog(
     
      context: context,
      builder: (context) {
        return StatefulBuilder(
       builder: (context,child){
return ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Material(
                child:  cuerpo(context, perro, gato, nunca, meGustaria),
                
              ));
       }
        );
      },
    );
  }

  Widget cuerpo(BuildContext context, bool perro, bool gato, bool nunca, bool meGustaria) {
    return Consumer<Usuario>(
      builder: (context, myType, child) {
        return  Container(
                  height: ScreenUtil.screenHeight / 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: Row(
                              children: <Widget>[
                                Icon(LineAwesomeIcons.dog),
                                Text(
                                  "Mascotas",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60)),
                                ),
                              ],
                            )),
                            FlatButton(
                                onPressed: () {
                                  Usuario.esteUsuario.mascotas = null;
                                  Usuario.esteUsuario.notifyListeners();
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    Text("Borrar",
                                        style: TextStyle(color: Colors.red))
                                  ],
                                )),
                          ],
                        ),
                      ),
                      CheckboxListTile(
                          value: perro,
                          title: Text("Perro"),
                          onChanged: (bool value) {
                            perro = value;
                            gato = false;

                            nunca = false;

                            meGustaria = false;

                            Usuario.esteUsuario.mascotas = 1;
                            Usuario.esteUsuario.notifyListeners();
                            setState(() {
                                                          
                                                        });
                          }),
                      CheckboxListTile(
                          value: gato,
                          title: Text("Gato"),
                          onChanged: (bool value) {
                            gato = value;

                            perro = false;
                            nunca = false;

                            meGustaria = false;

                            Usuario.esteUsuario.mascotas = 2;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: nunca,
                          title: Text("No tengo"),
                          onChanged: (bool value) {
                            nunca = value;
                            perro = false;
                            gato = false;

                            meGustaria = false;

                            Usuario.esteUsuario.mascotas = 3;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: meGustaria,
                          title: Text("Me Gustaria"),
                          onChanged: (bool value) {
                            meGustaria = value;
                            perro = false;
                            gato = false;

                            nunca = false;

                            Usuario.esteUsuario.mascotas = 4;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Usuario.esteUsuario.notifyListeners();
                                },
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                ) ;
      },
    );
    
    
    
    
    
  }
}

class EditorObjetivoRelaciones extends StatefulWidget {
  @override
  _EditorObjetivoRelacionesState createState() =>
      _EditorObjetivoRelacionesState();
}

class _EditorObjetivoRelacionesState extends State<EditorObjetivoRelaciones> {
  String valorMostrar;
  void valorUsuario() {
    if (Usuario.esteUsuario.busco == 1) {
      valorMostrar = "Relacion seria";
    }
    if (Usuario.esteUsuario.busco == 2) {
      valorMostrar = "Lo que surja";
    }
    if (Usuario.esteUsuario.busco == 3) {
      valorMostrar = "Algo casual";
    }

    if (Usuario.esteUsuario.busco == 4) {
      valorMostrar = "No se";
    }
  }

  @override
  Widget build(BuildContext context) {
    valorUsuario();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color:
                  Usuario.esteUsuario.busco == 0 ? Colors.white : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.heart)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Busco")),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.busco == 0
                        ? "Responder"
                        : "$valorMostrar"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool relacionSeria = false;
    bool loQueSurja = false;
    bool casual = false;
    bool noLoSe = false;

    if (Usuario.esteUsuario.mascotas == 0) {
      relacionSeria = false;
      loQueSurja = false;
      casual = false;
      noLoSe = false;
    }

    if (Usuario.esteUsuario.busco == 1) {
      relacionSeria = true;
    }
    if (Usuario.esteUsuario.busco == 2) {
      loQueSurja = true;
    }
    if (Usuario.esteUsuario.busco == 3) {
      casual = true;
    }
    if (Usuario.esteUsuario.busco == 4) {
      noLoSe = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context,child){
return  ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Material(child: newMethod(relacionSeria, loQueSurja, noLoSe, casual)));
          },
      
        );
      },
    );
  }

  Consumer<Usuario> newMethod(bool relacionSeria, bool loQueSurja, bool noLoSe, bool casual) {
    return Consumer<Usuario>(
              builder: (context, myType, child) {
                return Container(
                  height: ScreenUtil.screenHeight / 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: Row(
                              children: <Widget>[
                                Icon(LineAwesomeIcons.heart),
                                Text(
                                  "Busco",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60)),
                                ),
                              ],
                            )),
                            FlatButton(
                                onPressed: () {
                                  Usuario.esteUsuario.busco = 0;
                                  Usuario.esteUsuario.notifyListeners();
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    Text("Borrar",
                                        style: TextStyle(color: Colors.red))
                                  ],
                                )),
                          ],
                        ),
                      ),
                      CheckboxListTile(
                          value: relacionSeria,
                          title: Text("Relacion seria"),
                          onChanged: (bool value) {
                            relacionSeria = value;
                            loQueSurja = false;
                            noLoSe = false;
                            casual = false;

                            Usuario.esteUsuario.busco = 1;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: loQueSurja,
                          title: Text("Lo que surja"),
                          onChanged: (bool value) {
                            loQueSurja = value;
                            noLoSe = false;
                            relacionSeria = false;
                            casual = false;

                            Usuario.esteUsuario.busco = 2;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: casual,
                          title: Text("Algo casual"),
                          onChanged: (bool value) {
                            casual = value;
                            relacionSeria = false;
                            loQueSurja = false;

                            noLoSe = false;

                            Usuario.esteUsuario.busco = 3;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: noLoSe,
                          title: Text("No lo se"),
                          onChanged: (bool value) {
                            noLoSe = value;

                            relacionSeria = false;
                            loQueSurja = false;

                            casual = false;

                            Usuario.esteUsuario.busco = 4;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Usuario.esteUsuario.notifyListeners();
                                },
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            );
  }
}

class EditorHijos extends StatefulWidget {
  @override
  _EditorHijosState createState() => _EditorHijosState();
}

class _EditorHijosState extends State<EditorHijos> {
  String valorMostrar;
  void valorUsuario() {
    if (Usuario.esteUsuario.hijos == 1) {
      valorMostrar = "Algun dia";
    }
    if (Usuario.esteUsuario.hijos == 2) {
      valorMostrar = "Tengo";
    }
    if (Usuario.esteUsuario.hijos == 3) {
      valorMostrar = "Tengo";
    }
  }

  @override
  Widget build(BuildContext context) {
    valorUsuario();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color:
                  Usuario.esteUsuario.hijos == 0 ? Colors.white : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.baby)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Hijos")),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.hijos == 0
                        ? "Responder"
                        : "$valorMostrar"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool sihijos = false;
    bool nohijos = false;
    bool tengoHijos = false;

    if (Usuario.esteUsuario.hijos == 0) {
      sihijos = false;
      nohijos = false;
      tengoHijos = false;
    }
    if (Usuario.esteUsuario.hijos == 1) {
      sihijos = true;
    }
    if (Usuario.esteUsuario.hijos == 2) {
      nohijos = true;
    }
    if (Usuario.esteUsuario.hijos == 3) {
      tengoHijos = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
         builder:(context,child){
           return ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Material(child: newMethod(sihijos, nohijos, tengoHijos)));
         },
          
        );
      },
    );
  }

  Consumer<Usuario> newMethod(bool sihijos, bool nohijos, bool tengoHijos) {
    return Consumer<Usuario>(
              builder: (context, myType, child) {
                return Container(
                  height: ScreenUtil.screenHeight / 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: Row(
                              children: <Widget>[
                                Icon(LineAwesomeIcons.baby),
                                Text(
                                  "Busco",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60)),
                                ),
                              ],
                            )),
                            FlatButton(
                                onPressed: () {
                                  Usuario.esteUsuario.hijos = 0;
                                  Usuario.esteUsuario.notifyListeners();
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    Text("Borrar",
                                        style: TextStyle(color: Colors.red))
                                  ],
                                )),
                          ],
                        ),
                      ),
                      CheckboxListTile(
                          value: sihijos,
                          title: Text("Algun dia"),
                          onChanged: (bool value) {
                            sihijos = value;
                            nohijos = false;

                            tengoHijos = false;

                            Usuario.esteUsuario.hijos = 1;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: nohijos,
                          title: Text("Nunca"),
                          onChanged: (bool value) {
                            nohijos = value;

                            sihijos = false;
                            tengoHijos = false;

                            Usuario.esteUsuario.hijos = 2;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: tengoHijos,
                          title: Text("Tengo hijo(s)"),
                          onChanged: (bool value) {
                            tengoHijos = value;
                            sihijos = false;
                            nohijos = false;

                            Usuario.esteUsuario.hijos = 3;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Usuario.esteUsuario.notifyListeners();
                                },
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            );
  }
}

class EditorPolitica extends StatefulWidget {
  @override
  _EditorPoliticaState createState() => _EditorPoliticaState();
}

class _EditorPoliticaState extends State<EditorPolitica> {
  String valorMostrar;
  void valorUsuario() {
    if (Usuario.esteUsuario.politica == 1) {
      valorMostrar = "Derechas";
    }
    if (Usuario.esteUsuario.politica == 2) {
      valorMostrar = "Izquierdas";
    }
    if (Usuario.esteUsuario.politica == 3) {
      valorMostrar = "Centro";
    }

    if (Usuario.esteUsuario.politica == 4) {
      valorMostrar = "Apolitico";
    }
  }

  @override
  Widget build(BuildContext context) {
    valorUsuario();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.politica == 0
                  ? Colors.white
                  : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.landmark)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Politica")),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.politica == 0
                        ? "Responder"
                        : "$valorMostrar"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool derechas = false;
    bool izquierdas = false;
    bool centro = false;
    bool apolitico = false;

    if (Usuario.esteUsuario.politica == 0) {
      derechas = false;
      izquierdas = false;
      centro = false;
      apolitico = false;
    }
    if (Usuario.esteUsuario.politica == 1) {
      derechas = true;
    }
    if (Usuario.esteUsuario.politica == 2) {
      izquierdas = true;
    }
    if (Usuario.esteUsuario.politica == 3) {
      centro = true;
    }
    if (Usuario.esteUsuario.politica == 4) {
      apolitico = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
           builder:(context,child){
             return  ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Material(child: newMethod(derechas, izquierdas, apolitico, centro)),
            );
           
           }
          );
      },
    );
  }

  Consumer<Usuario> newMethod(bool derechas, bool izquierdas, bool apolitico, bool centro) {
    return Consumer<Usuario>(
              builder: (context, myType, child) {
                return Container(
                  height: ScreenUtil.screenHeight / 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: Row(
                              children: <Widget>[
                                Icon(LineAwesomeIcons.landmark),
                                Text(
                                  "Politica",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60)),
                                ),
                              ],
                            )),
                            FlatButton(
                                onPressed: () {
                                  Usuario.esteUsuario.politica = 0;
                                  Usuario.esteUsuario.notifyListeners();
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    Text("Borrar",
                                        style: TextStyle(color: Colors.red))
                                  ],
                                )),
                          ],
                        ),
                      ),
                      CheckboxListTile(
                          value: derechas,
                          title: Text("De Derechas"),
                          onChanged: (bool value) {
                            derechas = value;
                            izquierdas = false;
                            apolitico = false;
                            centro = false;

                            Usuario.esteUsuario.politica = 1;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: izquierdas,
                          title: Text("De Izquierdas"),
                          onChanged: (bool value) {
                            izquierdas = value;
                            apolitico = false;
                            derechas = false;
                            centro = false;

                            Usuario.esteUsuario.politica = 2;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: centro,
                          title: Text("De centro"),
                          onChanged: (bool value) {
                            centro = value;
                            derechas = false;
                            izquierdas = false;
                            apolitico = false;

                            Usuario.esteUsuario.politica = 3;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: apolitico,
                          title: Text("Apolitico"),
                          onChanged: (bool value) {
                            apolitico = value;
                            derechas = false;
                            izquierdas = false;
                            centro = false;

                            Usuario.esteUsuario.politica = 4;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Usuario.esteUsuario.notifyListeners();
                                },
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            );
  }
}

class ModificadorReligion extends StatefulWidget {
  @override
  _ModificadorReligionState createState() => _ModificadorReligionState();
}

class _ModificadorReligionState extends State<ModificadorReligion> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          color:
              Usuario.esteUsuario.religion == 0 ? Colors.white : Colors.green,
          height: ScreenUtil().setHeight(150),
          child: FlatButton(
            onPressed: () {},
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.church)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Religion")),
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.religion == 0
                        ? "Responder"
                        : "${Usuario.esteUsuario.religion}"))
              ],
            ),
          )),
    );
  }
}

class EditorVivirCon extends StatefulWidget {
  @override
  _EditorVivirConState createState() => _EditorVivirConState();
}

class _EditorVivirConState extends State<EditorVivirCon> {
  String valorMostrar;
  void valorUsuario() {
    if (Usuario.esteUsuario.vivoCon == 1) {
      valorMostrar = "Solo";
    }
    if (Usuario.esteUsuario.vivoCon == 2) {
      valorMostrar = "No Con padres";
    }
    if (Usuario.esteUsuario.vivoCon == 3) {
      valorMostrar = "Con amigos";
    }
  }

  @override
  Widget build(BuildContext context) {
    valorUsuario();

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.vivoCon == 0
                  ? Colors.white
                  : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(100),
          child: GestureDetector(
            onTap: () => modificarAtributo(context),
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.home)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Vivo con")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.vivoCon == 0
                        ? "Responder"
                        : "$valorMostrar"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;

    if (Usuario.esteUsuario.vivoCon == 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
    }

    if (Usuario.esteUsuario.vivoCon == 1) {
      vivirSolo = true;
    }
    if (Usuario.esteUsuario.vivoCon == 2) {
      vivirPadres = true;
    }
    if (Usuario.esteUsuario.vivoCon == 3) {
      vivirAmigos = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:(context,child){
            return ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Material(child: newMethod(vivirSolo, vivirPadres, vivirAmigos)));
          }
         
        );
      },
    );
  }

  Consumer<Usuario> newMethod(bool vivirSolo, bool vivirPadres, bool vivirAmigos) {
    return Consumer<Usuario>(
              builder: (context, myType, child) {
                return Container(
                  height: ScreenUtil.screenHeight / 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: Row(
                              children: <Widget>[
                                Icon(LineAwesomeIcons.baby),
                                Text(
                                  "Vivo con",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60)),
                                ),
                              ],
                            )),
                            FlatButton(
                                onPressed: () {
                                  Usuario.esteUsuario.vivoCon = 0;
                                  Usuario.esteUsuario.notifyListeners();
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    Text("Borrar",
                                        style: TextStyle(color: Colors.red))
                                  ],
                                )),
                          ],
                        ),
                      ),
                      CheckboxListTile(
                          value: vivirSolo,
                          title: Text("Solo"),
                          onChanged: (bool value) {
                            vivirSolo = value;
                            vivirPadres = false;

                            vivirAmigos = false;

                            Usuario.esteUsuario.vivoCon = 1;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: vivirPadres,
                          title: Text("Con mis padres"),
                          onChanged: (bool value) {
                            vivirPadres = value;

                            vivirSolo = false;
                            vivirAmigos = false;

                            Usuario.esteUsuario.vivoCon = 2;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      CheckboxListTile(
                          value: vivirAmigos,
                          title: Text("Con amigos"),
                          onChanged: (bool value) {
                            vivirAmigos = value;
                            vivirSolo = false;
                            vivirPadres = false;

                            Usuario.esteUsuario.vivoCon = 3;
                            Usuario.esteUsuario.notifyListeners();
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Usuario.esteUsuario.notifyListeners();
                                },
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            );
  }
}

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
          height: ScreenUtil().setHeight(150),
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
