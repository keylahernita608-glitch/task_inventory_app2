import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'register_screen.dart';
import 'user_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final List<AppUser> users;
  final List<InventoryItem> items;

  const LoginScreen({Key? key, required this.users, required this.items}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password tidak boleh kosong!')),
      );
      return;
    }

    try {
      AppUser user = widget.users.firstWhere(
        (u) => u.username == username && u.password == password,
      );

      // Validasi persetujuan Admin Utama
      if (!user.isApproved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Anda belum disetujui oleh Admin Utama, atau telah ditolak.')),
        );
        return;
      }

      if (user.role == UserRole.User) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserDashboard(currentUser: user, items: widget.items, users: widget.users),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboard(currentUser: user, items: widget.items, users: widget.users),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_sekolah.jpeg',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 80, color: Color(0xFF0F4C3A)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SMK NEGERI 1 BERINGIN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F4C3A)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Task Inventory App',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0F4C3A)),
                ),
                const SizedBox(height: 8),
                const Text('Masuk ke akun Anda', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    labelText: 'Username',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C3A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _login,
                    child: const Text('Masuk ke Sistem', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum memiliki akun? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen(users: widget.users, items: widget.items)),
                        );
                      },
                      child: const Text('Registrasi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C3A))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}