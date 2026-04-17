import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho de Compras'),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Seu carrinho está vazio.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items.values.toList()[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Text('${cartItem.quantity}x'),
                        ),
                        title: Text(cartItem.product.nome),
                        subtitle: Text('R\$ ${(cartItem.product.preco * cartItem.quantity).toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => cart.removeSingleItem(cartItem.product.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => cart.removeItem(cartItem.product.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            Text(
                              'R\$ ${cart.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // Prepare items for API
                            final items = cart.items.values.map((item) => {
                              'product_id': item.product.id,
                              'quantidade': item.quantity,
                            }).toList();
                            
                            final success = await orderProvider.createOrder(items);
                            if (success) {
                              cart.clear();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pedido realizado com sucesso!')),
                                );
                                context.pushReplacement('/orders');
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Erro ao realizar pedido.')),
                                );
                              }
                            }
                          },
                          child: const Text('Finalizar Pedido'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
