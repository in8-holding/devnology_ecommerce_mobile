import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ProductService {
  static const products = 'http://localhost:3001/products';

  static Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(products));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar os produtos');
    }

    final productsList = json.decode(response.body) as List;

    return productsList.map((e) => Product.fromJson(e)).toList();
  }
}