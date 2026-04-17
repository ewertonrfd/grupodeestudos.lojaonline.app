import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    final auth = context.read<AuthProvider>();
    final newName = _nameCtrl.text.trim();
    final newPassword = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    final success = await auth.updateProfile(
      name: newName.isNotEmpty ? newName : null,
      password: newPassword.isNotEmpty ? newPassword : null,
    );

    if (success && mounted) {
      _passwordCtrl.clear();
      _confirmPasswordCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar perfil.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.primaryColor.withOpacity(0.2),
                  child: Icon(Icons.person, size: 48, color: theme.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user?.email ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: user?.isLojista == true ? Colors.amber.withOpacity(0.2) : theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.isLojista == true ? '🏪 Lojista' : '👤 Usuário',
                    style: TextStyle(
                      color: user?.isLojista == true ? Colors.amber[800] : theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Nome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Seu nome',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 24),
              Text('Nova Senha (opcional)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(
                  hintText: 'Deixe em branco para manter',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordCtrl,
                decoration: const InputDecoration(
                  hintText: 'Confirmar nova senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: auth.isLoading ? null : _save,
                  icon: const Icon(Icons.save),
                  label: auth.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Salvar Alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
