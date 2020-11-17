
import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/TituloChat.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:citasnuevo/InterfazUsuario/Conversaciones/Mensajes.dart";
import 'Usuario.dart';







class Conversacion extends ChangeNotifier {
  static FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  static Conversacion conversaciones = new Conversacion.instancia();
  static int cantidadMensajesNoLeidos = 0;
  String idConversacion;
  String nombreRemitente;
  bool estadoConexionConversacion = false;
  String idRemitente;
  String idMensajes;
  String imagenRemitente;
  bool grupo;
  int mensajesSinLeerConversaciones=0;
  int mensajesPropiosSinLeerConversaciones=0;
  TituloChat ventanaChat;
  
  Map<String, dynamic> ultimoMensage = new Map();
   List<Conversacion> listaDeConversaciones = new List();
  List<String> estadosEscribiendoConversacion = [
    " ",
    "Escribiendo",
    "Grabando Audio"
  ];



static void calcularCantidadMensajesSinLeer(){
  int mensajesSInLeerTemporal=0;
  for(Conversacion conversacion in conversaciones.listaDeConversaciones ){

   mensajesSInLeerTemporal=mensajesSInLeerTemporal+conversacion.ventanaChat.mensajesSinLeer;

  }
  cantidadMensajesNoLeidos=mensajesSInLeerTemporal;
}

  

  void escucharMensajes() {
    Mensajes nuevo;
    baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .orderBy("Hora mensaje", descending: true)
        .snapshots()
        .listen((dato) {


  if(dato.docChanges!=null)  {      
      for (int a = 0; a < dato.docChanges.length; a++) {
        if (dato.docChanges[a].type == DocumentChangeType.added) {
          for (int i = 0;
              i < conversaciones.listaDeConversaciones.length;
              i++) {
            if (conversaciones.listaDeConversaciones[i].idMensajes ==
                dato.docChanges[a].doc.get("idMensaje")) {
              if (dato.docChanges[a].doc.get("Tipo Mensaje") == "Texto" ||
                  dato.docChanges[a].doc.get("Tipo Mensaje") == "Imagen" ||
                  dato.docChanges[a].doc.get("Tipo Mensaje") == "Gif") {
                nuevo = new Mensajes(
                  mensajeLeidoRemitente:
                      dato.docChanges[a].doc.get("mensajeLeidoRemitente"),
                  nombreEmisor: dato.docChanges[a].doc.get("Nombre emisor"),
                  idConversacion: dato.docChanges[a].doc.get("idConversacion"),
                  mensajeLeido: dato.docChanges[a].doc.get("mensajeLeido"),
                  tipoMensaje: dato.docChanges[a].doc.get("Tipo Mensaje"),
                  idMensaje: dato.docChanges[a].doc.get("idMensaje"),
                  identificadorUnicoMensaje:
                      dato.docChanges[a].doc.get("identificadorUnicoMensaje"),
                  idEmisor: dato.docChanges[a].doc.get("idEmisor"),
                  horaMensaje:
                      (dato.docChanges[a].doc.get("Hora mensaje")).toDate(),
                  mensaje: dato.docChanges[a].doc.get("Mensaje"),
                );

                
              }
              if (dato.docChanges[a].doc.get("Tipo Mensaje") == "Audio") {
                nuevo = new Mensajes.Audio(
                  mensajeLeidoRemitente:
                      dato.docChanges[a].doc.get("mensajeLeidoRemitente"),
                  duracionMensaje: dato.docChanges[a].doc.get("duracion"),
                  identificadorUnicoMensaje:
                      dato.docChanges[a].doc.get("identificadorUnicoMensaje"),
                  nombreEmisor: dato.docChanges[a].doc.get("Nombre emisor"),
                  mensajeLeido: dato.docChanges[a].doc.get("mensajeLeido"),
                  tipoMensaje: dato.docChanges[a].doc.get("Tipo Mensaje"),
                  idMensaje: dato.docChanges[a].doc.get("idMensaje"),
                  idConversacion: dato.docChanges[a].doc.get("idConversacion"),
                  idEmisor: dato.docChanges[a].doc.get("idEmisor"),
                  horaMensaje:
                      (dato.docChanges[a].doc.get("Hora mensaje")).toDate(),
                  mensaje: dato.docChanges[a].doc.get("Mensaje"),
                );
              }

            

              if (conversaciones
                      .listaDeConversaciones[i].ventanaChat.listadeMensajes ==
                  null) {
                conversaciones.listaDeConversaciones[i].ventanaChat
                    .listadeMensajes = new List();

                conversaciones
                    .listaDeConversaciones[i].ventanaChat.listadeMensajes
                    .add(nuevo);
              } else {
                conversaciones
                        .listaDeConversaciones[i].ventanaChat.listadeMensajes =
                    List.from(conversaciones
                        .listaDeConversaciones[i].ventanaChat.listadeMensajes)
                      ..add(nuevo);
              }
              ControladorNotificacion.controladorNotificacion.sumarMensajeNuevoEnNotificacion(dato.docChanges[a].doc);

              notifyListeners();
              calcularCantidadMensajesSinLeer();
            }
          }
        }

        if (dato.docChanges[a].type == DocumentChangeType.modified) {
          String idConversacion = dato.docChanges[a].doc.get("idConversacion");
          String idMensajeUnico =
              dato.docChanges[a].doc.get("identificadorUnicoMensaje");
      

          for (int s = 0;
              s < conversaciones.listaDeConversaciones.length;
              s++) {
            if (conversaciones.listaDeConversaciones[s].idConversacion ==
                idConversacion) {
              for (int x = 0;
                  x <
                      conversaciones.listaDeConversaciones[s].ventanaChat
                          .listadeMensajes.length;
                  x++) {
                if (conversaciones.listaDeConversaciones[s].ventanaChat
                        .listadeMensajes[x].identificadorUnicoMensaje ==
                    idMensajeUnico) {
                  conversaciones.listaDeConversaciones[s].ventanaChat
                          .listadeMensajes[x].mensajeLeidoRemitente =
                      dato.docChanges[a].doc.get("mensajeLeidoRemitente");
                }
                notifyListeners();
              }
            }
          }
        }
      }}
    });
  }


  

