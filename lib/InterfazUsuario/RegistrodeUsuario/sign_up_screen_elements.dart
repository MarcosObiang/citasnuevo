import 'dart:core';


import 'package:citasnuevo/InterfazUsuario/Social/social_screen_elements.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/gestures.dart';
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
  TextEditingController controladorTexto = new TextEditingController();

  @override
  void initState() {
      Usuario.esteUsuario.nombre = widget.nombre_campo;
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
        child: text_black());
  }

  Widget text_black() {
    return TextField(
      maxLines: lineas,
      maxLength: caracteres,
      textInputAction: TextInputAction.done,
      controller:controladorTexto,
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
    controladorEditorDescripcion.text =
        Usuario.esteUsuario.observaciones;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        maxLines: 9,
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

///**************************************************************************************************************************************************************
///  WIDGET BOTON NACIMMIENTO: Boton que debe ser presionado para acceder al menu que nos deja elegir la fecha de nacimiento(String texto)
///
///  TEXTO: Recibe una cadena de caracteres con la traduccion de cumpleaños al idioma deseado
///
/// *************************************************************************************************************************************************************

class BotonNacimiento extends StatefulWidget {
  DateTime dato;
 int caracteresIntroducidos=0;
 

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BotonNacimientoState();
  }

  BotonNacimiento(this.dato);
}

class BotonNacimientoState extends State<BotonNacimiento> {
  TextEditingController controladorTextoDia=new TextEditingController();
  TextEditingController controladorTextoMes=new TextEditingController();
  TextEditingController controladorTextoAnio=new TextEditingController();
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
    nodoDia=new FocusNode();
    nodoMes=new FocusNode();
    nodoAnio=new FocusNode();

    super.initState();
  }

  void dispose(){
nodoAnio.dispose();
nodoDia.dispose();
nodoMes.dispose();
    super.dispose();
  }

 

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: ScreenUtil().setHeight(100),
          width: 600.w,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3))),
          child: Row(
            children: [
              Flexible(
                flex:2,
                fit: FlexFit.tight,
                              child: TextFormField(
                                focusNode: nodoDia,
                  maxLength: 2,
                  maxLines: 1,
                  
                  maxLengthEnforced: true,
                  keyboardType: TextInputType.datetime,
                  controller:controladorTextoDia,
                  onEditingComplete: (){
                    print(Usuario.esteUsuario.fechaNacimiento);
                  },
                  style: TextStyle(fontSize: 60.sp),
                  decoration: InputDecoration(counter: Offstage(),
                  hintText: "dd",
                  hintStyle: TextStyle(color: Colors.grey)
                 
                  ),
                  
                  onChanged:(valor){
                    if(valor.length>=2){
                      Usuario.esteUsuario.dia=int.parse(valor);
                      nodoDia.unfocus();
                      nodoMes.requestFocus();
                    }
                      if(valor.length==0){
                    
                    }
                 
                   



                  },




                ),
              ),

              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text("/",style:TextStyle(fontSize:90.sp))),
               Flexible(
                  flex:2,
                fit: FlexFit.tight,
                                child: TextField(
                                  focusNode:nodoMes,
                  maxLength: 2,
                  keyboardType: TextInputType.datetime,
                  controller:controladorTextoMes,
                  onEditingComplete: (){
                    print(Usuario.esteUsuario.fechaNacimiento);
                  },
                  style: TextStyle(fontSize: 60.sp),
                  decoration: InputDecoration(counter: Offstage(),
                 hintText: "mm",
                 hintStyle: TextStyle(color: Colors.grey),
                  ),
                  
                  onChanged:(valor){
                      if(valor.length>=2){
                         Usuario.esteUsuario.mes=int.parse(valor);
                      nodoMes.unfocus();
                      nodoAnio.requestFocus();
                    }

                    if(valor.length==0){
                      
                        nodoMes.unfocus();
                      nodoDia.requestFocus();
                    }
                 
                   



                  },




              ),
               ),
               Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text("/",style:TextStyle(fontSize:90.sp))),
                      Flexible(
                  flex:4,
                fit: FlexFit.tight,
                                child: TextField(
                                  
                                  focusNode:nodoAnio,
                  maxLength: 4,
                  keyboardType: TextInputType.datetime,
                  controller:controladorTextoAnio,
                  onEditingComplete: (){
                    print(Usuario.esteUsuario.fechaNacimiento);
                  },
                  style: TextStyle(fontSize: 60.sp),
                  decoration: InputDecoration(counter: Offstage(),
                  hintText: "yyyy",
                  hintStyle: TextStyle(color: Colors.grey)
                  ),
                  
                  onChanged:(valor){
                   if(valor.length>=4){
                      Usuario.esteUsuario.anio=int.parse(valor);
                      Usuario.esteUsuario.validadorFecha();
                      
                    }
                       if(valor.length==0){
                        nodoAnio.unfocus();
                      nodoMes.requestFocus();
                    }
                   



                  },




              ),
               ),
            ],
          )
          
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
        Container(
          width: 150.w,
        height: 150.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
             
       ),
          child: Center(
            child: Usuario.esteUsuario.edad==0
                ? Text("")
                : Text(
                 Usuario.esteUsuario.edad.toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(70),
                        fontWeight: FontWeight.bold,
                        color:Usuario.esteUsuario.edad < 18 ? Colors.red : Colors.green),
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
  static String confirmar = "Siguiente";
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
        width: ScreenUtil().setWidth(400),
        height: 200.h,
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
        width: ScreenUtil().setWidth(400),
        height: 100.h,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: Colors.green),
          child: FlatButton(
            onPressed: () async {
              SiguientePantalla(context);
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
        height: 200.h,
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

class ListaPreguntasUsuario extends StatefulWidget {
  @override
  _ListaPreguntasUsuarioState createState() => _ListaPreguntasUsuarioState();
}

class _ListaPreguntasUsuarioState extends State<ListaPreguntasUsuario> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          PreguntaQueBuscasEnLaGente(),
        ],
      ),
    );
  }
}

