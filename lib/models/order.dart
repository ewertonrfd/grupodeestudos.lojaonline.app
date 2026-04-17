import 'product.dart';

class Order {
  final int id;
  final double valorTotal;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.valorTotal,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    return Order(
      id: json['id'],
      valorTotal: double.tryParse(json['valor_total'].toString()) ?? 0.0,
      status: json['status'] ?? 'PENDING',
      items: itemsList.map((i) => OrderItem.fromJson(i)).toList(),
    );
  }
}

class OrderItem {
  final int productId;
  final int quantidade;
  final double precoUnitario;
  final Product? product;

  OrderItem({
    required this.productId,
    required this.quantidade,
    required this.precoUnitario,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      quantidade: json['quantidade'],
      precoUnitario: double.tryParse(json['preco_unitario'].toString()) ?? 0.0,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}
