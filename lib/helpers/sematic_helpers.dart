String getSpacedClassName(String className) {
  return className.replaceAllMapped(
      RegExp('([A-Z])'), (match) => ' ${match.group(0)}');
}