class PreguntaQueBuscasEnLaGente extends StatefulWidget {
  @override
  PreguntaQueBuscasEnLaGenteState createState() =>
      PreguntaQueBuscasEnLaGenteState();
}

class PreguntaQueBuscasEnLaGenteState
    extends State<PreguntaQueBuscasEnLaGente> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.queBuscasEnAlguien != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.queBuscasEnAlguien = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.queBuscasEnAlguien == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.queBuscasEnAlguien == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que buscas en la gente?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.queBuscasEnAlguien ??
                                  "En la gente busco....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.queBuscasEnAlguien != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();
    if (Usuario.esteUsuario.queBuscasEnAlguien != null) {
      controladorTexto.text = Usuario.esteUsuario.queBuscasEnAlguien;
    }

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.queBuscasEnAlguien == null) {
        habraCambio = true;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que buscas en alguien?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.queBuscasEnAlguien = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Cuentanos"),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.queBuscasEnAlguien = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              print(Usuario.esteUsuario.altura);
                              Navigator.pop(context);
                              Usuario.esteUsuario.queBuscasEnAlguien =
                                  controladorTexto.value.text;
                              print(Usuario.esteUsuario.queBuscasEnAlguien);
                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaQueOdiasDeLaGente extends StatefulWidget {
  @override
  _PreguntaQueOdiasDeLaGenteState createState() =>
      _PreguntaQueOdiasDeLaGenteState();
}

class _PreguntaQueOdiasDeLaGenteState extends State<PreguntaQueOdiasDeLaGente> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.queOdiasEnAlguien != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.queOdiasEnAlguien = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.queOdiasEnAlguien == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.queOdiasEnAlguien == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que odias de la gente?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.queOdiasEnAlguien ??
                                  "En la gente odio....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.queOdiasEnAlguien != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.queOdiasEnAlguien != null) {
        controladorTexto.text = Usuario.esteUsuario.queOdiasEnAlguien;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que odias de la gente?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.queOdiasEnAlguien = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: "De la gente odio.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.queOdiasEnAlguien = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.queOdiasEnAlguien =
                                  controladorTexto.value.text;
                              print(Usuario.esteUsuario.queOdiasEnAlguien);
                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaTuRecetaDeFelicidad extends StatefulWidget {
  @override
  _PreguntaTuRecetaDeFelicidadState createState() =>
      _PreguntaTuRecetaDeFelicidadState();
}

class _PreguntaTuRecetaDeFelicidadState
    extends State<PreguntaTuRecetaDeFelicidad> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.recetaFelicidad != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.recetaFelicidad = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.recetaFelicidad == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.recetaFelicidad == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Receta de la felicidad?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.recetaFelicidad ??
                                  "La receta es....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.recetaFelicidad != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.recetaFelicidad != null) {
        controladorTexto.text = Usuario.esteUsuario.recetaFelicidad;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Receta de la felicidad?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.recetaFelicidad = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "La receta es.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.recetaFelicidad = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.recetaFelicidad =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaSiQuedaraUnDiaDeVida extends StatefulWidget {
  @override
  _PreguntaSiQuedaraUnDiaDeVidaState createState() =>
      _PreguntaSiQuedaraUnDiaDeVidaState();
}

