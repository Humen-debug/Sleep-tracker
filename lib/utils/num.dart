abstract final class NumFormat {
  static String toPercentWithTotal(num? num, num? total) {
    return '${((num ?? 0) / (total ?? 0) * 100).round()}%';
  }

  static String toPercent(num num) {
    return '${(num * 100).round()}%';
  }

  static String toNDigits(num num, [int digit = 2]) {
    return num.toString().padLeft(digit, '0');
  }
}
