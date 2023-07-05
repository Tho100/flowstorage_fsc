class ShortenText {

  String cutText(String input) {

    String? finalText;

    if(input.length > 28) {
      finalText = "${input.substring(0,28)}...";
    } else {
      finalText = input;
    }

    return finalText;
  }
}