class _PreguntaSiQuedaraUnDiaDeVidaState
    extends State<PreguntaSiQuedaraUnDiaDeVida> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.siQuedaUnDiaDeVida != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.siQuedaUnDiaDeVida = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.siQuedaUnDiaDeVida == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.siQuedaUnDiaDeVida == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Si me queda un dia de vida?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.siQuedaUnDiaDeVida ??
                                  "Haria....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.siQuedaUnDiaDeVida != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.siQuedaUnDiaDeVida != null) {
        controladorTexto.text = Usuario.esteUsuario.siQuedaUnDiaDeVida;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "¿Si me queda un dia de vida?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.siQuedaUnDiaDeVida = null;

                              Usuario.esteUsuario.notifyListeners();
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Haria..."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.siQuedaUnDiaDeVida = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.siQuedaUnDiaDeVida =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaQueTipoDeMusicaTeGusta extends StatefulWidget {
  @override
  _PreguntaQueTipoDeMusicaTeGustaState createState() =>
      _PreguntaQueTipoDeMusicaTeGustaState();
}

class _PreguntaQueTipoDeMusicaTeGustaState
    extends State<PreguntaQueTipoDeMusicaTeGusta> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.queMusicaTeGusta != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.queMusicaTeGusta = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.queMusicaTeGusta == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.queMusicaTeGusta == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que musica te gusta?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.queMusicaTeGusta ??
                                  "Me gusta....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.queMusicaTeGusta != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.queMusicaTeGusta != null) {
        controladorTexto.text = Usuario.esteUsuario.queMusicaTeGusta;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que musica te gusta?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.queMusicaTeGusta = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "ME gusta.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.queMusicaTeGusta = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.queMusicaTeGusta =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaEnQueCreesQueEresBueno extends StatefulWidget {
  @override
  _PreguntaEnQueCreesQueEresBuenoState createState() =>
      _PreguntaEnQueCreesQueEresBuenoState();
}

class _PreguntaEnQueCreesQueEresBuenoState
    extends State<PreguntaEnQueCreesQueEresBueno> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.enQueEresBueno != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.enQueEresBueno = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.enQueEresBueno == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.enQueEresBueno == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Eres bueno en...?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.enQueEresBueno ??
                                  "Soy bueno en....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.enQueEresBueno != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.enQueEresBueno != null) {
        controladorTexto.text = Usuario.esteUsuario.enQueEresBueno;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Eres bueno en..?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.enQueEresBueno = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Soy bueno en.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.enQueEresBueno = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.enQueEresBueno =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaQueEsLoQueMasValoras extends StatefulWidget {
  @override
  _PreguntaQueEsLoQueMasValorasState createState() =>
      _PreguntaQueEsLoQueMasValorasState();
}

class _PreguntaQueEsLoQueMasValorasState
    extends State<PreguntaQueEsLoQueMasValoras> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.queEsLoQueMasValoras != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.queEsLoQueMasValoras = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.queEsLoQueMasValoras == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.queEsLoQueMasValoras == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que valoras en alguien?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.queEsLoQueMasValoras ??
                                  "Lo que valoro en alguien es....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.queEsLoQueMasValoras != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.queEsLoQueMasValoras == null) {
        controladorTexto.text = Usuario.esteUsuario.queEsLoQueMasValoras;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que valoras en alguien?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.queEsLoQueMasValoras = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: "Lo que mas valoro es.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.queEsLoQueMasValoras = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              print(Usuario.esteUsuario.altura);
                              Navigator.pop(context);
                              Usuario.esteUsuario.queEsLoQueMasValoras =
                                  controladorTexto.value.text;
                              print(Usuario.esteUsuario.queBuscasEnAlguien);
                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaLaGenteDiceQueEres extends StatefulWidget {
  @override
  _PreguntaLaGenteDiceQueEresState createState() =>
      _PreguntaLaGenteDiceQueEresState();
}

