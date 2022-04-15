class GetProfileImage {
  static GetProfileImage getProfileImage = new GetProfileImage();

  Map<String, dynamic> getProfileImageMap(Map<String, dynamic> data) {
    bool done = false;
    Map<String, dynamic> imageMap = new Map();

    if (done == false && data["IMAGENPERFIL1"]?["Imagen"] != "vacio") {
      imageMap["image"] = data["IMAGENPERFIL1"]["Imagen"];
      imageMap["hash"] = data["IMAGENPERFIL1"]["hash"];
      done = true;
    }
    if (done == false && data["IMAGENPERFIL2"]?["Imagen"] != "vacio") {
      imageMap["image"] = data["IMAGENPERFIL2"]["Imagen"];
      imageMap["hash"] = data["IMAGENPERFIL2"]["hash"];
      done = true;
    }
    if (done == false && data["IMAGENPERFIL3"]?["Imagen"] != "vacio") {
      imageMap["image"] = data["IMAGENPERFIL3"]["Imagen"];
      imageMap["hash"] = data["IMAGENPERFIL3"]["hash"];
      done = true;
    }
    if (done == false && data["IMAGENPERFIL4"]?["Imagen"] != "vacio") {
      imageMap["image"] = data["IMAGENPERFIL4"]["Imagen"];
      imageMap["hash"] = data["IMAGENPERFIL4"]["hash"];
      done = true;
    }
    if (done == false && data["IMAGENPERFIL5"]?["Imagen"] != "vacio") {
      imageMap["image"] = data["IMAGENPERFIL5"]["Imagen"];
      imageMap["hash"] = data["IMAGENPERFIL5"]["hash"];
      done = true;
    }
    if (done == false && data["IMAGENPERFIL6"]?["Imagen"] != "vacio") {
      imageMap["image"] = data["IMAGENPERFIL6"]["Imagen"];
      imageMap["hash"] = data["IMAGENPERFIL6"]["hash"];
      done = true;
    }

    if (done == true) {
      return imageMap;
    } else {
      throw Exception();
    }
  }
}