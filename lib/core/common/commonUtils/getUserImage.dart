class GetProfileImage {
  static GetProfileImage getProfileImage = new GetProfileImage();

  Map<String, dynamic> getProfileImageMap(Map<String, dynamic> data) {
    bool done = false;
    Map<String, dynamic> imageMap = new Map();

    if (done == false && data["userPicture1"]?["imageId"] != "empty") {
      imageMap["image"] = data["userPicture1"]["imageId"];
      imageMap["hash"] = data["userPicture1"]["hash"];
      done = true;
    }
    if (done == false && data["userPicture2"]?["imageId"] != "empty") {
      imageMap["image"] = data["userPicture2"]["imageId"];
      imageMap["hash"] = data["userPicture2"]["hash"];
      done = true;
    }
    if (done == false && data["userPicture3"]?["imageId"] != "empty") {
      imageMap["image"] = data["userPicture3"]["imageId"];
      imageMap["hash"] = data["userPicture3"]["hash"];
      done = true;
    }
    if (done == false && data["userPicture4"]?["imageId"] != "empty") {
      imageMap["image"] = data["userPicture4"]["imageId"];
      imageMap["hash"] = data["userPicture4"]["hash"];
      done = true;
    }
    if (done == false && data["userPicture5"]?["imageId"] != "empty") {
      imageMap["image"] = data["userPicture5"]["imageId"];
      imageMap["hash"] = data["userPicture5"]["hash"];
      done = true;
    }
    if (done == false && data["userPicture6"]?["imageId"] != "empty") {
      imageMap["image"] = data["userPicture6"]["imageId"];
      imageMap["hash"] = data["userPicture6"]["hash"];
      done = true;
    }

    if (done == true) {
      return imageMap;
    } else {
      throw Exception();
    }
  }
}