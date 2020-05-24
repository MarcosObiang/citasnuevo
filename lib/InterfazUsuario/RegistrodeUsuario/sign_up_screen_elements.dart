import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/pantalla_actividades_elements.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'sign_up_methods.dart';
import '../../main.dart';
import 'sign_up_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
        child: text_black());
  }

  Widget text_black() {
    if (texto_oscuro) {
      aux = true;
      return Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 10,
            child: Container(
              child: TextField(
                obscureText: invisible,
                maxLines: lineas,
                maxLength: caracteres,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 0),
                  counter: Offstage(),
                  labelText: "$nombre_campo",
                  labelStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: ScreenUtil().setSp(60)),
                  icon: icon,
                ),
                onChanged: (String val) {
                  setState(() {
                    if (indice == 0) {
                      Usuario.esteUsuario.nombre = val;
                    }
                    if (indice == 1) {
                      Usuario.esteUsuario.alias = val;
                    }
                    if (indice == 2) {
                      Usuario.esteUsuario.clave = val;
                    }
                    if (indice == 3) {
                      Usuario.esteUsuario.confirmar_clave = val;
                    }
                    if (indice == 4) {
                      Usuario.esteUsuario.email = val;
                      print(val);
                    }
                  });
                },
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: Container(
              color: Colors.transparent,
              child: RaisedButton(
                color: Colors.white,
                elevation: 0,
                onPressed: (() {
                  setState(() {
                    if (invisible == true && aux) {
                      invisible = false;
                      aux = false;
                      print("Visible");
                    }

                    if (invisible == false && aux) {
                      invisible = true;
                      print("innVisible");
                    }
                  });
                }),
                child: Container(
                  child: Icon(
                    Icons.remove_red_eye,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return TextField(
        maxLines: lineas,
        maxLength: caracteres,
        textInputAction: TextInputAction.done,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 0),
          counter: Offstage(),
          labelText: "$nombre_campo",
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
            if (indice == 1) {
              Usuario.esteUsuario.alias = val;
            }
            if (indice == 2) {
              Usuario.esteUsuario.clave = val;
            }
            if (indice == 3) {
              Usuario.esteUsuario.confirmar_clave = val;
            }
            if (indice == 4) {
              Usuario.esteUsuario.email = val;
            }
            if (indice == 5) {
              Usuario.esteUsuario.observaciones = val;
            }
            if (indice == 6) {
              Usuario.esteUsuario.ImageURL1["PieDeFoto"] = val;
            }
            if (indice == 7) {
              Usuario.esteUsuario.ImageURL2["PieDeFoto"] = val;
            }
            if (indice == 8) {
              Usuario.esteUsuario.ImageURL3["PieDeFoto"] = val;
              print(val);
            }
            if (indice == 9) {
              Usuario.esteUsuario.ImageURL4["PieDeFoto"] = val;
            }
            if (indice == 10) {
              Usuario.esteUsuario.ImageURL5["PieDeFoto"] = val;
            }
            if (indice == 11) {
              Usuario.esteUsuario.ImageURL6["PieDeFoto"] = val;
            }
          });
        },
      );
    }
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
          height: ScreenUtil().setHeight(100),
          width: ScreenUtil().setWidth(750),
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
                  }

                  print(data);
                  return data;
                });
              });
            },
            child: Text(
              date == null ? "Fecha de Nacimimento" : f.format(widget.dato),
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(60),
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
        SizedBox(
          width: ScreenUtil().setWidth(400),
          height: ScreenUtil().setHeight(120),
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
  ///Aqui creamos el la variable seleccionado de tipo item, que servirá como caché de lo que haya seleccionado el usuario para asi despues acceder
  ///a su propiedad name para asi saber el sexo que ha elegido el usuario
  item seleccionado;

  /// Aqui creamos una lista de tipo item que contiene los objetos que se muestran en el menu desplegable "Sexo"
  List<item> items = <item>[
    item(Icon(LineAwesomeIcons.male), CampoSexo.hombre,
        Icon(LineAwesomeIcons.mars)),
    item(Icon(LineAwesomeIcons.female), CampoSexo.mujer,
        Icon(LineAwesomeIcons.venus)),
  ];

  ///Este metodo dependiendo de la propiedad name de item al ser llamado asigna al usuario un sexo
  void Sexo() {
    if (seleccionado.name == CampoSexo.hombre) {
      Usuario.esteUsuario.sexo = "Hombre";
    }
    if (seleccionado.name == CampoSexo.mujer) {
      Usuario.esteUsuario.sexo = "Mujer";
    } else {
      return null;
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            CampoSexo.nombreCampo,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3))),

          ///Aqui se despliega el menu descendente
          child: DropdownButton<item>(
            value: seleccionado,
            iconSize: ScreenUtil().setSp(60),
            elevation: 0,
            onChanged: (item newvalue) {
              setState(() {
                seleccionado = newvalue;
                if (seleccionado.name != null) {
                  Sexo();
                }
              });
            },
            items: items.map<DropdownMenuItem<item>>((item value) {
              return DropdownMenuItem<item>(
                value: value,
                child: Row(
                  children: <Widget>[
                    value.first_icon,
                    Text(
                      value.name,
                    ),
                    value.second_icon
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
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

class campoPreferenciaSexual extends StatefulWidget {
  static String nombreCampo = "Prefiero";
  static String hombre = "Hombre";
  static String mujer = "Mujer";
  static String bisexual = "Ambos";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return campoPreferenciaSexualState();
  }
}

class campoPreferenciaSexualState extends State<campoPreferenciaSexual> {
  item selected;

  List<item> items = <item>[
    item(Icon(LineAwesomeIcons.male), campoPreferenciaSexual.hombre,
        Icon(LineAwesomeIcons.mars)),
    item(Icon(LineAwesomeIcons.female), campoPreferenciaSexual.mujer,
        Icon(LineAwesomeIcons.venus)),
    item(Icon(LineAwesomeIcons.venus_mars), campoPreferenciaSexual.bisexual,
        Icon(LineAwesomeIcons.venus_mars)),
  ];

  ///Este metodo dependiendo de la propiedad name de item al ser llamado asigna al usuario un sexo
  void Sex() {
    if (selected.name == campoPreferenciaSexual.hombre) {
      Usuario.esteUsuario.sexoPareja = "Hombre";
    }
    if (selected.name == campoPreferenciaSexual.mujer) {
      Usuario.esteUsuario.sexoPareja = "Mujer";
    }
    if (selected.name == campoPreferenciaSexual.bisexual) {
      Usuario.esteUsuario.sexoPareja = "Ambos";
    } else {
      return null;
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            campoPreferenciaSexual.nombreCampo,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3))),
          child: DropdownButton<item>(
            value: selected,
            iconSize: ScreenUtil().setSp(60),
            elevation: 10,
            onChanged: (item newvalue) {
              setState(() {
                selected = newvalue;
                if (selected != null) {
                  Sex();
                  Usuario.esteUsuario.configurarModo();

                  print(Usuario.esteUsuario.citasCon);
                }
              });
            },
            items: items.map<DropdownMenuItem<item>>((item value) {
              return DropdownMenuItem<item>(
                value: value,
                child: Row(
                  children: <Widget>[
                    value.first_icon,
                    Text(
                      value.name,
                    ),
                    value.second_icon
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
class item {
  item(this.first_icon, this.name, this.second_icon);
  final String name;
  final Icon second_icon;
  final Icon first_icon;
}

class ItemModo {
  ItemModo(
    this.first_icon,
    this.name,
  );
  final String name;

  final Icon first_icon;
}

///**************************************************************************************************************************************************************
///  WIDGET SIGN IN BUTTON: Boton encargado de hacer llamar a la funcion que envia los datos introducidos por el usuario en la pantalla de registro
///
///*************************************************************************************************************************************************************

class BotonConfirmarRegistro extends StatefulWidget {
  BuildContext context;
  static String confirmar = "Confirmar";
  @override
  BotonConfirmarRegistro(this.context);
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BotonConfirmarRegistroState();
  }
}

class BotonConfirmarRegistroState extends State<BotonConfirmarRegistro> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
        width: ScreenUtil().setWidth(800),
        height: ScreenUtil().setHeight(150),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.green),
          child: FlatButton(
            onPressed: () {
              setState(() {
                Usuario.submit(widget.context);
              });
            },
            child: Text(BotonConfirmarRegistro.confirmar),
          ),
        ));
  }
}

class next_button extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return next_button_state();
  }
}

class next_button_state extends State<next_button> {
  static ValueNotifier numeroerror = ValueNotifier<int>(null);
  void SiguientePantalla(BuildContext context) {
    Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 100),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secAnimation,
                Widget child) {
              return ScaleTransition(
                  alignment: Alignment.centerRight,
                  scale: animation,
                  child: child);
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secAnimation) {
              return new sign_up_confirm();
            }));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
        width: ScreenUtil().setWidth(800),
        height: ScreenUtil().setHeight(150),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: Colors.green),
          child: FlatButton(
            onPressed: () async {
              int valor = Validadores.validadorGeneral(
                  Usuario.esteUsuario.nombre,
                  Usuario.esteUsuario.alias,
                  Usuario.esteUsuario.clave,
                  Usuario.esteUsuario.confirmar_clave,
                  Usuario.esteUsuario.email,
                  Usuario.esteUsuario.edad,
                  Usuario.esteUsuario.sexo,
                  Usuario.esteUsuario.citasCon);
              int veralias =
                  await Validadores.validarAlias(Usuario.esteUsuario.alias);
              print(valor);
              int veremail =
                  await Validadores.validadorEmail(Usuario.esteUsuario.email);
              if (valor == 0) {
                valor = 0;
              } else {
                setState(() {
                  ErrorMessages.error = valor;
                  PantallaRegistroState().showErrorDialog(context);
                });
              }
              if (veralias != 0 && valor == 0) {
                setState(() {
                  ErrorMessages.error = veralias;
                  PantallaRegistroState().showErrorDialog(context);
                });
              } else {
                if (veremail != 0 && valor == 0) {
                  setState(() {
                    ErrorMessages.error = veremail;
                    PantallaRegistroState().showErrorDialog(context);
                  });
                }
                if (veremail == 0 && veralias == 0 && valor == 0) {
                  SiguientePantalla(context);
                }
              }
            },
            child: Text("Next"),
          ),
        ));
  }
}