  void escucharEstadoConversacion() async {
    print("Escuchando estado");
    await baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .get()
        .then((dato) {
      for (int i = 0; i < dato.docs.length; i++) {
        for (int b = 0; b < listaDeConversaciones.length; b++) {
          if (dato.docs[i].get("IdConversacion") ==
              listaDeConversaciones[b].idConversacion) {
            print(listaDeConversaciones[b].idConversacion);
            if (dato.docs[i].get("Escribiendo") == true) {
              print("Escuchando estado");
              listaDeConversaciones[b].ventanaChat.estadoConversacion =
                  estadosEscribiendoConversacion[1];
              notifyListeners();
            }
            if (dato.docs[i].get("Escribiendo") == false) {
              print("No Escuchando estado");
              listaDeConversaciones[b].ventanaChat.estadoConversacion =
                  estadosEscribiendoConversacion[0];
              notifyListeners();
            }
            print(listaDeConversaciones[b].idConversacion);
            if (dato.docs[i].get("Conectado") == true) {
              print("Escuchando conexion");
              listaDeConversaciones[b].ventanaChat.estadoConexion = true;
              notifyListeners();
            }
            if (dato.docs[i].get("Conectado") == false) {
              print("No Escuchando conexion");
              listaDeConversaciones[b].ventanaChat.estadoConexion = false;
              notifyListeners();
            }
          }
        }
      }
    }).then((value) {
      baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("estados conversacion")
          .snapshots()
          .listen((dato) {
        for (int i = 0; i < dato.docs.length; i++) {
          for (int b = 0; b < listaDeConversaciones.length; b++) {
            if (dato.docs[i].get("IdConversacion") ==
                listaDeConversaciones[b].idConversacion) {
              print(listaDeConversaciones[b].idConversacion);
              if (dato.docs[i].get("Escribiendo") == true) {
                print("Escuchando estado");
                listaDeConversaciones[b].ventanaChat.estadoConversacion =
                    estadosEscribiendoConversacion[1];
                notifyListeners();
              }
              if (dato.docs[i].get("Escribiendo") == false) {
                print("No Escuchando estado");
                listaDeConversaciones[b].ventanaChat.estadoConversacion =
                    estadosEscribiendoConversacion[0];
                notifyListeners();
              }
              print(listaDeConversaciones[b].idConversacion);
              if (dato.docs[i].get("Conectado") == true) {
                print("Escuchando conexion");
                listaDeConversaciones[b].ventanaChat.estadoConexion = true;
                notifyListeners();
              }
              if (dato.docs[i].get("Conectado") == false) {
                print("No Escuchando conexion");
                listaDeConversaciones[b].ventanaChat.estadoConexion = false;
                notifyListeners();
              }
            }
          }
        }
      });
    });
  }

