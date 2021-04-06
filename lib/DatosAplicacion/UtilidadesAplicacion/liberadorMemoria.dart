
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorSanciones.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVerificacion.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/ListaConversaciones.dart';
import 'package:citasnuevo/base_app.dart';

class LimpiadorMemoria {

static void liberarMemoria(){
  ///eliminamosUsuario
  

  if(Valoracion.instanciar!=null){
 Valoracion.instanciar.limpiarValoraciones();
  }
  if(SolicitudConversacion.instancia!=null){
    SolicitudConversacion.instancia.cerrarEscuchadorSolicitudes();

  }
  if(Conversacion.conversaciones!=null){
Conversacion.conversaciones.cerrarConexionesConversacion();
  }

  if(ControladorCreditos.instancia!=null){
      ControladorCreditos.instancia.cerrarEscuchadorUsuario();
  }
  QueryPerfiles.cerrarConvexionesQuery();


  QueryPerfiles.listaStreamsCerrados=null;

       
        
  
        BaseAplicacion.indicePagina=0;
        Usuario.esteUsuario=null;
        Conversacion.conversaciones=null;
        ControladorCreditos.instancia=null;
        ControladorInicioSesion.instancia=null;
        Solicitudes.instancia=null;
        SolicitudConversacion.instancia=null;
        ControladorAjustes.instancia=null;
        ControladorNotificacion.instancia=null;
        SancionesUsuario.instancia=null;
        ControladorVerificacion.instanciaVerificacion=null;
        Perfiles.perfilesCitas=null;
        Valoracion.instanciar=null;
        
        

  iniciarMemoria();



}

static void iniciarMemoria(){
  Conversaciones.enPantallaConversacion=true;
  BaseAplicacion.indicePagina=0;
   QueryPerfiles.listaStreamsCerrados=new List();
      Usuario.esteUsuario=new Usuario();
        Conversacion.conversaciones=new Conversacion.instancia();
        ControladorCreditos.instancia=new ControladorCreditos();
        ControladorInicioSesion.instancia=new ControladorInicioSesion();
        Solicitudes.instancia=new Solicitudes();
        SolicitudConversacion.instancia=new SolicitudConversacion();
        ControladorAjustes.instancia=new ControladorAjustes();
        ControladorNotificacion.instancia=new ControladorNotificacion();
        SancionesUsuario.instancia=new SancionesUsuario();
        ControladorVerificacion.instanciaVerificacion=new ControladorVerificacion.instancia();
        Perfiles.perfilesCitas=new Perfiles();
        Valoracion.instanciar=new Valoracion();
}




}