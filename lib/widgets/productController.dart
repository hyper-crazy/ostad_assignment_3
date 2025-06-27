import 'dart:convert';

import 'package:ostad_assignment_3/models/productModel.dart';
import 'package:ostad_assignment_3/urls.dart';
import 'package:http/http.dart' as http;

class ProductController {
  List<Data> products = [];

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse(Urls.readProduct));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ProductModel model = ProductModel.fromJson(data);
      products = model.data ?? [];
    } else {
      print('Error');
    }
  }

  Future<bool> createUpdateProducts(
      String productName,
      String productQuantity,
      String productImage,
      String productUnitPrice,
      String productTotalPrice,
      String? productId,
      bool isUpdate,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(isUpdate ? Urls.updateProduct(productId!) : Urls.createProduct),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ProductName': productName,
          'ProductCode': DateTime.now().millisecondsSinceEpoch,
          'Qty': int.tryParse(productQuantity) ?? 0,
          'Img': productImage,
          'UnitPrice': int.tryParse(productUnitPrice) ?? 0,
          'TotalPrice': int.tryParse(productTotalPrice) ?? 0,
        }),
      );

      print("Status: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchProducts(); // Refresh products
        return true;
      } else {
        print("Failed to create/update");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }


  Future<bool> deleteProducts(String productId) async {
    final response = await http.get(Uri.parse(Urls.deleteProduct(productId)));
    print(response.statusCode);
    if (response.statusCode == 200) {
      fetchProducts();
      return true;
    } else {
      return false;
    }
  }
}