class _PreguntaLaGenteDiceQueEresState
    extends State<PreguntaLaGenteDiceQueEres> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              if (Usuario.esteUsuario.laGenteDiceQueSoy != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.laGenteDiceQueSoy = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.laGenteDiceQueSoy == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.laGenteDiceQueSoy == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que dice la gente de ti?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.laGenteDiceQueSoy ??
                                  "La gente dice que....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.laGenteDiceQueSoy != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.queBuscasEnAlguien == null) {
        habraCambio = true;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que dice la gente de ti?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.laGenteDiceQueSoy = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "La gente dice.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.laGenteDiceQueSoy = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              print(Usuario.esteUsuario.altura);
                              Navigator.pop(context);
                              Usuario.esteUsuario.laGenteDiceQueSoy =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaQueTeHaceReir extends StatefulWidget {
  @override
  _PreguntaQueTeHaceReirState createState() => _PreguntaQueTeHaceReirState();
}

class _PreguntaQueTeHaceReirState extends State<PreguntaQueTeHaceReir> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.queMeHaceReir != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.queBuscasEnAlguien = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.queMeHaceReir == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.queMeHaceReir == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que te hace reir?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.queMeHaceReir ??
                                  "ME hace reir....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.queMeHaceReir != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.queMeHaceReir != null) {
        controladorTexto.text = Usuario.esteUsuario.queMeHaceReir;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que te hace reir?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.queMeHaceReir = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Me hace reir.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.queMeHaceReir = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              print(Usuario.esteUsuario.altura);
                              Navigator.pop(context);
                              Usuario.esteUsuario.queMeHaceReir =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaCitaPErfecta extends StatefulWidget {
  @override
  _PreguntaCitaPErfectaState createState() => _PreguntaCitaPErfectaState();
}

class _PreguntaCitaPErfectaState extends State<PreguntaCitaPErfecta> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.citaPErfecta != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.citaPErfecta = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.citaPErfecta == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.citaPErfecta == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Como es tu cita perfecta?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.citaPErfecta ??
                                  "Mi cita perfecta es....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.citaPErfecta != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.citaPErfecta != null) {
        controladorTexto.text = Usuario.esteUsuario.citaPErfecta;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Como es tu cita perfecta?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.citaPErfecta = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: "Mi cita perfecta es.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.citaPErfecta = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.citaPErfecta =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PReguntaCancionFavorita extends StatefulWidget {
  @override
  _PReguntaCancionFavoritaState createState() =>
      _PReguntaCancionFavoritaState();
}

class _PReguntaCancionFavoritaState extends State<PReguntaCancionFavorita> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.cancionFavorita != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.cancionFavorita = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.cancionFavorita == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.cancionFavorita == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Cual es tu cancion favorita?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.cancionFavorita ??
                                  "Mi cancion favorita es....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.cancionFavorita != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.cancionFavorita != null) {
        controladorTexto.text = Usuario.esteUsuario.cancionFavorita;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Cual es tu cancion favorita?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.cancionFavorita = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: "Mi cancion favorita es.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.cancionFavorita = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.cancionFavorita =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaUnaVerdadYUnaMentira extends StatefulWidget {
  @override
  _PreguntaUnaVerdadYUnaMentiraState createState() =>
      _PreguntaUnaVerdadYUnaMentiraState();
}

class _PreguntaUnaVerdadYUnaMentiraState
    extends State<PreguntaUnaVerdadYUnaMentira> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.unaVerdadUnaMentira != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.unaVerdadUnaMentira = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.unaVerdadUnaMentira == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.unaVerdadUnaMentira == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("Una verdad y una mentira",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.unaVerdadUnaMentira ??
                                  "Xd....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.queBuscasEnAlguien != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.unaVerdadUnaMentira != null) {
        controladorTexto.text = Usuario.esteUsuario.unaVerdadUnaMentira;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "Di una verdad y una mentira",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.unaVerdadUnaMentira = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Xd.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.unaVerdadUnaMentira = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.queBuscasEnAlguien =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaPorQueTeHariasFamoso extends StatefulWidget {
  @override
  _PreguntaPorQueTeHariasFamosoState createState() =>
      _PreguntaPorQueTeHariasFamosoState();
}

class _PreguntaPorQueTeHariasFamosoState
    extends State<PreguntaPorQueTeHariasFamoso> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.meHariaFamosoPor != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.meHariaFamosoPor = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.meHariaFamosoPor == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.meHariaFamosoPor == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que te haria famoso?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.meHariaFamosoPor ??
                                  "Seria famoso por....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.queBuscasEnAlguien != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.meHariaFamosoPor != null) {
        controladorTexto.text = Usuario.esteUsuario.meHariaFamosoPor;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que te haria famoso?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.meHariaFamosoPor = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: "Seria famoso por.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.meHariaFamosoPor = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.meHariaFamosoPor =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaSiFuerasUnHeroeSerias extends StatefulWidget {
  @override
  _PreguntaSiFuerasUnHeroeSeriasState createState() =>
      _PreguntaSiFuerasUnHeroeSeriasState();
}

