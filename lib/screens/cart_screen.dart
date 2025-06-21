import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items;
    final products = cart.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Carrinho vazio'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final productId = items.keys.elementAt(index);
                      final quantity = items[productId]!;
                      final product = products[productId]!;

                      return ListTile(
                        leading: const Icon(Icons.image_not_supported),
                        title: Text(product.name),
                        subtitle: Text('Quantidade: $quantity'),
                        trailing: SizedBox(
                          width: 110,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => cart.removeProduct(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: () => cart.addProduct(product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Total: R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                    },
                    child: const Text('Finalizar Compra'),
                  ),
                ),
              ],
            ),
    );
  }
}