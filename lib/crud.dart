import 'package:ostad_assignment_3/widgets/productCard.dart';
import 'package:ostad_assignment_3/widgets/productController.dart';
import 'package:flutter/material.dart';

class CRUD_APP extends StatefulWidget {
  const CRUD_APP({super.key});

  @override
  State<CRUD_APP> createState() => _CRUD_APPState();
}

class _CRUD_APPState extends State<CRUD_APP> {
  final ProductController productController = ProductController();
  bool isLoading = true;

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    await productController.fetchProducts();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void productDialog({
    String? id,
    String? name,
    String? price,
    String? qty,
    String? img,
    String? totalPrice,
    bool? isUpdate,
  }) {
    TextEditingController productNameController =
    TextEditingController(text: name ?? '');
    TextEditingController productQuantityController =
    TextEditingController(text: qty ?? '');
    TextEditingController productImageController =
    TextEditingController(text: img ?? '');
    TextEditingController productUnitPriceController =
    TextEditingController(text: price ?? '');
    TextEditingController productTotalPriceController =
    TextEditingController(text: totalPrice ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdate ?? false ? 'Update Product' : 'Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productNameController,
                decoration: const InputDecoration(hintText: 'Product Name'),
              ),
              TextField(
                controller: productQuantityController,
                decoration: const InputDecoration(hintText: 'Product Quantity'),
              ),
              TextField(
                controller: productImageController,
                decoration: const InputDecoration(hintText: 'Product Image URL'),
              ),
              TextField(
                controller: productUnitPriceController,
                decoration: const InputDecoration(hintText: 'Product Unit Price'),
              ),
              TextField(
                controller: productTotalPriceController,
                decoration: const InputDecoration(hintText: 'Product Total Price'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final name = productNameController.text.trim();
                      final qty = productQuantityController.text.trim();
                      final img = productImageController.text.trim();
                      final unitPrice = productUnitPriceController.text.trim();
                      final total = productTotalPriceController.text.trim();

                      if (name.isEmpty ||
                          qty.isEmpty ||
                          unitPrice.isEmpty ||
                          total.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all fields')),
                        );
                        return;
                      }

                      final success = await productController.createUpdateProducts(
                        name,
                        qty,
                        img,
                        unitPrice,
                        total,
                        id,
                        isUpdate ?? false,
                      );

                      if (success) {
                        Navigator.pop(context);
                        await fetchProducts();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isUpdate ?? false
                                ? 'Product Updated'
                                : 'Product Added'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to save product')),
                        );
                      }
                    },
                    child: Text(isUpdate ?? false ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : productController.products.isEmpty
          ? const Center(child: Text("No products found."))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: productController.products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          var product = productController.products[index];
          return ProductCard(
            product: product,
            onEdit: () {
              productDialog(
                isUpdate: true,
                id: product.sId,
                name: product.productName,
                qty: product.qty.toString(),
                img: product.img,
                price: product.unitPrice.toString(),
                totalPrice: product.totalPrice.toString(),
              );
            },
            onDelete: () async {
              final deleted = await productController
                  .deleteProducts(product.sId.toString());
              if (deleted) {
                await fetchProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Product Deleted")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to delete")),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => productDialog(isUpdate: false),
        child: const Icon(Icons.add),
      ),
    );
  }
}