import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

const Map<String,dynamic> _kProfileCreatorMap = {
  "Alcohol": 0,
  "Busco": 0,
  "Complexion": 0,
  "Hijos": 0,
  "Mascotas": 0,
  "Politca": 0,
  "Que viva con": 0,
  "Tabaco": 0
};





 Map<String,dynamic> kUserCreatorMockData={
  "IMAGENPERFIL1":{"Imagen":"vacio","hash":"vacio","index":-1,"pictureName":"IMAGENPERFIL1","removed":false},
  "IMAGENPERFIL2":{"Imagen":"vacio","hash":"vacio","index":-1,"pictureName":"IMAGENPERFIL2","removed":false},
  "IMAGENPERFIL3":{"Imagen":"vacio","hash":"vacio","index":-1,"pictureName":"IMAGENPERFIL3","removed":false},
  "IMAGENPERFIL4":{"Imagen":"vacio","hash":"vacio","index":-1,"pictureName":"IMAGENPERFIL4","removed":false},
  "IMAGENPERFIL5":{"Imagen":"vacio","hash":"vacio","index":-1,"pictureName":"IMAGENPERFIL5","removed":false},
  "IMAGENPERFIL6":{"Imagen":"vacio","hash":"vacio","index":-1,"pictureName":"IMAGENPERFIL6","removed":false},
  "filtros usuario":_kProfileCreatorMap,"Descripcion":""
  
};

const kProfileCharacteristics_LookingFor_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Relacion seria": "Relacion seria"},
  {"Lo que surja": "Lo que surja"},
  {"Algo casual": "Algo casual"},
  {"No lo se": "No lo se"}
];

const kProfileCharacteristics_BodyType_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Normal": "Normal"},
  {"Atletica": "Atletica"},
  {"Talla Grande": "Talla Grande"},
  {"Delgado": "Delgado"}
];

const kProfileCharacteristics_Children_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Algun dia": "Algun día"},
  {"Nunca": "Nunca"},
  {"Tengo hijos": "Tengo hijos"},
];
const kProfileCharacteristics_Pets_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Perro": "Perro"},
  {"Gato": "Gato"},
  {"Me gustaría": "Me gustaría"}
];

const kProfileCharacteristics_Politics_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Derechas": "Derechas"},
  {"Izquierda": "Izquierda"},
  {"Centro": "Centro"},
  {"Apolitico": "Apolitico"}
];
const kProfileCharacteristics_LivesWith_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Solo": "Solo"},
  {"Familia": "Familia"},
  {"Amigos": "Amigos"}
];

const kProfileCharacteristics_Alcohol_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"En sociedad": "En sociedad"},
  {"No bebo": "No bebo"},
  {"No me importa": "No me importa"},
  {"Odio el alcohol": "Odio el alcohol"}
];

const kProfileCharacteristics_Smoking_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Fumo": "Fumo"},
  {"No Fumo": "No Fumo"},
  {"A veces": "A veces"},
  {"Odio el tabaco": "Odio el tabaco"}
];

const kProfileCharacteristics_SexualOrientation_ES = [
  {kNotAvailable: "Sin respuesta"},
  "Hetero",
  "Gay",
  "Lesbiana",
  "Bisexual",
];

const kProfileCharacteristics_ES = [
  {"Alcohol": kProfileCharacteristics_Alcohol_ES},
  {"Busco": kProfileCharacteristics_LookingFor_ES},
  {"Complexion": kProfileCharacteristics_BodyType_ES},
  {"Hijos": kProfileCharacteristics_Children_ES},
  {"Mascotas": kProfileCharacteristics_Pets_ES},
  {"Politca": kProfileCharacteristics_Politics_ES},
  {"Que viva con": kProfileCharacteristics_LivesWith_ES},
  {"Tabaco": kProfileCharacteristics_Smoking_ES},
];

const kProfileCharacteristics_Icons = [
  // {"Altura": LineAwesomeIcons.ruler_vertical},
  {"Alcohol": LineAwesomeIcons.beer},

  {"Busco": LineAwesomeIcons.ring},
  {"Complexion": LineAwesomeIcons.snowboarding},
  {"Hijos": LineAwesomeIcons.baby},
  {"Mascotas": LineAwesomeIcons.dog},
  {"Politca": LineAwesomeIcons.landmark},
  {"Que viva con": LineAwesomeIcons.home},
  {"Tabaco": LineAwesomeIcons.smoking},
];