class _PreguntaSiFuerasUnHeroeSeriasState
    extends State<PreguntaSiFuerasUnHeroeSerias> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.siFueraUnHeroe != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.siFueraUnHeroe = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.siFueraUnHeroe == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.siFueraUnHeroe == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que heroe serias?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.siFueraUnHeroe ?? "Seria....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.siFueraUnHeroe != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.siFueraUnHeroe != null) {
        controladorTexto.text = Usuario.esteUsuario.meHariaFamosoPor;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que heroe serias?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.siFueraUnHeroe = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: "Que heroe serias.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.siFueraUnHeroe = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              print(Usuario.esteUsuario.altura);
                              Navigator.pop(context);
                              Usuario.esteUsuario.siFueraUnHeroe =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaSiFueraUnVillanooSeria extends StatefulWidget {
  @override
  _PreguntaSiFueraUnVillanooSeriaState createState() =>
      _PreguntaSiFueraUnVillanooSeriaState();
}

class _PreguntaSiFueraUnVillanooSeriaState
    extends State<PreguntaSiFueraUnVillanooSeria> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              if (Usuario.esteUsuario.siFueraUnVillano != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.siFueraUnVillano = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.siFueraUnVillano == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.siFueraUnVillano == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que villano serias?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.siFueraUnVillano ??
                                  "Seria...",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.siFueraUnVillano != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.siFueraUnVillano != null) {
        controladorTexto.text = Usuario.esteUsuario.siFueraUnVillano;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  if (!habraCambio &&
                                      Usuario.esteUsuario.preguntasContestadas <
                                          3) {
                                    Usuario.esteUsuario.preguntasContestadas +=
                                        1;
                                  }
                                  Usuario.esteUsuario.siFueraUnVillano = null;

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
                            Text(
                              "¿Que villano serias?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Seria..."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.siFueraUnVillano = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.siFueraUnVillano =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaComidaRestoDeMiVida extends StatefulWidget {
  @override
  _PreguntaComidaRestoDeMiVidaState createState() =>
      _PreguntaComidaRestoDeMiVidaState();
}

class _PreguntaComidaRestoDeMiVidaState
    extends State<PreguntaComidaRestoDeMiVida> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.comerUnPlatoElRestoDeMividaSeria !=
                  null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.comerUnPlatoElRestoDeMividaSeria = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.comerUnPlatoElRestoDeMividaSeria ==
                          null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario
                                    .comerUnPlatoElRestoDeMividaSeria ==
                                null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que comerias el resto de tu vida?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario
                                      .comerUnPlatoElRestoDeMividaSeria ??
                                  "Comeria....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child:
                  Usuario.esteUsuario.comerUnPlatoElRestoDeMividaSeria != null
                      ? Center(child: Text("Presiona para borrar pregunta"))
                      : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.comerUnPlatoElRestoDeMividaSeria != null) {
        controladorTexto.text =
            Usuario.esteUsuario.comerUnPlatoElRestoDeMividaSeria;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que comerias el resto de tu vida?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario
                                  .comerUnPlatoElRestoDeMividaSeria = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Comeria.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.comerUnPlatoElRestoDeMividaSeria =
                            valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              print(Usuario.esteUsuario.altura);
                              Navigator.pop(context);
                              Usuario.esteUsuario
                                      .comerUnPlatoElRestoDeMividaSeria =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PReguntaNosLLEvamosBienSi extends StatefulWidget {
  @override
  _PReguntaNosLLEvamosBienSiState createState() =>
      _PReguntaNosLLEvamosBienSiState();
}

class _PReguntaNosLLEvamosBienSiState extends State<PReguntaNosLLEvamosBienSi> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.nosLlevaremosBienSi != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.nosLlevaremosBienSi = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.nosLlevaremosBienSi == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.nosLlevaremosBienSi == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Como podemos llevarnos bien?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.nosLlevaremosBienSi ??
                                  "pues....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.nosLlevaremosBienSi != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.nosLlevaremosBienSi != null) {
        controladorTexto.text = Usuario.esteUsuario.nosLlevaremosBienSi;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Como llevarnos bien?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.nosLlevaremosBienSi = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Pues.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.nosLlevaremosBienSi = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              print(Usuario.esteUsuario.altura);
                              Navigator.pop(context);
                              Usuario.esteUsuario.nosLlevaremosBienSi =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PReguntaBorrachoSoy extends StatefulWidget {
  @override
  _PReguntaBorrachoSoyState createState() => _PReguntaBorrachoSoyState();
}

class _PReguntaBorrachoSoyState extends State<PReguntaBorrachoSoy> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.borrachoSoyMuy != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.borrachoSoyMuy = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.borrachoSoyMuy == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.borrachoSoyMuy == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Como eres borracho/a?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(Usuario.esteUsuario.borrachoSoyMuy ?? "Pues....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.borrachoSoyMuy != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.borrachoSoyMuy != null) {
        controladorTexto.text = Usuario.esteUsuario.borrachoSoyMuy;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Como eres borracho?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.borrachoSoyMuy = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Pues.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.borrachoSoyMuy = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.borrachoSoyMuy =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    pantallaRegistroCinco.preguntasRestantes -
                                        1;
                              }
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
          });
    }
  }
}

