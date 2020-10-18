import 'dart:io';

import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_methods.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:drag_and_drop_gridview/drag.dart';
import 'package:drag_and_drop_gridview/gridorbiter.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

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
                           boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 10),],
                          borderRadius:BorderRadius.all(Radius.circular(20))
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
            fit: FlexFit.tight,
                                    child: LayoutBuilder(builder: (BuildContext context, BoxConstraints limites){

                    return  Container(
                   
                    width:  limites.maxHeight,
                    decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(
                             Usuario.esteUsuario.fotosUsuarioActualizar[0]
                              ))),
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
                             
                             child: Text(
                               "${Usuario.esteUsuario.nombre}, ${Usuario.esteUsuario.edad}",
                               style: TextStyle(fontSize: 50.sp),
                             ),
                           ),
                             
          Container(
            
            width: 600.w,
            child: GestureDetector(
              onTap: () {
                Usuario.esteUsuario=Usuario.esteUsuario;
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
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

class _BotonesTiendaAplicacionState extends State<BotonesTiendaAplicacion> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          flex: 2,
          fit:FlexFit.tight,

                    child: Container(
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            height: 100.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Hazte Premium"),
                Icon(LineAwesomeIcons.google_plus),
              ],
            ),
          ),
        ),
       
        Flexible(
            flex: 8,
          fit:FlexFit.tight,
                    child: Container(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2/1,
              children: [
                Container(
                  child: Center(
                      child: Column(
                    children: [
                      Icon(
                        Icons.videocam,
                        size: 120.sp,
                      ),
                      Text("Minutos de video")
                    ],
                  )),
                ),
                       Container(
              child: Center(
                  child: Column(
                children: [
                  Icon(
                    LineAwesomeIcons.coins,
                    size: 120.sp,
                  ),
                  Text("Creditos")
                ],
              )),
            ),
     
            Container(
              child: Center(
                  child: Column(
                children: [
                  Icon(
                    Icons.remove_red_eye,
                    size: 120.sp,
                  ),
                  Text("Revelaciones")
                ],
              )),
            ),
            Container(
              child: Center(
                  child: Column(
                children: [
                  Icon(
                    LineAwesomeIcons.rocket,
                    size: 120.sp,
                  ),
                  Text("Visitas")
                ],
              )),
            ),
      ],
    ),
          ),
        ),
    
          ],
        );
   
  }
}

