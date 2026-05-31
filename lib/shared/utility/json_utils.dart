class JsonUtils {
  static String parseString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static int? parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static double parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static bool parseBool(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value == 1;
    }

    final normalized = value.toString().toLowerCase();

    return normalized == 'true' || normalized == '1';
  }

  static List<T> parseList<T>(dynamic value) {
    if (value is List<T>) {
      return value;
    }

    return [];
  }

  static DateTime? parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
