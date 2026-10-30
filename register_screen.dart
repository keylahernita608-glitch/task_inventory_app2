import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';

class RegisterScreen extends StatefulWidget {
  final List<AppUser> users;
  final List<InventoryItem> items;

  const RegisterScreen({Key? key, required this.users, required this.items}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.User;
  bool _obscureText = true;

  Future<void> _saveUsersToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(widget.users.map((e) => e.toJson()).toList());
    await prefs.setString('saved_users', encoded);
  }

  void _register() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom!')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal harus 6 karakter!')),
      );
      return;
    }

    if (username == 'admin1') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username admin1 adalah akun master sistem.')),
      );
      return;
    }

    // Daftar akun baru diset pending (isApproved: false)
    widget.users.add(AppUser(
      username: username,
      password: password,
      role: _selectedRole,
      isApproved: false,
    ));

    await _saveUsersToStorage();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pendaftaran Berhasil'),
        content: const Text('Pendaftaran berhasil menunggu persetujuan admin utama dulu. Anda belum bisa masuk sebelum disetujui.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_alt_1, size: 40, color: Color(0xFF0F4C3A)),
                ),
                const SizedBox(height: 16),
                const Text('Buat Akun Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 4),
                const Text('Lengkapi formulir di bawah untuk mendaftar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    labelText: 'Username Baru',
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
                    labelText: 'Password (Min. 6 Karakter)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.badge_outlined),
                    labelText: 'Hak Akses (Role)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  items: const [
                    DropdownMenuItem(value: UserRole.User, child: Text('User / Anggota')),
                    DropdownMenuItem(value: UserRole.AdminBiasa, child: Text('Admin Biasa')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
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
                    onPressed: _register,
                    child: const Text('Daftar Akun', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C3A))),
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