class PantallaEdicionPerfil extends StatefulWidget {
  static List<String> listaDeImagenesUsuario = [
    Usuario.esteUsuario.ImageURL1["Imagen"],
    Usuario.esteUsuario.ImageURL2["Imagen"],
    Usuario.esteUsuario.ImageURL3["Imagen"],
    Usuario.esteUsuario.ImageURL4["Imagen"],
    Usuario.esteUsuario.ImageURL5["Imagen"],
    Usuario.esteUsuario.ImageURL6["Imagen"],
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
      onWillPop: ()async{
        
 Usuario.esteUsuario.editarPerfilUsuario(Usuario.esteUsuario.idUsuario);
print("saliendo");
return true;







        
   
        

      },
          child: ChangeNotifierProvider.value(
        value: Usuario.esteUsuario,
        
         
            child:  
            Consumer<Usuario>(
              builder: (context, myType, child) {
                return  Material(
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              resizeToAvoidBottomPadding: true,
              appBar: AppBar(
                
                title: Text("Edita tu perfil"),
              ),
              body:  Container(
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
                            height: 1200.h,
                            child: DragAndDropGridView(
                              dragStartBehavior: DragStartBehavior.start,
                              isCustomChildWhenDragging: false,
                              physics: NeverScrollableScrollPhysics(),
                              onReorder: (indiceViejo, indiceNuevo) {
                                setState(() {
                                  if (Usuario.esteUsuario
                                          .fotosUsuarioActualizar[indiceViejo] !=
                                      null) {
                                    File temporal = Usuario.esteUsuario
                                        .fotosUsuarioActualizar[indiceNuevo];
                                    Usuario.esteUsuario
                                            .fotosUsuarioActualizar[indiceNuevo] =
                                        Usuario.esteUsuario
                                            .fotosUsuarioActualizar[indiceViejo];
                                    Usuario.esteUsuario
                                            .fotosUsuarioActualizar[indiceViejo] =
                                        temporal;
                                  }

                                  pos = null;
                                });
                              },
                              onWillAccept: (indiceViejo, indiceNuevo) {
                                setState(() {
                                  pos = indiceNuevo;
                                });

                                if (Usuario.esteUsuario
                                        .fotosUsuarioActualizar[indiceNuevo] !=
                                    null) {
                                  return true;
                                } else {
                                  return false;
                                }
                              },
                              controller: PantallaEdicionPerfil.controladorScroll,
                              itemCount: Usuario
                                  .esteUsuario.fotosUsuarioActualizar.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1 / 1.60,
                              ),
                              itemBuilder: (context, indice) {
                                return Opacity(
                                  opacity:
                                      pos != null ? pos == indice ? 0.4 : 1 : 1,
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
                          EditorNombre(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Edad"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  BotonNacimiento(
                                      Usuario.esteUsuario.fechaNacimiento),
                                  MostradorEdad(Usuario.esteUsuario.edad),
                                ],
                              ),
                            ],
                          ),
                          EditorDescripcion(),
                          BotonEdicionPreguntasUsuario(),
                        
                            
                              ListaDeCaracteristicasUsuarioEditar(),
                          
                        ],
                      ),
                    ]),
                  ),
                ),
              ) ,
              
            ),
          ),
        )  ;
              },
            )
            
           
        
        
        
        
       
      ),
    );
  }
}

class BotonEdicionPreguntasUsuario extends StatefulWidget {
  @override
  _BotonEdicionPreguntasUsuarioState createState() =>
      _BotonEdicionPreguntasUsuarioState();
}

class _BotonEdicionPreguntasUsuarioState
    extends State<BotonEdicionPreguntasUsuario> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return PantallaEdicionPreguntas();
          }));
        },
        child: Container(
          width: ScreenUtil.screenWidth,
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.altura == null
                  ? Colors.white
                  : Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: ScreenUtil().setHeight(150),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Preguntas sobre ti",
                style: TextStyle(fontSize: 60.sp),
              ),
              Text(
                "${Usuario.esteUsuario.preguntasContestadas}/3",
                style: TextStyle(fontSize: 60.sp),
              ),
            ],
          )),
        ));
  }
}

class ListaDeCaracteristicasUsuarioEditar extends StatefulWidget {
  @override
  _ListaDeCaracteristicasUsuarioEditarState createState() =>
      _ListaDeCaracteristicasUsuarioEditarState();
}

