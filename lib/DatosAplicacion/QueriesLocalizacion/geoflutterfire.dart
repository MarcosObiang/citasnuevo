import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/point.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/collection.dart';

class Geoflutterfire {
  Geoflutterfire();

  GeoFireCollectionRef collection({@required Query collectionRef}) {
    return GeoFireCollectionRef(collectionRef);
  }

  GeoFirePoint point({@required double latitude, @required double longitude}) {
    return GeoFirePoint(latitude, longitude);
  }
}
