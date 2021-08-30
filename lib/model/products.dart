
class Products {
  String productId = "";
  String productName = "";
  String productDescription = "";
  double productPrice = 0.0;
  double productSalePrice = 0.0;
  int quantity = 0;
  String categoryName = '';
  String categoryId = '';
  bool productStatus = true;
  List productSizes = [];
  List productColors = [];
  List productImages = [];

  Products({this.productId, this.productName, this.productDescription, this.productPrice, this.productSalePrice, this.quantity, this.productStatus, this.productSizes, this.productColors, this.productImages, this.categoryId, this.categoryName});

  factory Products.fromJson(Map<String, dynamic> json) {
    Products product = new Products(
      productId: json['productId'],
      productName : json['productName'],
      productDescription : json['productDescription'],
      productPrice : double.parse(json['productPrice'].toString()),
      productSalePrice : double.parse(json['productSalePrice'].toString()),
      quantity: int.parse(json['productQuantity'].toString()),
      productStatus : json['productStatus'],
      productSizes : json['productSizes'],
      productColors : json['productColors'],
      productImages : json['productImagesPath'],
      categoryName : json ['categoryName'],
      categoryId : json ['categoryId'],
    );
    return product;
  }
}