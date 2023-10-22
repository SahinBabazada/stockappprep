class Product {
  String? id;
  String? name;
  bool? stockOut;
  int? stockCount;
  String? author;

  Product(
      {required this.name,
      this.stockOut = false,
      required this.stockCount,
      required this.author});

  Product.fromJson(this.id, Map<String, dynamic> json) {
    name = json['name'];
    stockOut = json['stockOut'];
    stockCount = json['stockCount'];
    author = json['author'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['stockOut'] = stockOut;
    data['stockCount'] = stockCount;
    data['author'] = author;
    return data;
  }
}