class ErrorMessages {
  static int error = 0;

  static String errornombre = "El campo nombre no puede estar vacio";
  static String nombrenumeros = "El campo nombre no puede contener numeros";
  static String aliasvacio = "El campo ALIAS no puede estar vacio";
  static String espacioalias = "El alias no puede tener espacios ";
  static String espacioemail = "El email no puede contener espacios";
  static String erroralias =
      "El alias ${Usuario.esteUsuario.alias} ya esta en uso porfavor elige otro";
  static String clavevacia = "El campo contraseña no puede estar vacio";
  static String clavecorta = "La contraseña debe tener mas de 8 caracteres";
  static String clavedesigual =
      "Las claves del campo confirmar clave y clave deben coincidir";
  static String emailVacio =
      "El campo de correo electronico no puede estar vacio";
  static String emailnovalido =
      "La direccion de correo electronico ${Usuario.esteUsuario.email} no es valida";
  static String emailexiste =
      "La direccion de correo electronico ${Usuario.esteUsuario.email} esta en uso";
  static String edadminima = "La edad minima son 18 años";
  static String edad =
      "Debe introducir su edad presionando el campo CUMPLEAÑOS";
  static String sexo = "Debe introducir su sexo presionando el campo SEXO";
  static String gustos = "Debe elegir sus gustos en el campo ME GUSTAN";
  static List<String> errores = [
    "",
    errornombre,
    nombrenumeros,
    erroralias,
    clavevacia,
    clavecorta,
    clavedesigual,
    emailVacio,
    emailnovalido,
    emailexiste,
    edad,
    edadminima,
    sexo,
    gustos,
    aliasvacio,
    espacioalias,
    espacioemail,
  ];
}

