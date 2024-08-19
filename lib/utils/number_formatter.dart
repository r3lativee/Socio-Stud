String formatNumber(int number) {
  if (number < 1000) {
    return number.toString();
  } else if (number >= 1000 && number < 1000000) {
    double result = number / 1000;
    return result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1) +
        "k";
  } else if (number >= 1000000 && number < 1000000000) {
    double result = number / 1000000;
    return result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1) +
        "m";
  } else {
    double result = number / 1000000000;
    return result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1) +
        "b";
  }
}