class PregutnaAnecdota extends StatefulWidget {
  @override
  _PregutnaAnecdotaState createState() => _PregutnaAnecdotaState();
}

class _PregutnaAnecdotaState extends State<PregutnaAnecdota> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              if (Usuario.esteUsuario.anecdota != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.anecdota = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.anecdota == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.anecdota == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Tu mejor anecdota?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.anecdota ??
                                  "Mi mejor anecdota es....",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.anecdota != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.anecdota != null) {
        controladorTexto.text = Usuario.esteUsuario.anecdota;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Alguna anecdota?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.anecdota = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: "Mi mejor anecdota es..."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.anecdota = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              Navigator.pop(context);
                              Usuario.esteUsuario.anecdota =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    Usuario.esteUsuario.preguntasContestadas -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaPeliculaRecomendada extends StatefulWidget {
  @override
  _PreguntaPeliculaRecomendadaState createState() =>
      _PreguntaPeliculaRecomendadaState();
}

class _PreguntaPeliculaRecomendadaState
    extends State<PreguntaPeliculaRecomendada> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => modificarAtributo(context),
            onLongPress: () {
              print(Usuario.esteUsuario.preguntasContestadas);

              if (Usuario.esteUsuario.peliculaRecomiendas != null) {
                if (Usuario.esteUsuario.preguntasContestadas < 3) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                Usuario.esteUsuario.peliculaRecomiendas = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      Usuario.esteUsuario.peliculaRecomiendas == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.white, BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Usuario.esteUsuario.peliculaRecomiendas == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("¿Que pelicula recomiendas?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60))),
                          Text(
                              Usuario.esteUsuario.peliculaRecomiendas ??
                                  "Recomiendo...",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40))),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: Usuario.esteUsuario.peliculaRecomiendas != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (Usuario.esteUsuario.peliculaRecomiendas != null) {
        controladorTexto.text = Usuario.esteUsuario.peliculaRecomiendas;
      } else {
        habraCambio = false;
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil.screenHeight / 1,
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
                            Text(
                              "¿Que peliculas recomiendas?",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(60)),
                            ),
                          ],
                        )),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              Usuario.esteUsuario.peliculaRecomiendas = null;

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
                  Container(
                    width: ScreenUtil().setWidth(1200),
                    child: TextField(
                      decoration: InputDecoration(labelText: "Recomiendo.."),
                      maxLines: 3,
                      maxLength: 200,
                      controller: controladorTexto,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (valor) {
                        Usuario.esteUsuario.peliculaRecomiendas = valor;
                        if (habraCambio) {
                          Usuario.esteUsuario.preguntasContestadas =
                              Usuario.esteUsuario.preguntasContestadas - 1;
                        }
                        Navigator.pop(context);
                        print(valor);
                      },
                    ),
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
                              print(Usuario.esteUsuario.altura);
                              Navigator.pop(context);
                              Usuario.esteUsuario.peliculaRecomiendas =
                                  controladorTexto.value.text;

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    Usuario.esteUsuario.preguntasContestadas -
                                        1;
                              }
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
          });
    }
  }
}

class PreguntaUsuario extends StatefulWidget {
  String preguntaUsuario;
  String respuestaUsuario;
  int indicePregunta;