class _ListaDeCaracteristicasUsuarioEditarState
    extends State<ListaDeCaracteristicasUsuarioEditar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*Text("Trabajo y Formacion"),
            ModificadorFormacion(),
            ModificadorTrabajo(),*/
            Divider(
              height: ScreenUtil().setHeight(100),
            ),
            Text(
              "Caracteristicas",
              style: TextStyle(fontSize: 60.sp, fontWeight: FontWeight.bold),
            ),
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
        ));
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
        ));
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
          Usuario.esteUsuario.nombre=val;

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
    controladorEditorDescripcion.text =
        Usuario.esteUsuario.observaciones;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        maxLines: 5,
        controller:controladorEditorDescripcion,
        decoration: InputDecoration(
            labelText: "Descripcion",
            floatingLabelBehavior: FloatingLabelBehavior.always),
        onChanged: (val) {

          Usuario.esteUsuario.observaciones=val;
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
  
        return  Padding(
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
                      child: Text(Usuario.esteUsuario.altura == null
                          ? "Responder"
                          : "${Usuario.esteUsuario.altura.toStringAsFixed(2)} m",))
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
          return    Provider<Usuario>(
            create: (_)=>Usuario.esteUsuario,
            builder: (context,child){
              return   ChangeNotifierProvider.value(
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
                                  style: TextStyle(fontSize: ScreenUtil().setSp(60)),
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
                          return  Slider(
                            min: 1.0,
                            max: 2.5,
                            value: altura,
                            onChanged: (value) {
                              setState(() {
                                Usuario.esteUsuario.altura=value;
                                 altura = value;
                                
                              });
                             
                                   print(value);
                             
                              Usuario.esteUsuario.notifyListeners();
                                
                             
                           
                            }) ;
                        },
                      )
                     ,
                      Consumer<Usuario>(

                        builder: (context, myType, child) {
                          return  Text(
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
                              borderRadius: BorderRadius.all(Radius.circular(3)),
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

class EditorComplexion extends StatefulWidget {
  @override
  _EditorComplexionState createState() => _EditorComplexionState();
}

class _EditorComplexionState extends State<EditorComplexion> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.complexion == null
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
                    child: Text(Usuario.esteUsuario.complexion == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.complexion}"))
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


    if (Usuario.esteUsuario.complexion == null) {
      atletico = false;
      normal = false;
      kiloDeMas = false;
      musculosa = false;
      tallaGrande = false;
      delgada = false;
    }
    if (Usuario.esteUsuario.complexion == "Normal") {
      normal = true;
    }
    if (Usuario.esteUsuario.complexion == "Atletico") {
      atletico = true;
    }
    if (Usuario.esteUsuario.complexion == "Musculosa") {
      musculosa = true;
    }
    if (Usuario.esteUsuario.complexion == "Kilitos de mas") {
      kiloDeMas = true;
    }
    if (Usuario.esteUsuario.complexion == "Talla Grande") {
      tallaGrande = true;
    }
    if (Usuario.esteUsuario.complexion == "Delgado") {
      delgada = true;
    }

    showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (context) {
          return SafeArea(
                      child: Provider<Usuario>(
              create: (_)=>Usuario.esteUsuario,
              builder: (context,child){

                return  ChangeNotifierProvider.value(
                  value:Usuario.esteUsuario,
                                child:  cuerpo(context, normal, atletico, kiloDeMas, musculosa, tallaGrande, delgada),
                   
                );
                
                
              
              },
                      
            ),
          );
        });
  }

  Container cuerpo(BuildContext context, bool normal, bool atletico, bool kiloDeMas, bool musculosa, bool tallaGrande, bool delgada) {
    return Container(
            height: ScreenUtil.screenHeight/5,
            child: 
            Consumer<Usuario>(
              builder: (context, myType, child) {
                return          Column(
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
                      Usuario.esteUsuario.notifyListeners();
                      atletico = false;
                      print(Usuario.esteUsuario.complexion);

                      kiloDeMas = false;
                      musculosa = false;
                      tallaGrande = false;
                      delgada = false;
                      Usuario.esteUsuario.complexion = "Normal";
                      
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
                      Usuario.esteUsuario.complexion = "Atletica";
                      Usuario.esteUsuario.notifyListeners();
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
                      Usuario.esteUsuario.complexion = "Musculosa";
                      Usuario.esteUsuario.notifyListeners();
                    }),
                CheckboxListTile(
                    value: kiloDeMas,
                    title: Text("Kilitos de mas"),
                    onChanged: (bool value) {
                      kiloDeMas = value;
                      atletico = false;
                      normal = false;

                      musculosa = false;
                      tallaGrande = false;
                      delgada = false;
                      Usuario.esteUsuario.complexion = "Kilitos de mas";
                      Usuario.esteUsuario.notifyListeners();
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
                      Usuario.esteUsuario.complexion = "Talla Grande";
                      Usuario.esteUsuario.notifyListeners();
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
                      Usuario.esteUsuario.complexion = "Delgado";

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
            ) ;
              },
            )
            
    
          );
  }
}

class ModificadorFormacion extends StatefulWidget {
  @override
  _ModificadorFormacionState createState() => _ModificadorFormacionState();
}

class _ModificadorFormacionState extends State<ModificadorFormacion> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          color: Usuario.esteUsuario.formacion == null
              ? Colors.white
              : Colors.green,
          height: ScreenUtil().setHeight(200),
          child: FlatButton(
            onPressed: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Icon(LineAwesomeIcons.graduation_cap)),
                    Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Text(
                          "Formacion",
                          style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                        )),
                    Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Text(Usuario.esteUsuario
                                    .formacion["entidad formadora"] ==
                                null
                            ? "Responder"
                            : "${Usuario.esteUsuario.formacion["entidad formadora"]}"))
                  ],
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Text("Donde te formaste")),
                    Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Text(Usuario.esteUsuario
                                    .formacion["entidad formadora"] ==
                                null
                            ? ""
                            : "${Usuario.esteUsuario.formacion["entidad formadora"]}"))
                  ],
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Text("En que te formaste")),
                    Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Text(Usuario
                                    .esteUsuario.formacion["formacion"] ==
                                null
                            ? ""
                            : "${Usuario.esteUsuario.formacion["entidad formadora"]}"))
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class ModificadorTrabajo extends StatefulWidget {
  @override
  _ModificadorTrabajoState createState() => _ModificadorTrabajoState();
}

