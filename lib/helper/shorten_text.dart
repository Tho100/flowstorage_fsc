class ShortenText {

  String cutText(String input, {int? customLength}) {

    String? finalText;

    int maxLength = customLength ?? 28;

    if(input.length > maxLength) {
      finalText = "${input.substring(0,maxLength)}...";
    } else {
      finalText = input;
    }

    return finalText;
  }
}