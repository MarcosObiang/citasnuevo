import 'dart:isolate';

import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/Mensajes.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/TituloChat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<dynamic> enviarRecibirConversaciones(
    SendPort puertos, List<Map<String, dynamic>> datos) {
  ReceivePort puertoRespuestaIntermedio = new ReceivePort();
  puertos.send([puertoRespuestaIntermedio.sendPort, datos]);
  return puertoRespuestaIntermedio.first;
}

void listaConversaciones(SendPort puertoEnvio) async {
  ReceivePort puertoRespuesta = ReceivePort();
  List<Conversacion> listaConversaciones = [];
  List<Map<String, dynamic>> archivo = [];

  SendPort puertoFinal;

  puertoEnvio.send(puertoRespuesta.sendPort);

  await for (var msj in puertoRespuesta) {
    puertoFinal = msj[0];
    archivo = msj[1];
    try {
      listaConversaciones = procesarConversaciones(archivo);
    } on Exception catch (e) {
      puertoFinal.send(e);
      throw e;
    }

    if (puertoFinal != null) {
      puertoFinal.send(listaConversaciones);
    }
  }
}

List<Conversacion> procesarConversaciones(
    List<Map<String, dynamic>> conversaciones) {
  List<Map<String, dynamic>> datos = conversaciones;
  List<Conversacion> listaConversaciones = [];

  for (int a = 0; a < datos.length; a++) {
    TituloChat chatVentana;
    if (datos[a]["conversacion"]["ultimoMensaje"] != null &&
        datos[a]["conversacion"]["ultimoMensaje"] is Map<String, dynamic> &&
        datos[a]["conversacion"]["cantidadMensajesSinLeer"] != null &&
        datos[a]["conversacion"]["cantidadMensajesSinLeer"] is num &&
        datos[a]["conversacion"]["IdConversacion"] != null &&
        datos[a]["conversacion"]["IdConversacion"] is String &&
        datos[a]["conversacion"]["nombreRemitente"] != null &&
        datos[a]["conversacion"]["nombreRemitente"] is String &&
        datos[a]["conversacion"]["imagenRemitente"] != null &&
        datos[a]["conversacion"]["imagenRemitente"] is String &&
        datos[a]["conversacion"]["IdRemitente"] != null &&
        datos[a]["conversacion"]["IdRemitente"] is String &&
        datos[a]["conversacion"]["IdMensajes"] != null &&
        datos[a]["conversacion"]["IdMensajes"] is String) {
      chatVentana = new TituloChat(
        ultimoMensaje: datos[a]["conversacion"]["ultimoMensaje"],
        estadoConexion: false,
        mensajesSinLeer: datos[a]["conversacion"]["cantidadMensajesSinLeer"],
        conversacion: null,
        idConversacion: datos[a]["conversacion"]["IdConversacion"],
        estadoConversacion: " ",
        listadeMensajes: null,
        nombre: datos[a]["conversacion"]["nombreRemitente"],
        imagen: datos[a]["conversacion"]["imagenRemitente"],
        idRemitente: datos[a]["conversacion"]["IdRemitente"],
        mensajeId: datos[a]["conversacion"]["IdMensajes"],
      );

      Conversacion nueva;
      if (datos[a]["conversacion"]["ultimoMensaje"] != null &&
          datos[a]["conversacion"]["IdConversacion"] != null &&
          datos[a]["conversacion"]["cantidadMensajesSinLeer"] != null &&
          datos[a]["conversacion"]["IdRemitente"] != null &&
          datos[a]["conversacion"]["IdMensajes"] != null &&
          datos[a]["conversacion"]["imagenRemitente"] != null &&
          chatVentana != null) {
        nueva = new Conversacion(
            ultimoMensage: datos[a]["conversacion"]["ultimoMensaje"],
            grupo: datos[a]["conversacion"]["Grupo"],
            idConversacion: datos[a]["conversacion"]["IdConversacion"],
            mensajesPropiosSinLeerConversaciones: datos[a]["conversacion"]
                ["cantidadMensajesSinLeerPropios"],
            mensajesSinLeerConversaciones: datos[a]["conversacion"]
                ["cantidadMensajesSinLeer"],
            nombreRemitente: datos[a]["conversacion"]["nombreRemitente"],
            idRemitente: datos[a]["conversacion"]["IdRemitente"],
            idMensajes: datos[a]["conversacion"]["IdMensajes"],
            imagenRemitente: datos[a]["conversacion"]["imagenRemitente"],
            ventanaChat: chatVentana);
        chatVentana.conversacion = nueva;

        nueva.ventanaChat.idConversacion = nueva.idConversacion;
        chatVentana.listadeMensajes =
            procesarMensajesPrimeraVez(datos[a]["mensajes"]);

        listaConversaciones.add(nueva);
      }
    }
  }

  return listaConversaciones;
}

