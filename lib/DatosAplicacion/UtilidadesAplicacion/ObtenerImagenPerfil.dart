
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';

class ObtenerImagenPerfl{
static ObtenerImagenPerfl instancia= new ObtenerImagenPerfl();



   String obtenerImagenUsuarioLocal() {
    bool imagenAdquirida = false;
    String imagen;
    if (Usuario.esteUsuario.imagenUrl1["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl1["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl2["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl2["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl3["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl3["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl4["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl4["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl5["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl5["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl6["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl6["Imagen"];
      imagenAdquirida = true;
    }
    return imagen;
  }
}