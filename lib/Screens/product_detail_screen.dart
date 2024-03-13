import 'package:flutter/material.dart';
import 'package:norqmachinetest/Providers/product_provider.dart';
import 'package:norqmachinetest/models/product_model.dart';
import 'package:norqmachinetest/reusable_widgets/reusable_widget.dart';
import 'package:provider/provider.dart';
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.image,
              height: 200.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16.0),
            Text(
              product.title,
              style: Theme.of(context).textTheme.subtitle1!.merge(
                const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  color: Colors.black
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text('Price:\$${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.subtitle1!.merge(
              const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14
              ),
            ),),
            const SizedBox(height: 8.0),
            Text(
              'Description: ${product.description}',
                style: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12
                  ),
                ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Rating: ${product.rating.rate}',
              style: Theme.of(context).textTheme.subtitle1!.merge(
                const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            buildCartIcon(product, productProvider),
          ]
        ),
      ),
    );
  }
}
