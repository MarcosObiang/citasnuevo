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
  {"userCharacteristics_alcohol": (context) => AppLocalizations.of(context)!.alcohol},
  {"userCharacteristics_what_he_looks": (context) => AppLocalizations.of(context)!.im_looking_for},
  {"userCharacteristics_bodyType": (context) => AppLocalizations.of(context)!.body_type},
  {"userCharacteristics_children": (context) => AppLocalizations.of(context)!.children},
  {"userCharacteristics_pets": (context) => AppLocalizations.of(context)!.pets},
  {"userCharacteristics_politics": (context) => AppLocalizations.of(context)!.politics},
  {"userCharacteristics_smokes": (context) => AppLocalizations.of(context)!.smoking},

  {"userCharacteristics_lives_with": (context) => AppLocalizations.of(context)!.im_living_with},
  {"userCharacteristics_sexualO": (context) => AppLocalizations.of(context)!.sexual_orientation},
  {"userCharacteristics_zodiak": (context) => AppLocalizations.of(context)!.zodiac_sign},
  {"userCharacteristics_personality": (context) => AppLocalizations.of(context)!.personality},]
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
  {"userCharacteristics_alcohol": kProfileCharacteristics_Alcohol_ES},
  {"userCharacteristics_what_he_looks": kProfileCharacteristics_LookingFor_ES},
  {"userCharacteristics_bodyType": kProfileCharacteristics_BodyType_ES},
  {"userCharacteristics_children": kProfileCharacteristics_Children_ES},
  {"userCharacteristics_pets": kProfileCharacteristics_Pets_ES},
  {"userCharacteristics_politics": kProfileCharacteristics_Politics_ES},
  {"userCharacteristics_smokes": kProfileCharacteristics_Smoking_ES},
  {"userCharacteristics_lives_with": kProfileCharacteristics_LivesWith_ES},
  {"userCharacteristics_sexualO": kProfileCharacteristics_SexualOrientation_ES},
  {"userCharacteristics_zodiak": kProfileCharacteristics_zodiacSign_ES},
  {"userCharacteristics_personality": kProfileCharacteristics_Personality_ES},
];

const kProfileCharacteristics_Icons = [
  {"userCharacteristics_alcohol": LineAwesomeIcons.beer},
  {"userCharacteristics_what_he_looks": LineAwesomeIcons.ring},
  {"userCharacteristics_bodyType": LineAwesomeIcons.snowboarding},
  {"userCharacteristics_children": LineAwesomeIcons.baby},
  {"userCharacteristics_pets": LineAwesomeIcons.dog},
  {"userCharacteristics_politics": LineAwesomeIcons.landmark},
    {"userCharacteristics_smokes": LineAwesomeIcons.smoking},
  {"userCharacteristics_lives_with": LineAwesomeIcons.home},

  {"userCharacteristics_sexualO": LineAwesomeIcons.venus_mars},
  {"userCharacteristics_zodiak": LineAwesomeIcons.star},
  {"userCharacteristics_personality": LineAwesomeIcons.flushed_face},
];