class _ModificadorTrabajoState extends State<ModificadorTrabajo> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          color:
              Usuario.esteUsuario.trabajo == null ? Colors.white : Colors.green,
          height: ScreenUtil().setHeight(200),
          child: FlatButton(
            onPressed: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Icon(LineAwesomeIcons.suitcase)),
                    Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Text(
                          "Trabajo",
                          style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                        )),
                    Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Text(Usuario
                                    .esteUsuario.trabajo["lugar trabajo"] ==
                                null
                            ? "Responder"
                            : "${Usuario.esteUsuario.trabajo["lugar trabajo"]}"))
                  ],
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Text("Trabaja en")),
                    Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Text(Usuario
                                    .esteUsuario.formacion["lugar trabajo"] ==
                                null
                            ? ""
                            : "${Usuario.esteUsuario.trabajo["lugar trabajo"]}"))
                  ],
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                        flex: 10, fit: FlexFit.tight, child: Text("Puesto")),
                    Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Text(
                            Usuario.esteUsuario.trabajo["puesto"] == null
                                ? ""
                                : "${Usuario.esteUsuario.formacion["puesto"]}"))
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class EditorAlcohol extends StatefulWidget {
  @override
  _EditorAlcoholState createState() => _EditorAlcoholState();
}

class _EditorAlcoholState extends State<EditorAlcohol> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.alcohol == null
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
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.alcohol == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.alcohol}"))
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

    if (Usuario.esteUsuario.alcohol == null) {
      sociedad = false;
      noBebo = false;
      beboMucho = false;

      enContraDeLaBebida = false;
    }
    if(Usuario.esteUsuario.alcohol=="En Sociedad"){
      sociedad=true;
    }
     if(Usuario.esteUsuario.alcohol=="No Bebo"){
      noBebo=true;
    }
     if(Usuario.esteUsuario.alcohol=="Bebo mucho"){
      beboMucho=true;
    }
     if(Usuario.esteUsuario.alcohol=="En Contra del Alcohol"){
      enContraDeLaBebida=true;
    }
    

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Provider<Usuario>(
            create: (_)=>Usuario.esteUsuario,
                      child: ChangeNotifierProvider.value(
                        value: Usuario.esteUsuario,
                        
                                              child: Container(
              height: ScreenUtil.screenHeight / 7,
              child: cuerpo(context, sociedad, noBebo, beboMucho, enContraDeLaBebida),
            ),
                      ),
          );
        });
  }

  Consumer cuerpo(BuildContext context, bool sociedad, bool noBebo, bool beboMucho, bool enContraDeLaBebida) {
    return Consumer<Usuario>(
      builder: (context, myType, child) {
        return  Column(
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
                            Text("Borrar",
                                style: TextStyle(color: Colors.red))
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

                    Usuario.esteUsuario.alcohol = "En Sociedad";
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

                    Usuario.esteUsuario.alcohol = "No Bebo";
                    Usuario.esteUsuario.notifyListeners();
                  }),
              CheckboxListTile(
                  value: beboMucho,
                  title: Text("Bebo mucho"),
                  onChanged: (bool value) {
                    beboMucho = value;
                    sociedad = false;
                    noBebo = false;

                    enContraDeLaBebida = false;

                    Usuario.esteUsuario.alcohol = "Bebo Mucho";
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

                    Usuario.esteUsuario.alcohol = "Odio el Alcohol";
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
          ) ;
      },
    );
    
    
   
  }
}

