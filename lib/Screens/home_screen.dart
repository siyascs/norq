import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:norqmachinetest/Providers/product_provider.dart';
import 'package:norqmachinetest/Screens/cart_screen.dart';
import 'package:norqmachinetest/Screens/product_detail_screen.dart';
import 'package:norqmachinetest/models/product_model.dart';
import 'package:norqmachinetest/reusable_widgets/reusable_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Call fetchProducts() when the widget is first created
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Fake App'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              Consumer<ProductProvider>(
                builder: (context, productProvider, _) {
                  return FutureBuilder<int>(
                    future: productProvider.getCartItemCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink(); // You can use a loading indicator here if needed
                      } else if (snapshot.hasError) {
                        return const SizedBox.shrink(); // Handle the error
                      } else {
                        int cartItemCount = snapshot.data ?? 0;
                        return cartItemCount > 0
                            ? Positioned(
                          top: 0,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              '$cartItemCount',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                            : const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(productProvider)
    );
  }
  Widget _buildBody(ProductProvider productProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        // Add your refresh logic here
        await productProvider.fetchProducts();
      },
      child: _buildGridView(productProvider),
    );
  }
  Widget _buildGridView(ProductProvider productProvider){
    if (productProvider.isLoading) {
      // Show loading indicator
      return const Center(child: CircularProgressIndicator());
    } else if (productProvider.error != null) {
      // Show error message
      return Center(
        child: Text('Error: ${productProvider.error}'),
      );
    } else if (productProvider.products.isEmpty) {
      // Show message when no products are available
      return const Center(
        child: Text('No products available.'),
      );
    } else {
      // Show GridView when data is available
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            mainAxisExtent: 290
        ),
        itemCount: productProvider.products.length,
        itemBuilder: (context, index) {
          Product product = productProvider.products[index];

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                16.0,
              ),
              color: Colors.amberAccent.shade100,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    child: Image.network(
                      product.image,
                      height: 170.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _truncateTitle(product.title),
                      maxLines: 1, // Set the maximum number of lines
                      overflow: TextOverflow.ellipsis, // Display three dots for overflow
                      style: Theme.of(context).textTheme.subtitle1!.merge(
                        const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 8.0,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.subtitle2!.merge(
                        TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                            fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  buildCartIcon(product, productProvider),
                ],
              ),
            ),
          );
        },
      );
    }
  }
  String _truncateTitle(String title) {
    const int maxChars = 20; // Set  maximum character limit
    return title.length > maxChars ? '${title.substring(0, maxChars)}...' : title;
  }
  Future<bool> _onBackPressed() async {
    // Exit the app
    return true;
  }
}