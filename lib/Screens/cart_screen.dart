import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:norqmachinetest/Providers/product_provider.dart';
import 'package:provider/provider.dart';
import '../database_helper/database_helper.dart';
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: _buildCartList(context),
    );
  }
  Widget _buildCartList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.queryAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(child: Text('Cart is empty.'));
        } else {
          List<Map<String, dynamic>> cartProducts = snapshot.data as List<Map<String, dynamic>>;

          return ListView.builder(
            itemCount: cartProducts.length,
            itemBuilder: (context, index) {
              return _buildCartItem(context, cartProducts[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> cartProduct) {
    return Card(
      child: ListTile(
        leading: Image.network(
          cartProduct[DatabaseHelper.columnImageUrl],
          height: 80.0,
          width: 80.0,
          fit: BoxFit.cover,
        ),
        title: Text(_truncateTitle(cartProduct[DatabaseHelper.columnProductName]),
          maxLines: 1, // Set the maximum number of lines
          overflow: TextOverflow.ellipsis, // Display three dots for overflow
          style: Theme.of(context).textTheme.subtitle1!.merge(
            const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12
            ),
          ),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: \$${cartProduct[DatabaseHelper.columnPrice].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12
                  ),
                )),
            Text('Total: \$${(cartProduct[DatabaseHelper.columnPrice] * cartProduct[DatabaseHelper.columnCount]).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12
                  ),
                )),
            GestureDetector(
              onTap: (){
                _removeProduct(context, cartProduct);
              },
              child: Text('Remove',
                  style: Theme.of(context).textTheme.subtitle1!.merge(
                    const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.red
                    ),
                  )),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                _updateProductCount(context, cartProduct, -1);
              },
            ),
            Text('${cartProduct[DatabaseHelper.columnCount]}',
                style: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12
                  ),
                )),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _updateProductCount(context, cartProduct, 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateProductCount(BuildContext context, Map<String, dynamic> cartProduct, int delta)async {
    int newCount = cartProduct[DatabaseHelper.columnCount] + delta;
    if (newCount > 0) {
      try {
        await DatabaseHelper.instance.updateProductCount(cartProduct[DatabaseHelper.columnProductId], newCount);
        setState(() {
        });
      } catch (error) {
        print('Error updating product count: $error');
      }
    }
  }
  void _removeProduct(BuildContext context, Map<String, dynamic> cartProduct)async {
      try {
        await DatabaseHelper.instance.removeProductFromCart(cartProduct[DatabaseHelper.columnProductId]);
        setState(() {
        });
        Provider.of<ProductProvider>(context, listen: false).getCartItemCount();
      } catch (error) {
        print('Error deleting product count: $error');
      }

  }
  String _truncateTitle(String title) {
    const int maxChars = 20; // Set  maximum character limit
    return title.length > maxChars ? '${title.substring(0, maxChars)}...' : title;
  }
}