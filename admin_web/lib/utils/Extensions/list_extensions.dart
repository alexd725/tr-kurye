extension ListExtensions<T> on Iterable<T>? {
  /// Validate given List is not null and returns blank list if null.
  /// This should not be used to clear list
  List<T> validate() {
    if (this == null) {
      return [];
    } else {
      return this!.toList();
    }
  }
}
