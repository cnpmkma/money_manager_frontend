import '../services/category_service.dart';

class CategoryRepository {
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    return await CategoryService.getCategories();
  }
}
