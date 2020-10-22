
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import '../../ServidorFirebase/firebase_sign_up.dart';
import 'sign_up_methods.dart';
import '../../main.dart';
import 'sign_up_screen_elements.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PantallaRegistro extends StatefulWidget {
  UserCredential credencialUsuario;

  PantallaRegistro({@required this.credencialUsuario});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PantallaRegistroState();
  }
}

class PantallaRegistroState extends State<PantallaRegistro> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  DateTime date;
  int age = BotonNacimientoState.GetAge();
  String sex = "Sexo";
  String i_like = "Man";
  String campoUsuario = "Nombre";
  String campoAlias = "Alias";
  String campoClave = "Clave";
  String campoConfirmarClave = "Cofirmar clave";
  String campoEmail = "Email";
  String campoSexo = "Sex";
  String campoCitasCon = "I Like";

  void showErrorDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: <Widget>[
                Icon(LineAwesomeIcons.exclamation_triangle),
                Text("Error"),
              ],
            ),
            content: Text(ErrorMessages.errores[ErrorMessages.error]),
            actions: <Widget>[],
          );
        });
  }

  Widget build(BuildContext context) {
  
    return ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            resizeToAvoidBottomPadding: true,
            backgroundColor: Colors.tealAccent,
            body: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                
                  Divider(
                    height: ScreenUtil().setHeight(50),
                  ),
                  Text(
                    "Informacion Basica",
                    style: TextStyle(
                        fontSize: ScreenUtil()
                            .setSp(60, allowFontScalingSelf: true),
                        color: Colors.white),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromRGBO(69, 76, 80, 90),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          new EntradaTexto(
                              Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                              widget.credencialUsuario.user.displayName,
                              0,
                              false,
                              100,
                              1,
                              60),
                          Container(
                            height: ScreenUtil().setHeight(40),
                          ),
                          
                    
                       
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: ScreenUtil().setHeight(80),
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Consumer<Usuario>(
                            builder: (BuildContext context, usuario,
                                Widget child) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    flex: 7,
                                    fit: FlexFit.tight,
                                                                              child: BotonNacimiento(
                                        usuario.fechaNacimiento),
                                  ),
                                  
                                  Flexible(
                                    
                                    flex: 4,
                                    fit: FlexFit.tight,
                                    child: MostradorEdad(usuario.edad))
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: ScreenUtil().setHeight(30),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CampoSexo(),
                        campoPreferenciaSexual(),
                      ],
                    ),
                  ),
                  Divider(
                    height: ScreenUtil().setHeight(40),
                  ),
                  Center(child:   FlatButton(
                    color: Colors.blue,
                    child: Row(
                      children:[
                        Icon(Icons.arrow_back),Text("Siguiente")
                      ]
                    ),
                    
                    onPressed: ()=>   Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PantallaEdicionPerfil(),)))),
                  Container(
                    height: ScreenUtil().setHeight(30),
                  ),
                  FlatButton(
                    child: Row(
                      children:[
                        Icon(Icons.arrow_back),Text("Atras")
                      ]
                    ),
                    
                    onPressed: ()=>   Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PantallaDeInicio(),)))
              
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class sign_up_confirm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return sign_up_confirm_state();
  }
}

