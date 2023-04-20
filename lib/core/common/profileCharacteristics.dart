import 'package:line_awesome_flutter/line_awesome_flutter.dart';

const Map<String, dynamic> _kProfileCreatorMap = {
  "alcohol": 0,
  "im_looking_for": 0,
  "body_type": 0,
  "children": 0,
  "pets": 0,
  "politics": 0,
  "im_living_with": 0,
  "smoke": 0,
  "sexual_orientation": 0,
  "zodiac_sign": 0,
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

const kProfileCharacteristicsNames_ES = [
  {"alcohol": "¿Bebes alcohol?"},
  {"im_looking_for": "¿Qué buscas?"},
  {"body_type": "Complexión física"},
  {"children": "¿Hijos?"},
  {"pets": "¿Mascotas?"},
  {"politics": "Politica"},
  {"im_living_with": "Vivo con"},
  {"smoke": "¿Fumas?"},
  {"sexual_orientation": "Sexualidad"},
  {"zodiac_sign": "Horoscopo"},
  {"personality": "Personalidad"}]
;

const kProfileCharacteristics_LookingFor_ES = [
  {0: "Sin respuesta"},
  {1: "Relacion seria"},
  {2: "Lo que surja"},
  {3: "Algo casual"},
  {4: "No lo se"}
];

const kProfileCharacteristics_BodyType_ES = [
  {0: "Sin respuesta"},
  {1: "Normal"},
  {2: "Atletica"},
  {3: "Talla Grande"},
  {4: "Delgado"}
];

const kProfileCharacteristics_Children_ES = [
  {0: "Sin respuesta"},
  {1: "Algun dia"},
  {2: "Nunca"},
  {3: "Tengo hijos"},
];
const kProfileCharacteristics_Pets_ES = [
  {0: "Sin respuesta"},
  {1: "Perro"},
  {2: "Gato"},
  {3: "Me gustaría"}
];

const kProfileCharacteristics_Politics_ES = [
  {0: "Sin respuesta"},
  {1: "Derechas"},
  {2: "Izquierda"},
  {3: "Centro"},
  {4: "Apolitico"}
];
const kProfileCharacteristics_LivesWith_ES = [
  {0: "Sin respuesta"},
  {1: "Solo"},
  {2: "Familia"},
  {3: "Amigos"}
];

const kProfileCharacteristics_Alcohol_ES = [
  {0: "Sin respuesta"},
  {1: "En sociedad"},
  {2: "No bebo"},
  {3: "No me importa"},
  {4: "Odio el alcohol"}
];

const kProfileCharacteristics_Smoking_ES = [
  {0: "Sin respuesta"},
  {1: "Fumo"},
  {2: "No Fumo"},
  {3: "A veces"},
  {4: "Odio el tabaco"}
];

const kProfileCharacteristics_SexualOrientation_ES = [
  {0: "Sin respuesta"},
  {1: "Heterosexual"},
  {2: "Gay"},
  {3: "Lesbiana"},
  {4: "Bisexual"},
  {5: "Asexual"},
  {6: "Demisexual"},
  {7: "Pansexual"},
  {8: "Queer"},
];
const kProfileCharacteristics_zodiacSign_ES = [
  {0: "Sin respuesta"},
  {1: "Aries"},
  {2: "Tauro"},
  {3: "Geminis"},
  {4: "Cáncer"},
  {5: "Leo"},
  {6: "Virgo"},
  {7: "Libra"},
  {8: "Escorpio"},
  {9: "Sagitario"},
  {10: "Capricornio"},
  {11: "Acuario"},
  {12: "Piscis"},
];
const kProfileCharacteristics_Personality_ES = [
  {0: "Sin respuesta"},
  {1: "Introvertido"},
  {2: "Extrovertido"},
  {3: "Una mezcla de ambos"},
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
