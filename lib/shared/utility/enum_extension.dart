extension EnumByName<T extends Enum> on Iterable<T> {
  T? byNameOrNull(String? value) {
    if (value == null) {
      return null;
    }

    try {
      return byName(value);
    } catch (_) {
      return null;
    }
  }
}
