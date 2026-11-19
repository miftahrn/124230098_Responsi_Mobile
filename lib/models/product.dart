class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.ratingRate,
    required this.ratingCount,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double ratingRate;
  final int ratingCount;

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingValue = json['rating'];
    final rating = ratingValue is Map
        ? Map<String, dynamic>.from(ratingValue)
        : <String, dynamic>{};
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return Product(
      id: parseInt(json['id']),
      title: json['title'] as String? ?? '',
      price: parseDouble(json['price']),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
      ratingRate: parseDouble(rating['rate']),
      ratingCount: parseInt(rating['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': {
        'rate': ratingRate,
        'count': ratingCount,
      },
    };
  }
}
