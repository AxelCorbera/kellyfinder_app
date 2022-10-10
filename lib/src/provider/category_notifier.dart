import 'package:app/src/model/category.dart';
import 'package:flutter/material.dart';

class CategoryNotifier extends ChangeNotifier {
  bool _isFilled = false;
  List<Category> _categories;
  Category _selectedCategory;
  Category _selectedSubcategory;

  bool get isFilled => _isFilled;

  List<Category> get categories => _categories;

  Category get selectedCategory => _selectedCategory;

  Category get selectedSubcategory => _selectedSubcategory;

  void fillCategories(List<Category> items) {
    _categories = items;
    _isFilled = true;
    notifyListeners();
  }

  void selectCategory(Category item) {
    _selectedCategory = item;
    _selectedSubcategory = null;
    notifyListeners();
  }

  void selectSubcategory(Category item) {
    _selectedSubcategory = item;
    notifyListeners();
  }
}
