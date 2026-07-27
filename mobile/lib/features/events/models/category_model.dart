class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.color,
  });

  final int id;
  final String name;
  final String slug;
  final String icon;
  final String color;

  factory CategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '#6750A4',
    );
  }
}