  void obtenerConversaciones() async {
    await baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .get()
        .then((datos) async {
      for (int a = 0; a < datos.docs.length; a++) {
        print("${datos.docs.length} total de conversaciones");
        TituloChat chatVentana = new TituloChat(
          ultimoMensaje: datos.docs[a].get("ultimoMensaje"),
          estadoConexion: estadoConexionConversacion,
        mensajesSinLeer:datos.docs[a].get("cantidadMensajesSinLeer") ,
          conversacion: null,
          idConversacion: datos.docs[a].get("IdConversacion"),
          estadoConversacion: " ",
          listadeMensajes: null,
          nombre: datos.docs[a].get("nombreRemitente"),
          imagen: datos.docs[a].get("imagenRemitente"),
          idRemitente: datos.docs[a].get("IdRemitente"),
          mensajeId: datos.docs[a].get("IdMensajes"),
        );

        Conversacion nueva = new Conversacion(
            ultimoMensage: datos.docs[a].get("ultimoMensaje"),
            grupo: datos.docs[a].get("Grupo"),
            idConversacion: datos.docs[a].get("IdConversacion"),
            mensajesPropiosSinLeerConversaciones: datos.docs[a].get("cantidadMensajesSinLeerPropios") ,
            mensajesSinLeerConversaciones: datos.docs[a].get("cantidadMensajesSinLeer"),
            nombreRemitente: datos.docs[a].get("nombreRemitente"),
            idRemitente: datos.docs[a].get("IdRemitente"),
            idMensajes: datos.docs[a].get("IdMensajes"),
            imagenRemitente: datos.docs[a].get("imagenRemitente"),
            ventanaChat: chatVentana);
        chatVentana.conversacion = nueva;

        print("${nueva.idConversacion}este es mi compañero");
        nueva.ventanaChat.idConversacion = nueva.idConversacion;

        print(
            "${nueva.ventanaChat.idConversacion}este es miffff compañero en el chat");

        conversaciones.listaDeConversaciones =
            List.from(conversaciones.listaDeConversaciones)..add(nueva);
      }
    }).then((value) async {
      calcularCantidadMensajesSinLeer();
      escucharEstadoConversacion();
      escucharConversaciones();
    });
  }

  void escucharConversaciones() {
  
   
    baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .orderBy("Hora", descending: true)
        .snapshots()
        .listen((datos) {
      /// Al hacerse cualquier cabio en la coleccion conversaciones, ya sea añadir,alterar o eliminar conversaciones, son escuchadas por este metodo,
      /// para detectar eliminaciones comparamos las conversaciones existentes con las de la nube, si alguna falta en la nube se eliina en el dispositivo
      
 for(int s=0;s<datos.docChanges.length;s++){
       if(datos.docChanges[s].type==DocumentChangeType.removed){
         for(int z=0;z<Conversacion.conversaciones.listaDeConversaciones.length;z++){
           if(datos.docChanges[s].doc.get("IdConversacion")==Conversacion.conversaciones.listaDeConversaciones[z].idConversacion){
             Conversacion.conversaciones.listaDeConversaciones.removeAt(z);
    
           }
         }
       }
     }



      for (int a = 0; a <datos.docs.length; a++) {
          bool existeConversacion=false;
    if(Conversacion.conversaciones.listaDeConversaciones!=null){
for(int k=0;k<datos.docs.length;k++){
  for(int g=0;g<Conversacion.conversaciones.listaDeConversaciones.length;g++){


    if(datos.docs[k].get("IdConversacion")==Conversacion.conversaciones.listaDeConversaciones[g].idConversacion){
           if (Conversacion
                    .conversaciones.listaDeConversaciones[g].ultimoMensage !=
                datos.docs[k].get("ultimoMensaje")) {
              Conversacion.conversaciones.listaDeConversaciones[g]
                  .ultimoMensage = datos.docs[k].get("ultimoMensaje");
              Conversacion.conversaciones.listaDeConversaciones[g].ventanaChat
                      .ultimoMensaje =
                  Conversacion
                      .conversaciones.listaDeConversaciones[g].ultimoMensage;
            }
            if (Conversacion
                    .conversaciones.listaDeConversaciones[g].nombreRemitente !=
                datos.docs[k].get("nombreRemitente")) {
              Conversacion.conversaciones.listaDeConversaciones[g]
                  .nombreRemitente = datos.docs[k].get("nombreRemitente");
              Conversacion.conversaciones.listaDeConversaciones[g].ventanaChat
                      .nombre =
                  Conversacion
                      .conversaciones.listaDeConversaciones[g].nombreRemitente;
            }

            if (Conversacion
                    .conversaciones.listaDeConversaciones[g].imagenRemitente !=
                datos.docs[k].get("imagenRemitente")) {
              Conversacion.conversaciones.listaDeConversaciones[g]
                  .imagenRemitente = datos.docs[k].get("imagenRemitente");
              Conversacion.conversaciones.listaDeConversaciones[g].ventanaChat
                      .imagen =
                  Conversacion
                      .conversaciones.listaDeConversaciones[g].imagenRemitente;
            }
                   if (Conversacion
                    .conversaciones.listaDeConversaciones[g].mensajesSinLeerConversaciones !=
                datos.docs[k].get("cantidadMensajesSinLeer")) {
              Conversacion.conversaciones.listaDeConversaciones[g]
                  .mensajesSinLeerConversaciones = datos.docs[k].get("cantidadMensajesSinLeer");
              Conversacion.conversaciones.listaDeConversaciones[g].ventanaChat
                      .mensajesSinLeer =
                  Conversacion
                      .conversaciones.listaDeConversaciones[g].mensajesSinLeerConversaciones;
            }

    }
  }
}
    }
      
    
          
       

            Conversacion.conversaciones.notifyListeners();
         
        

for(int z=0;z<Conversacion.conversaciones.listaDeConversaciones.length;z++){
  if(Conversacion.conversaciones.listaDeConversaciones[z].idConversacion==datos.docs[a].get("IdConversacion")){
    existeConversacion=true;
  }
}

        if(!existeConversacion){

      
          TituloChat chatVentana = new TituloChat(
            ultimoMensaje: datos.docs[a].get("ultimoMensaje"),
            estadoConexion: estadoConexionConversacion,
            mensajesSinLeer:  datos.docs[a].get("cantidadMensajesSinLeer"),
            conversacion: null,
            idConversacion: datos.docs[a].get("IdConversacion"),
            estadoConversacion: " ",
            listadeMensajes: null,
            nombre: datos.docs[a].get("nombreRemitente"),
            imagen: datos.docs[a].get("imagenRemitente"),
            idRemitente: datos.docs[a].get("IdRemitente"),
            mensajeId: datos.docs[a].get("IdMensajes"),
          );

          Conversacion nueva = new Conversacion(
              grupo: datos.docs[a].get("Grupo"),
              mensajesPropiosSinLeerConversaciones:  datos.docs[a].get("cantidadMensajesSinLeerPropios"),
              mensajesSinLeerConversaciones: datos.docs[a].get("cantidadMensajesSinLeer"),
              ultimoMensage: datos.docs[a].get("ultimoMensaje"),
              idConversacion: datos.docs[a].get("IdConversacion"),
              nombreRemitente: datos.docs[a].get("nombreRemitente"),
              idRemitente: datos.docs[a].get("IdRemitente"),
              idMensajes: datos.docs[a].get("IdMensajes"),
              imagenRemitente: datos.docs[a].get("imagenRemitente"),
              ventanaChat: chatVentana);
          chatVentana.conversacion = nueva;

          nueva.ventanaChat.idConversacion = nueva.idConversacion;

          conversaciones.listaDeConversaciones =
              List.from(conversaciones.listaDeConversaciones)..add(nueva);
      
      }
      }

    
    });
  }

