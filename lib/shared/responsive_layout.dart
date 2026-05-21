class ResponsiveLayout {
  static bool isMobile(double width) {
    return width < 768;
  }

  static bool isTablet(double width) {
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(double width) {
    return width >= 1024;
  }

  static int gridCount(double width) {
    if (isDesktop(width)) return 4;

    if (isTablet(width)) return 2;

    return 1;
  }
}
