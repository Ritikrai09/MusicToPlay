class SearchTileModel {
  SearchTileModel({required this.icon, required this.name});
  final String icon, name;
}

class SearchTileData {
  static final List<SearchTileModel> searchItems = [
    SearchTileModel(icon: 'asset/Icons/newspaper.svg', name: 'All News'),
    SearchTileModel(icon: 'asset/Icons/trending_up.svg', name: 'Trending'),
    SearchTileModel(icon: 'asset/Icons/transformer.svg', name: 'Latest'),
    SearchTileModel(icon: 'asset/Icons/mailbox.svg', name: 'Unread'),
  ];
}
