import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

const Map<String, dynamic> _kProfileCreatorMap = {
  "alcohol": 0,
  "Im_looking_for": 0,
  "body_type": 0,
  "children": 0,
  "pets": 0,
  "politics": 0,
  "im_living_with": 0,
  "smoke": 0,
  "sexual_orientation": 0,
  "zodiag_sign": 0,
  "personality": 0
};

Map<String, dynamic> kUserCreatorMockData = {
  "IMAGENPERFIL1": {
    "Imagen": "vacio",
    "hash": "vacio",
    "index": -1,
    "pictureName": "IMAGENPERFIL1",
    "removed": false
  },
  "IMAGENPERFIL2": {
    "Imagen": "vacio",
    "hash": "vacio",
    "index": -1,
    "pictureName": "IMAGENPERFIL2",
    "removed": false
  },
  "IMAGENPERFIL3": {
    "Imagen": "vacio",
    "hash": "vacio",
    "index": -1,
    "pictureName": "IMAGENPERFIL3",
    "removed": false
  },
  "IMAGENPERFIL4": {
    "Imagen": "vacio",
    "hash": "vacio",
    "index": -1,
    "pictureName": "IMAGENPERFIL4",
    "removed": false
  },
  "IMAGENPERFIL5": {
    "Imagen": "vacio",
    "hash": "vacio",
    "index": -1,
    "pictureName": "IMAGENPERFIL5",
    "removed": false
  },
  "IMAGENPERFIL6": {
    "Imagen": "vacio",
    "hash": "vacio",
    "index": -1,
    "pictureName": "IMAGENPERFIL6",
    "removed": false
  },
  "filtros usuario": _kProfileCreatorMap,
  "Descripcion": ""
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
  {"Heterosexual": "HeteroSexual"},
  {"Gay": "Gay"},
  {"Lesbiana": "Lesbiana"},
  {"Bisexual": "Bisexual"},
  {"Asexual": "Asexual"},
  {"Demisexual": "Demisexual"},
  {"Pansexual": "Pansexual"},
  {"Queer": "Queer"},
];
const kProfileCharacteristics_zodiacSign_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Aries": "Aries"},
  {"Tauro": "Tauro"},
  {"Geminis": "Geminis"},
  {"Cáncer": "Cáncer"},
  {"Leo": "Leo"},
  {"Virgo": "Virgo"},
  {"Libra": "Libra"},
  {"Escorpio": "Escorpio"},
  {"Sagitario": "Sagitario"},
  {"Capricornio": "Capricornio"},
  {"Acuario": "Acuario"},
  {"Piscis": "Piscis"},
];
const kProfileCharacteristics_Personality_ES = [
  {kNotAvailable: "Sin respuesta"},
  {"Introvertido": "Introvertido"},
  {"Extrovertido": "Extrovertido"},
  {"Una mezcla de ambos": "Una mezcla de ambos"},
];

const kProfileCharacteristics_ES = [
  {"alcohol": kProfileCharacteristics_Alcohol_ES},
  {"im_looking_for": kProfileCharacteristics_LookingFor_ES},
  {"body_type": kProfileCharacteristics_BodyType_ES},
  {"children": kProfileCharacteristics_Children_ES},
  {"pets": kProfileCharacteristics_Pets_ES},
  {"politics": kProfileCharacteristics_Politics_ES},
  {"im_living_with": kProfileCharacteristics_LivesWith_ES},
  {"smoke": kProfileCharacteristics_Smoking_ES},
  {"sexual_orientation": kProfileCharacteristics_SexualOrientation_ES},
  {"zodiac_sign": kProfileCharacteristics_zodiacSign_ES},
  {"personality": kProfileCharacteristics_Personality_ES},
];

const kProfileCharacteristics_Icons = [
  {"alcohol": LineAwesomeIcons.beer},
  {"im_looking_for": LineAwesomeIcons.ring},
  {"body_type": LineAwesomeIcons.snowboarding},
  {"children": LineAwesomeIcons.baby},
  {"pets": LineAwesomeIcons.dog},
  {"politics": LineAwesomeIcons.landmark},
  {"im_living_with": LineAwesomeIcons.home},
  {"smoke": LineAwesomeIcons.smoking},
  {"sexual_orientation": LineAwesomeIcons.venus_mars},
  {"zodiac_sign": LineAwesomeIcons.star},
  {"personality": LineAwesomeIcons.flushed_face},
];
