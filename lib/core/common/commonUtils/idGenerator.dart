import 'dart:math';

class IdGenerator {
  static IdGenerator instancia = new IdGenerator();

  String createId() {
    List<String> letras = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    List<String> numero = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
    var random = Random();
    int primeraLetra = random.nextInt(26);
    String finalCode = letras[primeraLetra];

    for (int i = 0; i <= 20; i++) {
      int characterTypeIndicator = random.nextInt(20);
      int randomWord = random.nextInt(27);
      int randomNumber = random.nextInt(9);
      if (characterTypeIndicator <= 2) {
        characterTypeIndicator = 2;
      }
      if (characterTypeIndicator % 2 == 0) {
        finalCode = "$finalCode${(numero[randomNumber])}";
      }
      if (randomWord % 3 == 0) {
        int mayuscula = random.nextInt(9);
        if (characterTypeIndicator <= 2) {
          int suerte = random.nextInt(2);
          suerte == 0 ? characterTypeIndicator = 3 : characterTypeIndicator = 2;
        }
        if (mayuscula % 2 == 0) {
          finalCode = "$finalCode${(letras[randomWord]).toUpperCase()}";
        }
        if (mayuscula % 3 == 0) {
          finalCode = "$finalCode${(letras[randomWord]).toLowerCase()}";
        }
      }
    }
    return finalCode;
  }
}
