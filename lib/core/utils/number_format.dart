/// Weight values without trailing zeros: `0.25`, `0.5`, `10`.
String formatWeightAmount(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.contains('.')
      ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
      : fixed;
}
