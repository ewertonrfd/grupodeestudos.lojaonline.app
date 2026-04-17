import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class LojistaDashboard extends StatefulWidget {
  const LojistaDashboard({super.key});

  @override
  State<LojistaDashboard> createState() => _LojistaDashboardState();
}

class _LojistaDashboardState extends State<LojistaDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _showProductDialog({Product? existingProduct}) {
    final nomeCtrl = TextEditingController(text: existingProduct?.nome ?? '');
    final descCtrl = TextEditingController(text: existingProduct?.descricao ?? '');
    final precoCtrl = TextEditingController(text: existingProduct != null ? existingProduct.preco.toString() : '');
    final estoqueCtrl = TextEditingController(text: existingProduct != null ? existingProduct.estoque.toString() : '');

    final isEditing = existingProduct != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
              const SizedBox(height: 8),
              TextField(
                controller: precoCtrl,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: estoqueCtrl,
                decoration: const InputDecoration(labelText: 'Estoque'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nome = nomeCtrl.text;
              final desc = descCtrl.text;
              final preco = double.tryParse(precoCtrl.text) ?? 0.0;
              final estoque = int.tryParse(estoqueCtrl.text) ?? 0;

              if (nome.isNotEmpty && preco > 0) {
                bool success;
                if (isEditing) {
                  success = await context.read<ProductProvider>().updateProduct(
                    existingProduct.id,
                    nome: nome,
                    descricao: desc,
                    preco: preco,
                    estoque: estoque,
                  );
                } else {
                  final product = Product(id: 0, nome: nome, descricao: desc, preco: preco, estoque: estoque);
                  success = await context.read<ProductProvider>().createProduct(product);
                }
                if (success && mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Produto atualizado!' : 'Produto criado!')),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Atualizar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/app_icon.png'),
        ),
        title: const Text('Painel do Lojista'),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(product.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('R\$ ${product.preco.toStringAsFixed(2)} | Estoque: ${product.estoque}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: theme.primaryColor),
                          tooltip: 'Editar',
                          onPressed: () => _showProductDialog(existingProduct: product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Excluir',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir'),
                                content: const Text('Deseja excluir este produto?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Não')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sim')),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              await context.read<ProductProvider>().deleteProduct(product.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