class EditorTabaco extends StatefulWidget {
  @override
  _EditorTabacoState createState() => _EditorTabacoState();
}

class _EditorTabacoState extends State<EditorTabaco> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.tabaco == null
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
                    child: Icon(LineAwesomeIcons.smoking)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Tabaco")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.tabaco == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.tabaco}"))
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

    if (Usuario.esteUsuario.tabaco == null) {
      fumo = false;
      noFumo = false;
      fumoSociedad = false;

      odioTabaco = false;
    }
     if(Usuario.esteUsuario.tabaco=="Fumo"){
      fumo=true;
    }
    if(Usuario.esteUsuario.tabaco=="No Fumo"){
      noFumo=true;
    }
    if(Usuario.esteUsuario.tabaco=="Fumador Social"){
      fumoSociedad=true;
    }
    if(Usuario.esteUsuario.tabaco=="Odio el Tabaco"){
      odioTabaco=true;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Provider<Usuario>(
create: (_)=>Usuario.esteUsuario,
                  child: ChangeNotifierProvider.value(
                    value: Usuario.esteUsuario,
                    child: Container(
            height: ScreenUtil.screenHeight / 7,
            child: cuerpo(context, fumo, noFumo, fumoSociedad, odioTabaco),
          ),
                  ),
        );
      },
    );
  }

  Consumer cuerpo(BuildContext context, bool fumo, bool noFumo, bool fumoSociedad, bool odioTabaco) {
    return Consumer<Usuario>(
      builder: (context, myType, child) {
        return     Column(
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
                        Usuario.esteUsuario.tabaco = null;
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

                  Usuario.esteUsuario.tabaco = "Fumo";
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

                  Usuario.esteUsuario.tabaco = "No Fumo";
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

                  Usuario.esteUsuario.tabaco = "Fumador Social";
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

                  Usuario.esteUsuario.tabaco = "Odio el Tabaco";
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
        ) ;
      },
    );
    
    

  }
}

class ModificadorIdiomas extends StatefulWidget {
  @override
  _ModificadorIdiomasState createState() => _ModificadorIdiomasState();
}

class _ModificadorIdiomasState extends State<ModificadorIdiomas> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          color:
              Usuario.esteUsuario.idiomas == null ? Colors.white : Colors.green,
          height: ScreenUtil().setHeight(150),
          child: FlatButton(
            onPressed: () {},
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.language)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Idiomas")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.idiomas == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.idiomas}"))
              ],
            ),
          )),
    );
  }
}

class EditorMascotas extends StatefulWidget {
  @override
  _EditorMascotasState createState() => _EditorMascotasState();
}