  static Future<int> eliminarConversaciones(
      String idConversacion, String idRemitente, String idMensaje) async{
        int estadoOperacion;
    print(idConversacion);
    print(idRemitente);
    WriteBatch opceracionEliminacion = baseDatosRef.batch();
    DocumentReference referenciaConversacionEnLocal = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);
    DocumentReference referenciaConversacionEnRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);
    DocumentReference referenciaEstadoConversacionEnLocal = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .doc(idConversacion);
    DocumentReference referenciaEstadoConversacionEnRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("estados conversacion")
        .doc(idConversacion);


    opceracionEliminacion.delete(referenciaConversacionEnLocal);
    opceracionEliminacion.delete(referenciaEstadoConversacionEnLocal);
    opceracionEliminacion.delete(referenciaConversacionEnRemitente);
    opceracionEliminacion.delete(referenciaEstadoConversacionEnRemitente);
  await  opceracionEliminacion.commit().then((value){
      estadoOperacion=0;
      for(int i=0;i<Conversacion.conversaciones.listaDeConversaciones.length;i++){
if(Conversacion.conversaciones.listaDeConversaciones[i].idConversacion==idConversacion){
  Conversacion.conversaciones.listaDeConversaciones.removeAt(i);
  Conversacion.conversaciones.notifyListeners();
}

      }
    }).catchError((onError){
      print(onError);
      estadoOperacion=1;
    });
    Conversacion.conversaciones.notifyListeners();
    return estadoOperacion;

    
    

  }

  Conversacion(
      {@required this.grupo,
      @required this.ultimoMensage,
      @required this.mensajesPropiosSinLeerConversaciones,
      @required this.idConversacion,
      @required this.mensajesSinLeerConversaciones,
      @required this.nombreRemitente,
      @required this.idRemitente,
      @required this.idMensajes,
      @required this.imagenRemitente,
      @required this.ventanaChat});

  Conversacion.instancia();
}
