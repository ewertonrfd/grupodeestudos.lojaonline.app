import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.isLojista ? 'Todos os Pedidos' : 'Meus Pedidos'),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
              ? const Center(child: Text('Nenhum pedido encontrado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text('Pedido #${order.id}'),
                        subtitle: Text('Status: ${order.status}'),
                        trailing: Text(
                          'R\$ ${order.valorTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        children: order.items.map((item) {
                          return ListTile(
                            dense: true,
                            title: Text(item.product?.nome ?? 'Produto #${item.productId}'),
                            subtitle: Text('${item.quantidade}x R\$ ${item.precoUnitario.toStringAsFixed(2)}'),
                            trailing: Text('R\$ ${(item.quantidade * item.precoUnitario).toStringAsFixed(2)}'),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
    );
  }
}