class _EditorMascotasState extends State<EditorMascotas> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.mascotas == null
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
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.mascotas == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.mascotas}"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool perro = false;
    bool gato = false;
    bool nunca = false;
    bool varias = false;
    bool otras = false;
    bool meGustaria = false;

    if (Usuario.esteUsuario.mascotas == null) {
      perro = false;
      gato = false;
      nunca = false;
      varias = false;
      otras = false;
      meGustaria = false;
    }
    if (Usuario.esteUsuario.mascotas == "Perro") {
      perro = true;
    }
    if (Usuario.esteUsuario.mascotas == "Gato") {
      gato = true;
    }
    if (Usuario.esteUsuario.mascotas == "Nunca") {
      nunca = true;
    }
    if (Usuario.esteUsuario.mascotas == "Me Gustaria") {
      meGustaria = true;
    }
    if (Usuario.esteUsuario.mascotas == "Otras (Preguntame)") {
      otras = true;
    }
    if (Usuario.esteUsuario.mascotas == "Varias") {
      varias = true;
    }
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Provider<Usuario>(
          create: (_)=>Usuario.esteUsuario,
                  child: ChangeNotifierProvider.value(
                    value: Usuario.esteUsuario,
                                      child:
                                      
                                      
                                      Consumer<Usuario>(
                                        builder: (context, myType, child) {
                                          return Container(
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
                              style: TextStyle(fontSize: ScreenUtil().setSp(60)),
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
                                Text("Borrar", style: TextStyle(color: Colors.red))
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
                        varias = false;
                        nunca = false;
                        otras = false;
                        meGustaria = false;

                        Usuario.esteUsuario.mascotas = "Perro";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: gato,
                      title: Text("Gato"),
                      onChanged: (bool value) {
                        gato = value;
                        varias = false;
                        perro = false;
                        nunca = false;
                        otras = false;
                        meGustaria = false;

                        Usuario.esteUsuario.mascotas = "Gato";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: nunca,
                      title: Text("Nunca"),
                      onChanged: (bool value) {
                        nunca = value;
                        perro = false;
                        gato = false;
                        otras = false;
                        meGustaria = false;
                        varias = false;

                        Usuario.esteUsuario.mascotas = "Nunca";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: meGustaria,
                      title: Text("Me Gustaria"),
                      onChanged: (bool value) {
                        meGustaria = value;
                        perro = false;
                        gato = false;
                        otras = false;
                        nunca = false;
                        varias = false;

                        Usuario.esteUsuario.mascotas = "Me Gustaria";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: otras,
                      title: Text("Otras (Preguntame)"),
                      onChanged: (bool value) {
                        otras = value;
                        meGustaria = false;
                        perro = false;
                        gato = false;

                        varias = false;

                        nunca = false;

                        Usuario.esteUsuario.mascotas = "Otras";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: varias,
                      title: Text("Varias"),
                      onChanged: (bool value) {
                        varias = value;
                        meGustaria = false;
                        perro = false;
                        gato = false;
                        otras = false;
                        nunca = false;

                        Usuario.esteUsuario.mascotas = "Varias";
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
            ),
          ) ;
                                        },
                                      ) 
                  ),
        );
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.busco == null
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
                    child: Icon(LineAwesomeIcons.heart)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Busco")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.busco == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.busco}"))
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

    if (Usuario.esteUsuario.mascotas == null) {
      relacionSeria = false;
      loQueSurja = false;
      casual = false;
      noLoSe = false;
    }

    if (Usuario.esteUsuario.busco == "Relacion seria") {
      relacionSeria = true;
    }
    if (Usuario.esteUsuario.busco == "Lo que surja") {
      loQueSurja = true;
    }
    if (Usuario.esteUsuario.busco == "Casual") {
      casual = true;
    }
    if (Usuario.esteUsuario.busco == "No se") {
      noLoSe = true;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Provider<Usuario>(
          create:(_)=>Usuario.esteUsuario,
                  child: ChangeNotifierProvider.value(
                    value: Usuario.esteUsuario,

                                      child:
                                      Consumer<Usuario>(
                                        builder: (context, myType, child) {
                                          return  Container(
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
                              style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              Usuario.esteUsuario.busco = null;
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
                      value: relacionSeria,
                      title: Text("Relacion seria"),
                      onChanged: (bool value) {
                        relacionSeria = value;
                        loQueSurja = false;
                        noLoSe = false;
                        casual = false;

                        Usuario.esteUsuario.busco = "Relacion seria";
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

                        Usuario.esteUsuario.busco = "Lo que surja";
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

                        Usuario.esteUsuario.busco = "Casual";
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

                        Usuario.esteUsuario.busco = "No se";
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
            ),
          ) ;
                                        },
                                      )
                                      
                                      
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.hijos == null
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
                    child: Icon(LineAwesomeIcons.baby)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Hijos")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.hijos == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.hijos}"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool sihijos = false;
    bool nohijos = false;
    bool tengoHijos = false;

    if (Usuario.esteUsuario.hijos == null) {
      sihijos = false;
      nohijos = false;
      tengoHijos = false;
    }
    if(Usuario.esteUsuario.hijos=="Algun dia"){
      sihijos=true;
    }
    if(Usuario.esteUsuario.hijos=="Nunca"){
      nohijos=true;
    }
    if(Usuario.esteUsuario.hijos=="Tengo hijo(s)"){
      tengoHijos=true;
    }



    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Provider<Usuario>(
          create: (_)=>Usuario.esteUsuario,

                  child: ChangeNotifierProvider.value(
                    value:Usuario.esteUsuario,
                    child: Consumer<Usuario>(
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
                              style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              Usuario.esteUsuario.hijos = null;
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
                      value: sihijos,
                      title: Text("Algun dia"),
                      onChanged: (bool value) {
                        sihijos = value;
                        nohijos = false;

                        tengoHijos = false;

                        Usuario.esteUsuario.hijos = "Algun dia";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: nohijos,
                      title: Text("Nunca"),
                      onChanged: (bool value) {
                        nohijos = value;

                        sihijos = false;
                        tengoHijos = false;

                        Usuario.esteUsuario.hijos = "Nunca";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: tengoHijos,
                      title: Text("Tengo hijo(s)"),
                      onChanged: (bool value) {
                        tengoHijos = value;
                        sihijos = false;
                        nohijos = false;

                        Usuario.esteUsuario.hijos = "Tengo hijo(s)";
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
            ),
          ) ;
                      },
                    )
                    
                    
                    
                  ),
        );
      },
    );
  }
}

class ModificadorZodiaco extends StatefulWidget {
  @override
  _ModificadorZodiacoState createState() => _ModificadorZodiacoState();
}

class _ModificadorZodiacoState extends State<ModificadorZodiaco> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          color:
              Usuario.esteUsuario.zodiaco == null ? Colors.white : Colors.green,
          height: ScreenUtil().setHeight(150),
          child: FlatButton(
            onPressed: () {},
            child: Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(LineAwesomeIcons.star_of_david)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Zodiaco")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.zodiaco == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.zodiaco}"))
              ],
            ),
          )),
    );
  }
}