  PreguntaUsuario(
      {@required this.preguntaUsuario,
      @required this.respuestaUsuario,
      @required this.indicePregunta});

  @override
  _PreguntaUsuarioState createState() => _PreguntaUsuarioState();
}

class _PreguntaUsuarioState extends State<PreguntaUsuario> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (Usuario.esteUsuario.preguntasContestadas <= 4) {
                modificarAtributo(context);
              }
            },
            onLongPress: () {
              if (widget.respuestaUsuario != null) {
                if (Usuario.esteUsuario.preguntasContestadas <= 4) {
                  Usuario.esteUsuario.preguntasContestadas += 1;
                }

                widget.respuestaUsuario = null;
                Usuario.esteUsuario.listaRespuestasPreguntasPersonales[
                    widget.indicePregunta] = null;
                Usuario.esteUsuario.notifyListeners();
              }
            },
            child: ColorFiltered(
              colorFilter: (Usuario.esteUsuario.preguntasContestadas == 0 &&
                      widget.respuestaUsuario == null)
                  ? ColorFilter.mode(Colors.grey.shade700, BlendMode.modulate)
                  : ColorFilter.mode(Colors.purple[100], BlendMode.modulate),
              child: Material(
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                        color: widget.respuestaUsuario == null
                            ? Colors.white
                            : Colors.green),
                    height: 200.h,
                    width: ScreenUtil().setWidth(1500),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("${widget.preguntaUsuario} ${widget.indicePregunta}",
                            style: TextStyle(fontSize: ScreenUtil().setSp(60))),
                      ),
                    )),
              ),
            ),
          ),
          Container(
              child: widget.respuestaUsuario != null
                  ? Center(child: Text("Presiona para borrar pregunta"))
                  : Container())
        ],
      ),
    );
  }

  void modificarAtributo(BuildContext context) {
    bool vivirSolo = false;
    bool vivirPadres = false;
    bool vivirAmigos = false;
    bool habraCambio = false;
    TextEditingController controladorTexto = new TextEditingController();

    if (Usuario.esteUsuario.preguntasContestadas > 0) {
      vivirSolo = false;
      vivirPadres = false;
      vivirAmigos = false;
      if (widget.respuestaUsuario != null) {
        controladorTexto.text = widget.respuestaUsuario;
      } else {
        habraCambio = false;
      }

      showDialog(
          useSafeArea: true,
          context: context,
          builder: (context) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.transparent,
              body: Container(
                height: ScreenUtil.screenHeight,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 50.0, right: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Row(
                                children: <Widget>[
                                  Text(
                                    widget.preguntaUsuario,
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: ScreenUtil().setSp(60)),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(1200),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: widget.preguntaUsuario,
                              labelStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white,
                              focusColor: Colors.red
                            ),
                            maxLines: 3,
                            maxLength: 200,
                            controller: controladorTexto,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (valor) {
                              widget.respuestaUsuario = valor;
                              Usuario.esteUsuario
                                          .listaRespuestasPreguntasPersonales[
                                      widget.indicePregunta] =
                                  widget.respuestaUsuario;
                              print(Usuario.esteUsuario.recetaFelicidad);

                              if (habraCambio) {
                                Usuario.esteUsuario.preguntasContestadas =
                                    Usuario.esteUsuario.preguntasContestadas -
                                        1;
                              }
                              Navigator.pop(context);
                            },
                          ),
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
                                    Navigator.pop(context);
                                    widget.respuestaUsuario =
                                        controladorTexto.value.text;
                                    Usuario.esteUsuario
                                            .listaRespuestasPreguntasPersonales[
                                        widget
                                            .indicePregunta] = widget
                                        .respuestaUsuario;

                                    if (habraCambio) {
                                      Usuario.esteUsuario.preguntasContestadas =
                                          Usuario.esteUsuario
                                                  .preguntasContestadas -
                                              1;
                                    }
                                    Usuario.esteUsuario.notifyListeners();
                                  },
                                  child: Text(
                                    "Aceptar",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            )
                          ],
                        ),
                        FlatButton(
                            onPressed: () {
                              if (!habraCambio &&
                                  Usuario.esteUsuario.preguntasContestadas <
                                      3) {
                                Usuario.esteUsuario.preguntasContestadas += 1;
                              }
                              widget.respuestaUsuario = null;

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
                ),
              ),
            );
          });
    }
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
    return ChangeNotifierProvider.value(
        value: Usuario.esteUsuario,
        child: Consumer<Usuario>(
          builder: (context, myType, child) {
            return Material(
              child: SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  resizeToAvoidBottomPadding: true,
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
                                    "Añade tus fotos",style: TextStyle(fontSize:70.sp),),
                                     Icon(LineAwesomeIcons.camera,size:90.sp ),
                              ],
                            ),
                          ),),
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
                                      File temporal = Usuario.esteUsuario
                                          .fotosPerfil[indiceNuevo];
                                      Usuario.esteUsuario
                                              .fotosPerfil[indiceNuevo] =
                                          Usuario.esteUsuario
                                              .fotosPerfil[indiceViejo];
                                      Usuario.esteUsuario
                                              .fotosPerfil[indiceViejo] =
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
                                        ? pos == indice ? 0.4 : 1
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
                              "*Presiona y arrastra para cambiar el orden de las imagenes*",style: TextStyle(fontSize:40.sp),),
                        ),

                            Flexible(
                              flex: 3,
                              fit: FlexFit.loose,
                                                                child: GestureDetector(
                                                                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AtributosDestacadosUsuario())),
                                                                                                                                  child: Container(
                                height: 150.h,
                                width: 600.w,
                                decoration: BoxDecoration(
                                  borderRadius:BorderRadius.all(Radius.circular(40)),
                                  color:Colors.green
                                  
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Siguiente",style: TextStyle(fontSize:70.sp),),
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
  File Imagen;

  FotosPerfilNuevas(this.box, this.Imagen);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FotosPerfilStateNuevas(this.box, this.Imagen);
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
    imagen = widget.Imagen ?? pictures[box];
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
  _AtributosDestacadosUsuarioState createState() => _AtributosDestacadosUsuarioState();
}

class _AtributosDestacadosUsuarioState extends State<AtributosDestacadosUsuario> {
  @override
  Widget build(BuildContext context) {
    return Provider<Usuario>(
     create: (_)=>Usuario.esteUsuario,
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
                          fit: FlexFit.loose,
                          flex: 2,
                          child:Text("Caracteristicas",style: TextStyle(fontSize:70.sp,color:Colors.black),) ),
                        Flexible(
                          flex: 15,
                          fit: FlexFit.tight,
                          child: 
                          Consumer<Usuario>(
                            builder: (context, myType, child) {
                              return   ListaDeCaracteristicasUsuarioEditar() ;
                            },
                          )
                          
                        ),
                           Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: GestureDetector(
                               onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>PantallaPreguntasPerfil())),
                                                                         
                                                                                                                                          child: Container(
                                        height: 150.h,
                                        width: 600.w,
                                        decoration: BoxDecoration(
                                          borderRadius:BorderRadius.all(Radius.circular(40)),
                                          color:Colors.green
                                          
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text("Siguiente",style: TextStyle(fontSize:50.sp),),
                                          ),
                                        ),
                                      ),
                                                                        ))
                      ],
                    ),
                  )
              
            ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*Text("Trabajo y Formacion"),
            ModificadorFormacion(),
            ModificadorTrabajo(),*/
            Divider(
              height: ScreenUtil().setHeight(100),
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


class PantallaPreguntasPerfil extends StatefulWidget {
  @override
  _PantallaPreguntasPerfilState createState() => _PantallaPreguntasPerfilState();
}

class _PantallaPreguntasPerfilState extends State<PantallaPreguntasPerfil> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:PantallaCreacionPreguntas(),
    );
  }
}


class PantallaCreacionPreguntas extends StatefulWidget {
  static int preguntasRestantes = 3;

  @override
  _PantallaCreacionPreguntasState createState() =>
      _PantallaCreacionPreguntasState();
}

class _PantallaCreacionPreguntasState extends State<PantallaCreacionPreguntas> {
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
                      child: Row(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: Colors.red),
                              height: ScreenUtil().setHeight(100),
                              child: FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Atras"))),Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: Colors.red),
                              height: ScreenUtil().setHeight(100),
                              child: FlatButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>PantallaRegistroFinal())),
                                  child: Text("Siguiente"))),
                        ],
                      ),
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
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[Text("Cuentanos sobre ti",style: TextStyle(fontSize:80.sp),),Icon(LineAwesomeIcons.pen,size: 70.sp,)]
                      ),
                      Divider(
                        height:200.h,
                      ),
                      CreadorDescripcion(),
                      FlatButton(
                        color: Colors.green,
                        onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PantalaPeticionPermisoUbicacion()));
                        }, child: Text("Registrarse"))
                    ],
                  )
                ),
              ),
            ),
        
      ),
    );
  }
}