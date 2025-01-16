class BuildFieldModel {
  final String tittle, sub;
  BuildFieldModel({required this.tittle, required this.sub});
}

class BuildFieldData {
  static final List<BuildFieldModel> data = [
    BuildFieldModel(
        tittle: 'Top World News', sub: 'Special reports and editor’s pick'),
    BuildFieldModel(
        tittle: 'Breakfast News', sub: 'Start your day with interesting news'),
    BuildFieldModel(
        tittle: 'Sports', sub: 'Live scores, match updates & games'),
    BuildFieldModel(
        tittle: 'Politics', sub: 'All political news, nation & worldwide'),
    BuildFieldModel(
        tittle: 'Business News', sub: 'Economics, money matters & people'),
    BuildFieldModel(
        tittle: 'Capital News in Trend',
        sub: 'Get in touch with latest happenings'),
    BuildFieldModel(
        tittle: 'Medical News', sub: 'Latest treatments, business & hospitals'),
  ];
}
