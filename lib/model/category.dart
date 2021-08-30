
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String categoryId = "";
  String categoryName = "";
  String categoryImageUrl = "";
  bool categoryStatus = true;

  Category({this.categoryId, this.categoryName, this.categoryImageUrl, this.categoryStatus,});

  factory Category.fromJson(Map<String, dynamic> json) {
    Category category = new Category(
      categoryId: json['categoryId'],
      categoryName : json['categoryName'],
      categoryImageUrl : json['categoryImage'],
      categoryStatus : json['categoryStatus'],
    );
    return category;
  }

  Future addCategory(String categoryName, String categoryImage, bool categoryStatus) async {
    final firestoreInstance = FirebaseFirestore.instance;
      return await firestoreInstance.collection("categories").add({
      'categoryName': categoryName,
      'categoryImage': categoryImage,
      'categoryStatus': categoryStatus,
    }).then((_) async {
      print("success!");
      return true;
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

  Future editCategory(Category category, String categoryName, String categoryImage, bool categoryStatus) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("categories").doc(category.categoryId).update({
      'categoryName': categoryName,
      'categoryImage': categoryImage,
      'categoryStatus': categoryStatus,
    }).then((_) async {
      print("success!");
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

  Future updateCategoryStatus(Category category) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("categories").doc(category.categoryId).update({
      'categoryStatus': category.categoryStatus,
    }).then((_) async {
      print("success!");
      return true;
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

  

  Future deleteCategory(Category category) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("categories").doc(category.categoryId)
    .delete().then((_) async {
      print("success!");
      return true;
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

}