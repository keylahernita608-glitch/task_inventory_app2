import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';
import 'add_item_screen.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  final AppUser currentUser;
  final List<InventoryItem> items;
  final List<AppUser> users;

  const AdminDashboard({
    Key? key,
    required this.currentUser,
    required this.items,
    required this.users,
  }) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _filterStatus =
      'All'; // All, Pending, Proses, Selesai, Approve, Delete

  Future<void> _saveDataToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedItems = jsonEncode(
      widget.items.map((e) => e.toJson()).toList(),
    );
    String encodedUsers = jsonEncode(
      widget.users.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('saved_items', encodedItems);
    await prefs.setString('saved_users', encodedUsers);
  }

  @override
  Widget build(BuildContext context) {
    bool isSuperAdmin = widget.currentUser.role == UserRole.AdminSuper;

    int pendingAction = widget.items
        .where((i) => i.status == ItemStatus.Pending)
        .length;
    int inProgress = widget.items
        .where((i) => i.status == ItemStatus.Proses)
        .length;
    int completed = widget.items
        .where((i) => i.status == ItemStatus.Selesai)
        .length;

    int totalTask = widget.items
        .where((i) => i.category == ItemCategory.Task)
        .length;
    int totalInventaris = widget.items
        .where((i) => i.category == ItemCategory.Inventaris)
        .length;
    int totalSystem = widget.items.length;

    List<InventoryItem> filteredItems = widget.items.where((item) {
      if (_filterStatus == 'Pending') return item.status == ItemStatus.Pending;
      if (_filterStatus == 'Proses') return item.status == ItemStatus.Proses;
      if (_filterStatus == 'Selesai') return item.status == ItemStatus.Selesai;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1128),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Control Center',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  'Supervision: ${widget.currentUser.username}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LoginScreen(users: widget.users, items: widget.items),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel Pengawasan & Validasi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Panel Pengawasan & Validasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Terdapat $pendingAction tugas/inventaris memerlukan tindakan verifikasi status.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'RINGKASAN OPERASIONAL ADMIN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildStatCard(
                  pendingAction.toString(),
                  'Need Action',
                  Icons.assignment_late,
                  Colors.red,
                ),
                _buildStatCard(
                  inProgress.toString(),
                  'In Progress',
                  Icons.sync,
                  Colors.orange,
                ),
                _buildStatCard(
                  completed.toString(),
                  'Completed',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  totalSystem.toString(),
                  'Total System...',
                  Icons.list_alt,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Analisis Distribusi Data Sistem
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Analisis Distribusi Data Sistem',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Icon(Icons.pie_chart_outline, color: Colors.deepOrange),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Proporsi Kategori Data:',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: totalTask == 0 ? 1 : totalTask,
                          child: Container(height: 10, color: Colors.blue),
                        ),
                        Expanded(
                          flex: totalInventaris == 0 ? 1 : totalInventaris,
                          child: Container(height: 10, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Task ($totalTask)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Inventaris ($totalInventaris)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filter Menu Bawah
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip('Pending'),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip('Proses'),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip('Selesai'),
                  if (isSuperAdmin) ...[
                    const SizedBox(width: 8),
                    _buildStatusFilterChip('Approve'),
                    const SizedBox(width: 8),
                    _buildStatusFilterChip('Delete'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // KONDISI TAMPILAN MENU APPROVE DAN DELETE AKUN (Hanya Admin Utama)
            if (_filterStatus == 'Approve' && isSuperAdmin) ...[
              const Text(
                'Persetujuan Akun Baru',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              widget.users
                      .where((u) => !u.isApproved && u.username != 'admin1')
                      .isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Tidak ada akun yang menunggu persetujuan.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.users
                          .where((u) => !u.isApproved && u.username != 'admin1')
                          .length,
                      itemBuilder: (context, index) {
                        final unapprovedUser = widget.users
                            .where(
                              (u) => !u.isApproved && u.username != 'admin1',
                            )
                            .toList()[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        unapprovedUser.username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Role: ${unapprovedUser.role.name}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          unapprovedUser.isApproved = true;
                                        });
                                        await _saveDataToStorage();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Akun ${unapprovedUser.username} disetujui!',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Terima',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          widget.users.remove(unapprovedUser);
                                        });
                                        await _saveDataToStorage();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Akun ${unapprovedUser.username} ditolak dan dihapus!',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Tolak',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ] else if (_filterStatus == 'Delete' && isSuperAdmin) ...[
              const Text(
                'Manajemen Hapus Akun Terdaftar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              widget.users.where((u) => u.username != 'admin1').isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Tidak ada akun lain yang terdaftar.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.users
                          .where((u) => u.username != 'admin1')
                          .length,
                      itemBuilder: (context, index) {
                        final registeredUser = widget.users
                            .where((u) => u.username != 'admin1')
                            .toList()[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.redAccent,
                                  child: Icon(
                                    Icons.supervised_user_circle,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        registeredUser.username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Role: ${registeredUser.role.name} • ${registeredUser.isApproved ? "Aktif" : "Pending"}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      widget.users.remove(registeredUser);
                                    });
                                    await _saveDataToStorage();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Akun ${registeredUser.username} berhasil dihapus!',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Record Data ($_filterStatus)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${filteredItems.length} Items',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.shade50,
                            child: const Icon(
                              Icons.inbox,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        item.status.name,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor:
                                          item.status == ItemStatus.Pending
                                          ? Colors.redAccent
                                          : item.status == ItemStatus.Proses
                                          ? Colors.orange
                                          : Colors.green,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                Text(
                                  '${item.category.name} • ${item.createdBy}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tombol Edit Status (Admin Utama & Admin Biasa)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () => _showStatusDialog(item),
                          ),
                          // Tombol Delete (Hanya Admin Utama)
                          if (isSuperAdmin)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                setState(() {
                                  widget.items.remove(item);
                                });
                                await _saveDataToStorage();
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F4C3A),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemScreen(
                currentUser: widget.currentUser,
                items: widget.items,
              ),
            ),
          );
          await _saveDataToStorage();
          setState(() {});
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Entry',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showStatusDialog(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Status Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ItemStatus.values.map((status) {
              return ListTile(
                title: Text(status.name),
                onTap: () async {
                  setState(() {
                    item.status = status;
                  });
                  await _saveDataToStorage();
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                val,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String label) {
    bool isSelected = _filterStatus == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.deepOrange,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      onSelected: (selected) {
        if (selected) setState(() => _filterStatus = label);
      },
    );
  }
}