class FotosPerfil extends sign_up_confirm {
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

  static List<File> pictures = List(6);
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
        await ImagePicker.pickImage(source: ImageSource.gallery);
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
    if (imagenRecortada != null) {
      pieFoto(context, imagenRecortada, calculadorIndice());
    }

    this.setState(() {
      imagenFinal = imagenRecortada;
      pictures[box] = imagenFinal;
      Usuario.esteUsuario.FotosPerfil = pictures;
      print("${archivoImagen.lengthSync()} Tamaño original");
      print("${imagenRecortada.lengthSync()} Tamaño Recortado");
      print(box);
    });
  }

  abrirCamara(BuildContext context) async {
    var archivoImagen = await ImagePicker.pickImage(source: ImageSource.camera);
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
    if (imagenRecortada != null) {
      pieFoto(context, imagenRecortada, calculadorIndice());
    }

    this.setState(() {
      imagenFinal = imagenRecortada;
      pictures[box] = imagenFinal;
      Usuario.esteUsuario.FotosPerfil = pictures;
      print("${archivoImagen.lengthSync()} Tamaño original");
      print("${imagenRecortada.lengthSync()} Tamaño Recortado");
      print(box);
    });
  }

  eliminarImagen(BuildContext context) {
    this.setState(() {
      Usuario.esteUsuario.FotosPerfil[box] = null;
      print("object");
      if (Usuario.esteUsuario.FotosPerfil[box] == null) {
        print("vacio en $box");
      }
      Usuario.esteUsuario.notifyListeners();
    });
  }

  void pieFoto(BuildContext context, File imagen, int indice) {
    showGeneralDialog(
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 200),
        context: sign_up_confirm_state.claveScaffold.currentContext,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondanimation) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: ScreenUtil().setHeight(2600),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromRGBO(20, 20, 20, 50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: ScreenUtil().setHeight(1300),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: Image.file(imagen),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          child: Text("Comentarios Foto",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(60))),
                        ),
                      ),
                      Divider(
                        height: ScreenUtil().setHeight(200),
                      ),
                      Material(
                          color: Color.fromRGBO(0, 0, 0, 100),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white,
                                    width: ScreenUtil().setWidth(6)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                color: Colors.white30,
                              ),
                              child: EntradaTexto(
                                  Icon(LineAwesomeIcons.comment),
                                  "Pie de Foto",
                                  indice,
                                  false,
                                  200,
                                  2,
                                  200))),
                      Divider(
                        height: ScreenUtil().setHeight(200),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.green),
                        child: FlatButton(
                          child: Text("Hecho"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget build(BuildContext context) {
    imagen = widget.Imagen;
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(420),
      width: ScreenUtil().setWidth(420),
      decoration: BoxDecoration(
        border:
            Border.all(color: Colors.white, width: ScreenUtil().setWidth(6)),
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: Colors.white30,
      ),
      child: FlatButton(
        onPressed: () => opcionesImagenPerfil(),
        onLongPress: () => eliminarImagen(context),
        child: imagen == null
            ? Center(
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                ),
              )
            : Stack(alignment: AlignmentDirectional.center, children: [
                Image.file(
                  imagen,
                  fit: BoxFit.fill,
                ),
                Container(
                  height: ScreenUtil().setHeight(500),
                  width: ScreenUtil().setWidth(500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: ScreenUtil().setSp(150),
                    ),
                  ),
                ),
              ]),
      ),
    );
  }
}

