class Product {
  String? id;
  String? name;
  bool? stockOut;
  int? stockCount;

  Product(
      {required this.name, this.stockOut = false, required this.stockCount});

  Product.fromJson(this.id, Map<String, dynamic> json) {
    name = json['name'];
    stockOut = json['stockOut'];
    stockCount = json['stockCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['stockOut'] = stockOut;
    data['stockCount'] = stockCount;
    return data;
  }
}
