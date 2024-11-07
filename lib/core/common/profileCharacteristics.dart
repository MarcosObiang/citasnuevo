import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

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

 final kProfileCharacteristicsNames_ES = [
  {"alcohol": (context) => AppLocalizations.of(context)!.alcohol},
  {"im_looking_for": (context) => AppLocalizations.of(context)!.im_looking_for},
  {"body_type": (context) => AppLocalizations.of(context)!.body_type},
  {"children": (context) => AppLocalizations.of(context)!.children},
  {"pets": (context) => AppLocalizations.of(context)!.pets},
  {"politics": (context) => AppLocalizations.of(context)!.politics},
  {"im_living_with": (context) => AppLocalizations.of(context)!.im_living_with},
  {"smoke": (context) => AppLocalizations.of(context)!.smoking},
  {"sexual_orientation": (context) => AppLocalizations.of(context)!.sexual_orientation},
  {"zodiac_sign": (context) => AppLocalizations.of(context)!.zodiac_sign},
  {"personality": (context) => AppLocalizations.of(context)!.personality},]
;

final kProfileCharacteristics_LookingFor_ES = [
  {0: (context)=> AppLocalizations.of(context)!.sin_respuesta},
  {1: (context)=> AppLocalizations.of(context)!.im_looking_for_relacion_seria},
  {2: (context)=> AppLocalizations.of(context)!.im_looking_for_lo_que_surja},
  {3: (context)=> AppLocalizations.of(context)!.im_looking_for_algo_casual},
  {4: (context)=> AppLocalizations.of(context)!.im_looking_for_no_lo_se},
];

final kProfileCharacteristics_BodyType_ES = [
  {0: (context)=> AppLocalizations.of(context)!.sin_respuesta},
  {1: (context)=> AppLocalizations.of(context)!.body_type_normal},
  {2: (context)=> AppLocalizations.of(context)!.body_type_atletica},
  {3: (context)=> AppLocalizations.of(context)!.body_type_talla_grande},
  {4: (context)=> AppLocalizations.of(context)!.body_type_delgado},
];

final kProfileCharacteristics_Children_ES = [
  {0: (context)=> AppLocalizations.of(context)!.sin_respuesta},
  {1: (context)=> AppLocalizations.of(context)!.children_algun_dia},
  {2: (context)=> AppLocalizations.of(context)!.children_nunca},
  {3: (context)=> AppLocalizations.of(context)!.children_tengo_hijos},
];
final kProfileCharacteristics_Pets_ES = [
  {0: (context)=> AppLocalizations.of(context)!.sin_respuesta},
  {1: (context)=> AppLocalizations.of(context)!.pets_perro},
  {2: (context)=> AppLocalizations.of(context)!.pets_gato},
  {3: (context)=> AppLocalizations.of(context)!.pets_me_gustaria}
];


final kProfileCharacteristics_Politics_ES = [
  {0: (context)=> AppLocalizations.of(context)!.sin_respuesta},
  {1: (context) => AppLocalizations.of(context)!.politics_derechas},
  {2: (context) => AppLocalizations.of(context)!.politics_izquierda},
  {3: (context)=> AppLocalizations.of(context)!.politics_centro},
  {4: (context)=> AppLocalizations.of(context)!.politics_apolitico}
];
final kProfileCharacteristics_LivesWith_ES = [
  {0: (context) => AppLocalizations.of(context)!.sin_respuesta},
  {1: (context) => AppLocalizations.of(context)!.im_living_with_solo},
  {2: (context) => AppLocalizations.of(context)!.im_living_with_familia},
  {3: (context) => AppLocalizations.of(context)!.im_living_with_amigos}
];

final kProfileCharacteristics_Alcohol_ES = [
  {0: (context) => AppLocalizations.of(context)!.sin_respuesta},
  {1: (context) => AppLocalizations.of(context)!.alcohol_en_sociedad},
  {2: (context) => AppLocalizations.of(context)!.alcohol_no_bebo},
  {3: (context) => AppLocalizations.of(context)!.alcohol_no_me_importa},
  {4: (context) => AppLocalizations.of(context)!.alcohol_no_me_importa}
];

final kProfileCharacteristics_Smoking_ES = [
  {0: (context) => AppLocalizations.of(context)!.sin_respuesta},
  {1: (context) => AppLocalizations.of(context)!.smoking_no_fumo},
  {2: (context) => AppLocalizations.of(context)!.smoking_fumo},
  {3: (context) => AppLocalizations.of(context)!.smoking_a_veces},
  {4: (context) => AppLocalizations.of(context)!.smoking_odio_el_tabaco},
];

final kProfileCharacteristics_SexualOrientation_ES = [
  {0: (context) => AppLocalizations.of(context)!.sin_respuesta},
  {1: (context) => AppLocalizations.of(context)!.sexual_orientation_heterosexual},
  {2: (context) => AppLocalizations.of(context)!.sexual_orientation_gay},
  {3: (context) => AppLocalizations.of(context)!.sexual_orientation_lesbiana},
  {4: (context) => AppLocalizations.of(context)!.sexual_orientation_bisexual},
  {5: (context) => AppLocalizations.of(context)!.sexual_orientation_asexual},
  {6: (context) => AppLocalizations.of(context)!.sexual_orientation_demisexual},
  {7: (context) => AppLocalizations.of(context)!.sexual_orientation_pansexual},
  {8: (context) => AppLocalizations.of(context)!.sexual_orientation_queer},
];
final kProfileCharacteristics_zodiacSign_ES = [
  {0: (context) => AppLocalizations.of(context)!.sin_respuesta},
  {1: (context) => AppLocalizations.of(context)!.zodiac_sign_acuario},
  {2: (context) => AppLocalizations.of(context)!.zodiac_sign_piscis},
  {3: (context) => AppLocalizations.of(context)!.zodiac_sign_geminis},
  {4: (context) => AppLocalizations.of(context)!.zodiac_sign_cancer},
  {5: (context) => AppLocalizations.of(context)!.zodiac_sign_leo},
  {6: (context) => AppLocalizations.of(context)!.zodiac_sign_virgo},
  {7: (context) => AppLocalizations.of(context)!.zodiac_sign_libra},
  {8: (context) => AppLocalizations.of(context)!.zodiac_sign_escorpio},
  {9: (context) => AppLocalizations.of(context)!.zodiac_sign_sagitario},
  {10: (context) => AppLocalizations.of(context)!.zodiac_sign_capricornio},
  {11: (context) => AppLocalizations.of(context)!.zodiac_sign_tauro},
  {12: (context) => AppLocalizations.of(context)!.zodiac_sign_piscis},
];
final kProfileCharacteristics_Personality_ES = [
  {0: (context) => AppLocalizations.of(context)!.sin_respuesta},
  {1: (context) => AppLocalizations.of(context)!.personality_introvertido},
  {2: (context) => AppLocalizations.of(context)!.personality_extrovertido},
  {3: (context) => AppLocalizations.of(context)!.personality_una_mezcla_de_ambos},
];

final kProfileCharacteristics_ES = [
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





