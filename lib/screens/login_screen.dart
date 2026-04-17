import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _isLogin = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    if (_isLogin) {
      final success = await auth.login(email, password);
      if (success && mounted) {
        context.go('/');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro no login. Verifique as credenciais.')),
          );
        }
      }
    } else {
      final name = _nameCtrl.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha o nome')),
        );
        return;
      }
      
      final success = await auth.register(name, email, password);
      if (success && mounted) {
        setState(() {
          _isLogin = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado! Faça login agora.')),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro no cadastro.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/app_icon.png',
                      height: 100,
                    ).animate().scale(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Web Evolui Store',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 32),
                    
                    if (!_isLogin)
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nome'),
                      ).animate().slideX(),
                      
                    if (!_isLogin) const SizedBox(height: 16),
                    
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ).animate().slideX(delay: 100.ms),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      autofillHints: const [AutofillHints.password],
                    ).animate().slideX(delay: 200.ms),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isLogin ? 'Entrar' : 'Cadastrar'),
                      ),
                    ).animate().scale(delay: 300.ms),
                    
                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Faça login'),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