class sign_up_confirm_state extends State<sign_up_confirm> {
  String coche = "Automoviles";
  String videojuegos = "VideoJuegos";
  String cine = "Cine";
  String bricolaje = "Manualidades y Bricolaje";
  String comida = "Comida";
  String moda = "Moda y Belleza";
  String animales = "Aniimales";
  String musica = "Musica";
  String naturaleza = "Naturaleza";
  String ciencia = "Ciencia y Tecnologia";
  String politica = "Politica y Sociedad";
  String viajes = "Viajes";
  String fiesta = "Fiesta";
  String vidasocial = "Vida Social";
  String fittnes = "Deporte y Fittness";
  String salud = "Salud";
  String virtudes = "Mis Virtudes";
  String defectos = "Mis Defectos";
  String nomegusta = "No me Gusta";
  String megusta = "Me Gusta";
  String megustadelagente = "¿Que te gusta en una persona?";
  String nomegustadelagente = "¿Que no te gusta en una persona?";
  String descripcion = "Descripcion";
  static String descripcion_fotos_perfil = "Add pictures to your profile";
  static String seleccionar_modo = "What do you preffer";
  static String textocitas = "Cita";
  static String textoaigos = "Amistad";
  static String texto_ambos = "Ambos (Predeterminado)";
  static final GlobalKey claveScaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,
      child: SafeArea(
        child: Scaffold(
          key: claveScaffold,
          backgroundColor: Color.fromRGBO(255, 78, 132, 100),
          body: Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            child: SingleChildScrollView(
              child: Container(
                height: ScreenUtil().setHeight(5000),
                child: Column(
                  children: <Widget>[
                    Text("Add pictures for your date profile"),
                    Consumer<Usuario>(
                      builder: (BuildContext context, usuario, Widget child) {
                        if (usuario.fotosPerfil[0] != null) {
                          print(usuario);
                        }
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color.fromRGBO(69, 76, 80, 90),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                               
                                ],
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: ScreenUtil().setHeight(50),
                    ),
                    Container(child: ElegirModo("Hola", "Hombre ", " Mujer")),
                    Container(
                      height: ScreenUtil().setHeight(50),
                    ),
                    Text("Cuentanos un poco sobre ti"),
                    EntradaTexto(Icon(LineAwesomeIcons.comment), descripcion, 5,
                        false, 800, 9, 500),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.red),
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Atras"))),
                        Container(
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        pantallaRegistroTres()),
                              ),
                              child: Text("Siguiente"),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// TODO: implement build

class pantallaRegistroTres extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return pantallaRegistroTresState();
  }
}

class pantallaRegistroTresState extends State<pantallaRegistroTres> {
  String coche = "Automoviles";
  String videojuegos = "VideoJuegos";
  String cine = "Cine";
  String bricolaje = "Manualidades y Bricolaje";
  String comida = "Comida";
  String moda = "Moda y Belleza";
  String animales = "Aniimales";
  String musica = "Musica";
  String naturaleza = "Naturaleza";
  String ciencia = "Ciencia y Tecnologia";
  String politica = "Politica y Sociedad";
  String viajes = "Viajes";
  String fiesta = "Fiesta";
  String vidasocial = "Vida Social";
  String fittnes = "Deporte y Fittness";
  String salud = "Salud";
  String virtudes = "Mis Virtudes";
  String defectos = "Mis Defectos";
  String nomegusta = "No me Gusta";
  String megusta = "Me Gusta";
  String megustadelagente = "¿Que te gusta en una persona?";
  String nomegustadelagente = "¿Que no te gusta en una persona?";
  String descripcion = "Descripcion";
  static String descripcion_fotos_perfil = "Add pictures to your profile";
  static String seleccionar_modo = "What do you preffer";
  static String textocitas = "Cita";
  static String textoaigos = "Amistad";
  static String texto_ambos = "Ambos (Predeterminado)";
  static final GlobalKey claveScaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,
      child: SafeArea(
        child: Scaffold(
          key: claveScaffold,
          backgroundColor: Color.fromRGBO(255, 78, 132, 100),
          body: Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.red),
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Atras"))),
                        Container(
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        pantallaRegistroCuatro()),
                              ),
                              child: Text("Siguiente"),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class pantallaRegistroCuatro extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return pantallaRegistroCuatroState();
  }
}

class pantallaRegistroCuatroState extends State<pantallaRegistroCuatro> {
  String coche = "Automoviles";
  String videojuegos = "VideoJuegos";
  String cine = "Cine";
  String bricolaje = "Manualidades y Bricolaje";
  String comida = "Comida";
  String moda = "Moda y Belleza";
  String animales = "Aniimales";
  String musica = "Musica";
  String naturaleza = "Naturaleza";
  String ciencia = "Ciencia y Tecnologia";
  String politica = "Politica y Sociedad";
  String viajes = "Viajes";
  String fiesta = "Fiesta";
  String vidasocial = "Vida Social";
  String fittnes = "Deporte y Fittness";
  String salud = "Salud";
  String virtudes = "Mis Virtudes";
  String defectos = "Mis Defectos";
  String nomegusta = "No me Gusta";
  String megusta = "Me Gusta";
  String megustadelagente = "¿Que te gusta en una persona?";
  String nomegustadelagente = "¿Que no te gusta en una persona?";
  String descripcion = "Descripcion";
  static String descripcion_fotos_perfil = "Add pictures to your profile";
  static String seleccionar_modo = "What do you preffer";
  static String textocitas = "Cita";
  static String textoaigos = "Amistad";
  static String texto_ambos = "Ambos (Predeterminado)";
  static final GlobalKey claveScaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,
      child: SafeArea(
        child: Scaffold(
          key: claveScaffold,
          backgroundColor: Color.fromRGBO(255, 78, 132, 100),
          body: Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            child: SingleChildScrollView(
              child: Container(
                height: ScreenUtil().setHeight(4000),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setHeight(200),
                      child: Center(
                        child: Text(
                          "Cuentanos mas sobre ti",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(120),
                          ),
                        ),
                      ),
                    ),
                    Consumer<Usuario>(builder: (context, usuario, child) {
                      return ListaDeCaracteristicasUsuario();
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.red),
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Atras"))),
                        Container(
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        pantallaRegistroCinco()),
                              ),
                              child: Text("Siguiente"),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class pantallaRegistroCinco extends StatefulWidget {
  static int preguntasRestantes=3;
  @override
  _pantallaRegistroCincoState createState() => _pantallaRegistroCincoState();
}

class _pantallaRegistroCincoState extends State<pantallaRegistroCinco> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
            color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                
                Container(
                  
                  child: Consumer<Usuario>(
                    builder:
                        (BuildContext context, Usuario user, Widget child) {
                      return Column(
                        children: <Widget>[
                          Container(
                    height: ScreenUtil().setHeight(200),
                    child: Center(
                        child: Text(
                     pantallaRegistroCinco.preguntasRestantes!=0? "Elige ${pantallaRegistroCinco.preguntasRestantes} Preguntas Personales":"Has respondido el maximo",
                      style: TextStyle(fontSize: ScreenUtil().setSp(90)),
                    ))),
                          Container(
                            height: ScreenUtil().setHeight(1400),
                            child: ListView(
                              children: <Widget>[
                                PreguntaQueBuscasEnLaGente(),
                                PreguntaQueOdiasDeLaGente(),
                                PreguntaTuRecetaDeFelicidad(),
                                PreguntaSiQuedaraUnDiaDeVida(),
                                PreguntaQueTipoDeMusicaTeGusta(),
                                PreguntaEnQueCreesQueEresBueno(),
                                PreguntaQueEsLoQueMasValoras(),
                                PreguntaLaGenteDiceQueEres(),
                                PreguntaQueTeHaceReir(),
                                PreguntaCitaPErfecta(),
                                PReguntaCancionFavorita(),
                                PreguntaUnaVerdadYUnaMentira(),
                                PreguntaPorQueTeHariasFamoso(),
                                PreguntaSiFueraUnVillanooSeria(),
                                PreguntaSiFuerasUnHeroeSerias(),
                                PreguntaComidaRestoDeMiVida(),
                                PReguntaNosLLEvamosBienSi(),
                                PregutnaAnecdota(),
                                PReguntaBorrachoSoy(),
                                PreguntaPeliculaRecomendada(),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.red),
                        height: ScreenUtil().setHeight(150),
                        child: FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Atras"))),
                    Container(
                      color: Colors.green,
                        height: ScreenUtil().setHeight(150),
                        child: FlatButton(
                          onPressed: () => Usuario.submit(context),
                          child: Text("Siguiente"),
                        )),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
