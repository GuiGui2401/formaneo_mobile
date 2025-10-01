import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: cart.itemCount == 0
                ? Center(
                    child: Text(
                      'Votre panier est vide.',
                      style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.itemCount,
                    itemBuilder: (ctx, i) => CartItemWidget(
                      cart.items.values.toList()[i].product.id,
                      cart.items.values.toList()[i].product.imageUrl,
                      cart.items.values.toList()[i].product.name,
                      cart.items.values.toList()[i].product.currentPrice,
                      cart.items.values.toList()[i].quantity,
                    ),
                  ),
          ),
          _buildCheckoutCard(context, cart),
        ],
      ),
    );
  }

  Widget _buildCheckoutCard(BuildContext context, CartProvider cart) {
    return Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Chip(
                  label: Text(
                    Formatters.formatAmount(cart.totalAmount),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: cart.totalAmount <= 0 ? null : () {
                // TODO: Implement checkout logic
                print('Checkout button pressed!');
              },
              child: Text('Commander'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final String productId;
  final String? imageUrl;
  final String title;
  final double price;
  final int quantity;

  CartItemWidget(
    this.productId,
    this.imageUrl,
    this.title,
    this.price,
    this.quantity,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(productId),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                  ? NetworkImage(imageUrl!)
                  : null,
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Icon(Icons.shopping_bag, color: Colors.white)
                  : null,
              backgroundColor: AppTheme.primaryColor,
            ),
            title: Text(title),
            subtitle: Text('Total: ${Formatters.formatAmount(price * quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