List<Mensajes> insertarHoras(List<Mensajes> datos) {
  List<Mensajes> lista = datos;
  if (lista != null) {
    lista.sort(
        (b, c) => b.horaMensajeFormatoDate.compareTo(c.horaMensajeFormatoDate));
  }

  DateTime cacheTiempo = lista[0].horaMensajeFormatoDate;
  int cacheDia = lista[0].horaMensajeFormatoDate.day;
  Mensajes horaSeparador;

  horaSeparador = Mensajes.separadorHora(
    horaMensaje: lista[0].horaMensaje,
    horaMensajeFormatoDate: cacheTiempo,
    idEmisor: lista[0].idEmisor,
  );
  lista.insert(0, horaSeparador);
  for (int i = 0; i < lista.length; i++) {
    if (cacheDia != lista[i].horaMensajeFormatoDate.day) {
      horaSeparador = Mensajes.separadorHora(
        horaMensajeFormatoDate: lista[i].horaMensajeFormatoDate,
        horaMensaje: lista[i].horaMensaje,
        idEmisor: lista[i].idEmisor,
      );

      cacheTiempo = lista[i].horaMensajeFormatoDate;
      cacheDia = lista[i].horaMensajeFormatoDate.day;
      lista.insert(i, horaSeparador);
    }
    //  lista[i].horaMensajeFormatoDate=null;
  }


  for(int a=0;a<lista.length;a++){
if(lista.length>a+1){
    if(lista[a].tipoMensaje=="SeparadorHora"&&lista[a+1].tipoMensaje=="SeparadorHora"){
lista.removeAt(a);
    }
}


  }

  return lista;
}

