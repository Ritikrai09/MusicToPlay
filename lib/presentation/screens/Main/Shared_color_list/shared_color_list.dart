class SharedColor {
  static const List<String> colors = [
    '0xffD9F5D2',
    '0xffFAF1ED',
    '0xffFFF8C6',
    '0xffDDF3FF',
    '0xffFFDCDB',
    '0xffCFF7FD'
  ];
}

class CategoryModel {
  CategoryModel({
    required this.color,
    required this.tittle,
    required this.article,
  });
  final String color, tittle, article;
}

class SharedCategoryData {
  static final List<CategoryModel> categories = [
    CategoryModel(
        color: '0xffD9F5D2', tittle: 'Travel', article: '17 Articles'),
    CategoryModel(
        color: '0xffFAF1ED', tittle: 'Lifestyle', article: '120 Articles'),
    CategoryModel(
        color: '0xffFFF8C6', tittle: 'Fitness', article: '172 Articles'),
    CategoryModel(
        color: '0xffDDF3FF', tittle: 'Education', article: '265 Articles'),
    CategoryModel(
        color: '0xffFFDCDB', tittle: 'Sports', article: '56 Articles'),
    CategoryModel(
        color: '0xffCFF7FD', tittle: 'Technology', article: '85 Articles')
  ];
}
