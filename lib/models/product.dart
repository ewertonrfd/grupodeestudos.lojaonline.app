class Product {
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final int estoque;

  Product({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.estoque,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'] ?? '',
      preco: double.tryParse(json['preco'].toString()) ?? 0.0,
      estoque: json['estoque'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'estoque': estoque,
    };
  }
}
