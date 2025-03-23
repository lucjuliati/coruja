class Helper {
  static T? findOrNull<T>(List<T> list, bool Function(T) test) {
    try {
      return list.firstWhere(test);
    } catch (err) {
      return null;
    }
  }
}
