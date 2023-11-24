abstract final class NumFormat {
  static String toPercentWithTotal(num? num, num? total) {
    if (total == 0) return "0%";
    if (num != null && (num.isInfinite || num.isNaN)) return '--';
    return '${((num ?? 0) / (total ?? 0) * 100).round()}%';
  }

  static String toPercent(num num) {
    if (num.isInfinite || num.isNaN) return '--';
    return '${(num * 100).round()}%';
  }

  static String toNDigits(num num, [int digit = 2]) {
    return num.toString().padLeft(digit, '0');
  }
}
