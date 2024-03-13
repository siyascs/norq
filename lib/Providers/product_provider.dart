import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:norqmachinetest/models/product_model.dart';

import '../database_helper/database_helper.dart';
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  String? _error;
  bool _isLoading = false;

  List<Product> get products => _products;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      final response = await http.get(
          Uri.parse('https://fakestoreapi.com/products'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _products = jsonData.map((item) => Product.fromJson(item)).toList();
        _error = null;
      } else {
        throw Exception('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Error loading products: ${e.toString()}';
      _products.clear(); // Clear products list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> addToCart(Product product) async {
    try {
      Map<String, dynamic> row = {
        DatabaseHelper.columnProductId: product.id,
        DatabaseHelper.columnProductName: product.title,
        DatabaseHelper.columnPrice: product.price,
        DatabaseHelper.columnImageUrl: product.image,
        DatabaseHelper.columnCount: 1,
      };

      await DatabaseHelper.instance.insertProduct(row);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error adding product to cart: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<int> getCartItemCount() async {
    List<Map<String, dynamic>> cartProducts=[];
    cartProducts = await DatabaseHelper.instance.queryAllProducts();
    return cartProducts.length;
  }
  Future<bool> isInCart(int productId) async {
    return await DatabaseHelper.instance.isProductInCart(productId);
  }
}