class ElegirModo extends StatefulWidget {
  String sex;
  String nombre_campo;
  String campo_amigos;
  String campo_citas;
  String campo_ambos;
  ElegirModo(
    String nombre_campo,
    String campo_amigos,
    String campo_citas,
  ) {
    this.nombre_campo = nombre_campo;
    this.campo_amigos = campo_amigos;
    this.campo_citas = campo_citas;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ElegirModostate(nombre_campo, campo_amigos, campo_citas);
  }
}

class ElegirModostate extends State<ElegirModo> {
  String sex = PantallaRegistroState().sex;
  String nombre_campo;
  String campo_amigos;
  String campo_citas;

  static int modo;
  item selected;
  ItemModo seleccionado;
  static int GetSex() {
    int data = modo;
    return data;
  }

  ElegirModostate(
      String campo_nombre, String campo_amigos, String campo_citas) {
    this.nombre_campo = campo_nombre;
    this.campo_amigos = campo_amigos;
    this.campo_citas = campo_citas;
  }
  List<ItemModo> items = <ItemModo>[
    ItemModo(
      Icon(LineAwesomeIcons.heart),
      sign_up_confirm_state.textocitas,
    ),
    ItemModo(Icon(LineAwesomeIcons.users), sign_up_confirm_state.textoaigos),
    ItemModo(
        Icon(LineAwesomeIcons.double_check), sign_up_confirm_state.texto_ambos),
  ];

