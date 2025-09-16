import 'package:flutter/material.dart';
import '../repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repo.fetchCategories();
    } catch (e) {
      debugPrint("Lỗi load categories: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
