extension StringExtension on String {
  String shrink() {
    return length > 15 ? '${substring(0, 15)}...' : this;
  }
}