  void seleccionarModo() {
    if (seleccionado.name == sign_up_confirm_state.textocitas) {
      Usuario.esteUsuario.citas = true;
      Usuario.esteUsuario.ambos = false;
      Usuario.esteUsuario.citas = false;
      Usuario.esteUsuario.configurarModo();
      print(Usuario.esteUsuario.citasCon);
    }
    if (seleccionado.name == sign_up_confirm_state.textoaigos) {
      Usuario.esteUsuario.amigos = true;
      Usuario.esteUsuario.ambos = false;
      Usuario.esteUsuario.citas = false;
      Usuario.esteUsuario.citasCon = null;
      print(Usuario.esteUsuario.citasCon);
    }
    if (seleccionado.name == sign_up_confirm_state.texto_ambos) {
      Usuario.esteUsuario.amigos = false;
      Usuario.esteUsuario.ambos = true;
      Usuario.esteUsuario.citas = false;
      Usuario.esteUsuario.configurarModo();
      print(Usuario.esteUsuario.citasCon);
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            sign_up_confirm_state.seleccionar_modo,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(4))),
          child: DropdownButton<ItemModo>(
            value: seleccionado,
            iconSize: ScreenUtil().setSp(60),
            elevation: 0,
            onChanged: (ItemModo newvalue) {
              setState(() {
                seleccionado = newvalue;
                if (seleccionado.name != null) {
                  seleccionarModo();
                }
              });
            },
            items: items.map<DropdownMenuItem<ItemModo>>((ItemModo value) {
              return DropdownMenuItem<ItemModo>(
                value: value,
                child: Row(
                  children: <Widget>[
                    value.first_icon,
                    Text(
                      value.name,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class BotonCrearPerfil extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return next_button_state();
  }
}

class BotonCrearPrfilState extends State<BotonCrearPerfil> {
  void SiguientePantalla(BuildContext context, Widget pantalla) {
    Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 100),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secAnimation,
                Widget child) {
              return ScaleTransition(
                  alignment: Alignment.centerRight,
                  scale: animation,
                  child: child);
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secAnimation) {
              return sign_up_confirm();
            }));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
        width: ScreenUtil().setWidth(800),
        height: ScreenUtil().setHeight(150),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.green),
          child: FlatButton(
            onPressed: () {
              setState(() {
                SiguientePantalla(context, sign_up_confirm());
              });
            },
            child: Text("Next"),
          ),
        ));
  }
}

