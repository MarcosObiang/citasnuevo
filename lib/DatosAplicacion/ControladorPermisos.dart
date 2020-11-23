import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

enum EstadosPermisos {
  permisoDenegadoPermanente,
  permisoDenegado,
  permisoConcedido,
}

class ControladorPermisos with ChangeNotifier {
  static ControladorPermisos instancia = new ControladorPermisos();
  bool permisoCamara;
  bool permisoUbicacion;
  bool permisoAlmacenamiento;
  bool permisoMicrofono;
  bool get getPermisoCamara => permisoCamara;

  set setPermisoCamara(bool permisoCamara) =>
      this.permisoCamara = permisoCamara;

  bool get getPermisoUbicacion => permisoUbicacion;

  set setPermisoUbicacion(bool permisoUbicacion) =>
      this.permisoUbicacion = permisoUbicacion;

  bool get getPermisoAlmacenamiento => permisoAlmacenamiento;

  set setPermisoAlmacenamiento(bool permisoAlmacenamiento) =>
      this.permisoAlmacenamiento = permisoAlmacenamiento;

  bool get getPermisoMicrofono => permisoMicrofono;

  set setPermisoMicrofono(bool permisoMicrofono) =>
      this.permisoMicrofono = permisoMicrofono;

  ///ComprobarUbicacion

  Future<EstadosPermisos> comprobarPermisoUbicacion() async {
    Permission tienePermisoUbicacion = Permission.location;

    EstadosPermisos tienePermiso;

    PermissionStatus statusPermisoUbicaion = await tienePermisoUbicacion.status;

       if (statusPermisoUbicaion.isUndetermined) {
    await  Permission.location.request().then((value) {
      statusPermisoUbicaion=value;
        if (value.isDenied) {
          this.setPermisoUbicacion = false;
          tienePermiso = EstadosPermisos.permisoDenegado;
        }
      });
    }

    if (statusPermisoUbicaion.isDenied) {
    await  Permission.location.request().then((value) {
      statusPermisoUbicaion=value;
        if (value.isDenied) {
          this.setPermisoUbicacion = false;
          tienePermiso = EstadosPermisos.permisoDenegado;
        }
      });
    }
    if (statusPermisoUbicaion.isPermanentlyDenied) {
    await  Permission.location.request().then((value) {
       statusPermisoUbicaion=value;
        if (value.isDenied) {
          tienePermiso = EstadosPermisos.permisoDenegadoPermanente;
          this.setPermisoUbicacion = false;
        }
      });
    }
    if (statusPermisoUbicaion.isGranted) {
      tienePermiso = EstadosPermisos.permisoConcedido;
      this.setPermisoUbicacion = true;
    }
    return tienePermiso;
  }

  ///ComprobarAlmacenamiento
  Future<EstadosPermisos> comprobarPermisoAlmacenamiento() async {
    Permission tienePermisoAlmacenamiento = Permission.storage;
    EstadosPermisos tienePermiso;
    PermissionStatus statusPermisoAlmacenamiento =
        await tienePermisoAlmacenamiento.status;
               if (statusPermisoAlmacenamiento.isUndetermined) {
    await  Permission.location.request().then((value) {
      statusPermisoAlmacenamiento=value;
        if (value.isDenied) {
          this.setPermisoUbicacion = false;
          tienePermiso = EstadosPermisos.permisoDenegado;
        }
      });
    }

    if (statusPermisoAlmacenamiento.isDenied) {
      Permission.storage.request().then((value) {
        statusPermisoAlmacenamiento=value;
        if (value.isDenied) {
          tienePermiso = EstadosPermisos.permisoDenegado;
          this.setPermisoAlmacenamiento = false;
        }
      });
    }
    if (statusPermisoAlmacenamiento.isPermanentlyDenied) {
      Permission.storage.request().then((value) {
         statusPermisoAlmacenamiento=value;
        if (value.isPermanentlyDenied) {
          tienePermiso = EstadosPermisos.permisoDenegadoPermanente;
          this.setPermisoAlmacenamiento = false;
        }
      });
    }
    if (statusPermisoAlmacenamiento.isGranted) {
      tienePermiso = EstadosPermisos.permisoConcedido;
      this.setPermisoAlmacenamiento = true;
    }
    return tienePermiso;
  }

  ///ComprobarCamara

  Future<EstadosPermisos> comprobarPermisoCamara() async {
    EstadosPermisos tienePermiso;
    Permission tienePermisoCamara = Permission.camera;

    PermissionStatus statusPermisoCamara = await tienePermisoCamara.status;
                 if (statusPermisoCamara.isUndetermined) {
    await  Permission.location.request().then((value) {
      statusPermisoCamara=value;
        if (value.isDenied) {
          this.setPermisoUbicacion = false;
          tienePermiso = EstadosPermisos.permisoDenegado;
        }
      });
    }

    if (statusPermisoCamara.isDenied) {
      Permission.camera.request().then((value) {
        if (value.isDenied) {
          statusPermisoCamara=value;
          tienePermiso = EstadosPermisos.permisoDenegado;
          this.setPermisoCamara = false;
        }
      });
    }
    if (statusPermisoCamara.isPermanentlyDenied) {
      Permission.camera.request().then((value) {
            statusPermisoCamara=value;
        if (value.isPermanentlyDenied) {
          tienePermiso = EstadosPermisos.permisoDenegadoPermanente;
          this.setPermisoCamara = false;
        }
      });
    }
    if (statusPermisoCamara.isGranted) {
      tienePermiso = EstadosPermisos.permisoConcedido;
      this.setPermisoCamara = true;
    }
    return tienePermiso;
  }

  ///ComprobarMicrofono

  Future<EstadosPermisos> comprobarPermisoMicrofono() async {
    EstadosPermisos tienePermiso;
    Permission tienePermisoMicrofono = Permission.microphone;

    PermissionStatus statusPermisoMicrofono =
        await tienePermisoMicrofono.status;
                       if (statusPermisoMicrofono.isUndetermined) {
    await  Permission.location.request().then((value) {
      statusPermisoMicrofono=value;
        if (value.isDenied) {
          this.setPermisoUbicacion = false;
          tienePermiso = EstadosPermisos.permisoDenegado;
        }
      });
    }

    if (statusPermisoMicrofono.isDenied) {
      Permission.microphone.request().then((value) {
            statusPermisoMicrofono=value;
        if (value.isDenied) {
          tienePermiso = EstadosPermisos.permisoDenegado;
          this.setPermisoMicrofono = false;
        }
      });
    }
    if (statusPermisoMicrofono.isPermanentlyDenied) {
      Permission.microphone.request().then((value) {
        statusPermisoMicrofono=value;
        if (value.isDenied) {
          tienePermiso = EstadosPermisos.permisoDenegadoPermanente;
          this.setPermisoMicrofono = false;
        }
      });
    }
    if (statusPermisoMicrofono.isGranted) {
      tienePermiso = EstadosPermisos.permisoConcedido;
      this.setPermisoMicrofono = true;
    }
    return tienePermiso;
  }
}