List<Mensajes> procesarMensajesPrimeraVez(Map<String, dynamic> datos) {
  List<Map<dynamic, dynamic>> dato = datos["listaMensajes"];
  String nombre = datos["nombre"];
  String idUsuario = datos["idUsuario"];
  double dimensionesImagen=datos["dimensionesImagen"];
  double dimensionesGif=datos["dimensionesGif"];

  List<Mensajes> temp = [];
  dato = dato.reversed.toList();
  if (dato != null) {
    if (idUsuario != null) {
      if (dato.length > 0) {
        for (int a = 0; a < dato.length; a++) {
          if (dato[a][("idMensaje")] != null &&
              dato[a][("idMensaje")] is String &&
              dato[a]["Tipo Mensaje"] != null &&
              dato[a][("Tipo Mensaje")] is String &&
              dato[a]["respuesta"] != null &&
              dato[a][("respuesta")] is bool &&
              dato[a]["mensajeRespuesta"] != null &&
              dato[a][("mensajeRespuesta")] is Map<dynamic, dynamic> &&
              dato[a]["mensajeLeidoRemitente"] != null &&
              dato[a][("mensajeLeidoRemitente")] is bool &&
              dato[a]["Nombre emisor"] != null &&
              dato[a][("Nombre emisor")] is String &&
              dato[a]["idConversacion"] != null &&
              dato[a][("idConversacion")] is String &&
              dato[a]["mensajeLeido"] != null &&
              dato[a][("mensajeLeido")] is bool &&
              dato[a]["identificadorUnicoMensaje"] != null &&
              dato[a][("identificadorUnicoMensaje")] is String &&
              dato[a]["idEmisor"] != null &&
              dato[a][("idEmisor")] is String &&
              dato[a]["Hora mensaje"] != null &&
              dato[a]["Mensaje"] != null) {
            if (dato[a]["Tipo Mensaje"] == "Texto" ||
                dato[a]["Tipo Mensaje"] == "Imagen" ||
                dato[a]["Tipo Mensaje"] == "Gif") {
              Mensajes mensaje = new Mensajes(
                respuestaMensaje: dato[a]["mensajeRespuesta"],
                respuesta: dato[a]["respuesta"],
                mensajeLeido: dato[a]["mensajeLeido"],
                nombreEmisor: dato[a]["Nombre emisor"],
                identificadorUnicoMensaje: dato[a]["identificadorUnicoMensaje"],
                idEmisor: dato[a]["idEmisor"],
                idConversacion: dato[a]["idConversacion"],
                mensajeLeidoRemitente: dato[a]["mensajeLeidoRemitente"],
                mensaje: dato[a]["Mensaje"],
                idMensaje: dato[a]["idMensaje"],
                horaMensajeFormatoDate: DateTime.fromMillisecondsSinceEpoch(
                    (dato[a]["Hora mensaje"])),
                horaMensaje:
                    ("${DateTime.fromMillisecondsSinceEpoch((dato[a]["Hora mensaje"])).hour}:${DateTime.fromMillisecondsSinceEpoch((dato[a]["Hora mensaje"])).minute}"),
                tipoMensaje: dato[a]["Tipo Mensaje"],
              );
              temp.add( mensaje);

           

              for (int v = 0; v < temp.length; v++) {
                if (temp[v].tipoMensaje != "SeparadorHora") {
                  if (temp[v].respuesta) {
                    if (temp[v].respuestaMensaje["tipoMensaje"] == "Texto") {
                      temp[v].widgetRespuesta = Container(
                        color: temp[v].respuestaMensaje["idEmisorMensaje"] ==
                                idUsuario
                            ? Colors.blue
                            : Colors.green,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            temp[v].respuestaMensaje["idEmisorMensaje"] ==
                                    idUsuario
                                ? Text("Yo")
                                : Text(nombre),
                            Text(temp[v].respuestaMensaje["mensaje"])
                          ],
                        ),
                      );
                    }
                    if (temp[v].respuestaMensaje["tipoMensaje"] == "Imagen") {
                      temp[v].widgetRespuesta = Container(
                        color: temp[v].respuestaMensaje["idEmisorMensaje"] ==
                                idUsuario
                            ? Colors.blue
                            : Colors.green,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            temp[v].respuestaMensaje["idEmisorMensaje"] ==
                                    idUsuario
                                ? Text("Yo")
                                : Text(nombre),
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      temp[v].respuestaMensaje["mensaje"],
                                      scale: 1,
                                    )),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.transparent,
                              ),
                              height: dimensionesImagen,
                              width: dimensionesImagen,
                            )
                          ],
                        ),
                      );
                    }
                    if (temp[v].respuestaMensaje["tipoMensaje"] == "Gif") {
                      temp[v].widgetRespuesta = Container(
                        color: temp[v].respuestaMensaje["idEmisorMensaje"] ==
                                idUsuario
                            ? Colors.blue
                            : Colors.green,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            temp[v].respuestaMensaje["idEmisorMensaje"] ==
                                    idUsuario
                                ? Text("Yo")
                                : Text(nombre),
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        temp[v].respuestaMensaje["mensaje"],
                                        scale: 1,
                                        headers: {'accept': 'image/*'})),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.transparent,
                              ),
                              height: dimensionesGif,
                              width: dimensionesGif,
                            )
                          ],
                        ),
                      );
                    }
                  }
                }
              }
            }
          } else {
            throw ExcepcionesConversaciones("no hay id usuario");
          }
        }
      }
    }
  }
     if (temp.length > 0) {
                temp = insertarHoras(temp);
                                temp = temp.reversed.toList();

          
              }

  return temp;
}
