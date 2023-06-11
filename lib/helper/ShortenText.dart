class ShortenText {

  String cutText(String input) {

    String? finalText;

    if(input.length > 35) {
      finalText = "${input.substring(0,35)}...";
    } else {
      finalText = input;
    }

    return finalText;
  }
}