class EditorPolitica extends StatefulWidget {
  @override
  _EditorPoliticaState createState() => _EditorPoliticaState();
}

class _EditorPoliticaState extends State<EditorPolitica> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.politica == null
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
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.politica == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.politica}"))
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

    if (Usuario.esteUsuario.politica == null) {
      derechas = false;
      izquierdas = false;
      centro = false;
      apolitico = false;
    }
     if(Usuario.esteUsuario.politica=="De Derechas"){
      derechas=true;
    }
     if(Usuario.esteUsuario.politica=="De Izquierdas"){
      izquierdas=true;
    }
     if(Usuario.esteUsuario.politica=="De centro"){
      centro=true;
    }
     if(Usuario.esteUsuario.politica=="Apolitico"){
      apolitico=true;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Provider<Usuario>(
          create: (_)=>Usuario.esteUsuario,
                  child: 
                  ChangeNotifierProvider.value(
                    value: Usuario.esteUsuario,
                                      child: Consumer<Usuario>(
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
                              style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              Usuario.esteUsuario.politica = null;
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
                      value: derechas,
                      title: Text("De Derechas"),
                      onChanged: (bool value) {
                        derechas = value;
                        izquierdas = false;
                        apolitico = false;
                        centro = false;

                        Usuario.esteUsuario.politica = "Derechas";
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

                        Usuario.esteUsuario.politica = "Izquierdas";
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

                        Usuario.esteUsuario.politica = "Centro";
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

                        Usuario.esteUsuario.politica = "Apolitico";
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
            ),
          ) ;
                      },
                    ),
                  )
                  
                  
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
          color: Usuario.esteUsuario.religion == null
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
                    child: Icon(LineAwesomeIcons.church)),
                Flexible(flex: 10, fit: FlexFit.tight, child: Text("Religion")),
                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Text(Usuario.esteUsuario.religion == null
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Container(
          decoration: BoxDecoration(
              color: Usuario.esteUsuario.vivoCon == null
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
                    child: Text(Usuario.esteUsuario.vivoCon == null
                        ? "Responder"
                        : "${Usuario.esteUsuario.vivoCon}"))
              ],
            ),
          )),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;

    if (Usuario.esteUsuario.vivoCon == null) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
    }

    if(Usuario.esteUsuario.vivoCon=="Solo"){
      vivirSolo=true;
    }
     if(Usuario.esteUsuario.vivoCon=="Con mis padres"){
      vivirPadres=true;
    }
     if(Usuario.esteUsuario.vivoCon=="Con amigos"){
      vivirAmigos=true;
    }


    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Provider<Usuario>(
          create: (_)=>Usuario.esteUsuario,
                  child: ChangeNotifierProvider.value(
                    value: Usuario.esteUsuario,

                                      child: Consumer<Usuario>(
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
                              style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              Usuario.esteUsuario.vivoCon = null;
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
                      value: vivirSolo,
                      title: Text("Solo"),
                      onChanged: (bool value) {
                        vivirSolo = value;
                        vivirPadres = false;

                        vivirAmigos = false;

                        Usuario.esteUsuario.vivoCon = "Solo";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: vivirPadres,
                      title: Text("Con mis padres"),
                      onChanged: (bool value) {
                        vivirPadres = value;

                        vivirSolo = false;
                        vivirAmigos = false;

                        Usuario.esteUsuario.vivoCon = "Con padres";
                        Usuario.esteUsuario.notifyListeners();
                      }),
                CheckboxListTile(
                      value: vivirAmigos,
                      title: Text("Con amigos"),
                      onChanged: (bool value) {
                        vivirAmigos = value;
                        vivirSolo = false;
                        vivirPadres = false;

                        Usuario.esteUsuario.vivoCon = "Con amigos";
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
            ),
          ) ;
                                        },
                                      )
                                      
                                      
                                       
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

class PantallaEdicionPreguntas extends StatefulWidget {
  static int preguntasRestantes = 3;

  @override
  _PantallaEdicionPreguntasState createState() =>
      _PantallaEdicionPreguntasState();
}

class _PantallaEdicionPreguntasState extends State<PantallaEdicionPreguntas> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,
          child: SafeArea(
       
        
          child: Material(
                      child: Container(
                color: Colors.white,
                child:Consumer<Usuario>(
                  builder: (context, myType, child) {
                    return         Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                              height: ScreenUtil().setHeight(100),
                              child: Center(
                                  child: Text(
                                Usuario.esteUsuario.preguntasContestadas != 0
                                    ? 
                                    
                                    "Elige ${Usuario.esteUsuario.preguntasContestadas} Preguntas Personales"
                                    : "Has respondido el maximo",
                                style: TextStyle(fontSize: ScreenUtil().setSp(55)),
                              ))),
                             
                          Container(
                            height: ScreenUtil().setHeight(1600),
                            child: ListView.builder(
                              itemCount: Usuario.listaPreguntasPersonales.length,
                              itemBuilder: (BuildContext context, int indice) {
                                return PreguntaUsuario(
                                    preguntaUsuario: Usuario.listaPreguntasPersonales[indice],
                                    respuestaUsuario: Usuario.esteUsuario
                                        .listaRespuestasPreguntasPersonales[indice],
                                    indicePregunta: indice);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Colors.red),
                          height: ScreenUtil().setHeight(100),
                          child: FlatButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Atras"))),
                    ),
                  ],
                );
                  },
                )
                
                
                
                
       ),
          ),
      
      ),
    );
  }
}