class Validadores {
  static final dbRef = Firestore.instance;
  static bool validadorNombre(String nombre) {
    if (Usuario.esteUsuario.nombre == null ||
        Usuario.esteUsuario.nombre.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static bool validadorNombreNumeros(String nombre) {
    if (Usuario.esteUsuario.nombre.contains("1") ||
        Usuario.esteUsuario.nombre.contains("2") ||
        Usuario.esteUsuario.nombre.contains("3") ||
        Usuario.esteUsuario.nombre.contains("4") ||
        Usuario.esteUsuario.nombre.contains("5") ||
        Usuario.esteUsuario.nombre.contains("6") ||
        Usuario.esteUsuario.nombre.contains("7") ||
        Usuario.esteUsuario.nombre.contains("8") ||
        Usuario.esteUsuario.nombre.contains("9") ||
        Usuario.esteUsuario.nombre.contains("0")) {
      return false;
    } else {
      return true;
    }
  }

  static Future<int> validarAlias(String alias) async {
    int aliasval;
    bool nohayalias;
    final QuerySnapshot resutl = await dbRef
        .collection("usuarios")
        .where("Alias", isEqualTo: alias)
        .limit(1)
        .getDocuments();
    resutl.documents.length == 1 ? nohayalias = false : nohayalias = true;

    nohayalias == true ? aliasval = 0 : aliasval = 3;

    print("$alias $nohayalias  $aliasval alias en nube");
    return aliasval;
  }

  static Future<int> validadorEmail(String email) async {
    bool resultado;
    int emailval;
    final QuerySnapshot resutl = await dbRef
        .collection("usuarios")
        .where("Email", isEqualTo: email)
        .limit(1)
        .getDocuments();
    resutl.documents.length == 1 ? resultado = false : resultado = true;

    resultado == true ? emailval = 0 : emailval = 9;
    return emailval;
  }

  static Future<int> validadorFinal() async {
    int val = validadorGeneral(
        Usuario.esteUsuario.nombre,
        Usuario.esteUsuario.alias,
        Usuario.esteUsuario.clave,
        Usuario.esteUsuario.confirmar_clave,
        Usuario.esteUsuario.email,
        Usuario.esteUsuario.edad,
        Usuario.esteUsuario.sexo,
        Usuario.esteUsuario.citasCon);

    //  print(val);
    return val;
  }

  static bool validadorMismaClave(String clave, String confirmar_clave) {
    if (clave != confirmar_clave) {
      return false;
    } else {
      return true;
    }
  }

  static bool validadorLongitudClave(String clave) {
    if (clave.length < 8) {
      return false;
    } else {
      return true;
    }
  }

  static bool validadorClaveNoVacia(String clave) {
    if (clave == null) {
      return false;
    } else {
      return true;
    }
  }

  static bool validadorEmailNoVacio(String email) {
    bool email_no_vacio;

    if (email == null) {
      return false;
    } else {
      if (email.isEmpty) {
        return false;
      } else {
        return true;
      }
    }
  }

  static bool validadorEmailValido(String email) {
    if (!email.contains("@")) {
      return false;
    } else {
      return true;
    }
  }

  static bool validadorEdadMinima(int edad) {
    if (edad < 18) {
      return false;
    } else {
      return true;
    }
  }

  static bool validadorSexo(String sexo) {
    if (sexo == null) {
      return false;
    } else {
      return true;
    }
  }

  static bool validadorSexualidad(String sexualidad) {
    if (sexualidad == null) {
      return false;
    } else {
      return true;
    }
  }

  static int validadorGeneral(
      String nombre,
      String alias,
      String clave,
      String confirmar_clave,
      String email,
      int edad,
      String sexo,
      String sexualidad) {
    int error = 0;
    if (validadorNombre(nombre) && error == 0) {
      error = 0;
    } else {
      error = 1;
      return error;
    }
    if (validadorNombreNumeros(nombre) && error == 0) {
      error = 0;
    } else {
      error = 2;
      return error;
    }

    if (validadorClaveNoVacia(clave) && error == 0) {
      error = 0;
    } else {
      error = 4;
      return error;
    }
    if (validadorLongitudClave(clave) && error == 0) {
      error = 0;
    } else {
      error = 5;
      return error;
    }
    if (validadorMismaClave(clave, confirmar_clave) && error == 0) {
      error = 0;
    } else {
      error = 6;
      return error;
    }
    if (validadorEmailNoVacio(email) && error == 0) {
      error = 0;
    } else {
      error = 7;
      return error;
    }
    if (validadorEmailValido(email) && error == 0) {
      error = 0;
    } else {
      error = 8;
      return error;
    }

    if (edad != null && error == 0) {
      error = 0;
    } else {
      error = 10;
      return error;
    }
    if (validadorEdadMinima(edad) && error == 0) {
      error = 0;
    } else {
      error = 11;
      print(error);
      return error;
    }
    if (validadorSexo(sexo) && error == 0) {
      error = 0;
    } else {
      error = 12;
      return error;
    }
    if (validadorSexualidad(sexualidad) && error == 0) {
      error = 0;
    } else {
      error = 13;
      return error;
    }
    if (alias != null) {
      error = 0;
    } else {
      error = 14;
      return error;
    }
    if (!alias.contains(" ")) {
      error = 0;
    } else {
      error = 15;
      return error;
    }
    if (!email.contains(" ")) {
      error = 0;
      return error;
    } else {
      error = 16;
      return error;
    }
  }
}
