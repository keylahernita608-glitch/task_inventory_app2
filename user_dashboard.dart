import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'add_item_screen.dart';
import 'login_screen.dart';

class UserDashboard extends StatefulWidget {
  final AppUser currentUser;
  final List<InventoryItem> items;
  final List<AppUser> users;

  const UserDashboard({Key? key, required this.currentUser, required this.items, required this.users}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String _filterCategory = 'All';

  @override
  Widget build(BuildContext context) {
    int totalItems = widget.items.length;
    int totalTask = widget.items.where((i) => i.category == ItemCategory.Task).length;
    int totalInventaris = widget.items.where((i) => i.category == ItemCategory.Inventaris).length;
    int pendingCount = widget.items.where((i) => i.status == ItemStatus.Pending).length;
    int prosesCount = widget.items.where((i) => i.status == ItemStatus.Proses).length;
    int selesaiCount = widget.items.where((i) => i.status == ItemStatus.Selesai).length;

    List<InventoryItem> filteredItems = widget.items.where((item) {
      if (_filterCategory == 'Task') return item.category == ItemCategory.Task;
      if (_filterCategory == 'Inventaris') return item.category == ItemCategory.Inventaris;
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
              decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.grid_view, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('User Workspace', style: TextStyle(fontSize: 16, color: Colors.white)),
                Text('Account: ${widget.currentUser.username}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                MaterialPageRoute(builder: (_) => LoginScreen(users: widget.users, items: widget.items)),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C3A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat Datang, ${widget.currentUser.username}!',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Pantau status inventaris dan penyelesaian tugas operasional Anda secara real-time.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('RINGKASAN METRIK ENTERPRISE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildStatCard(totalItems.toString(), 'Total Item', Icons.inventory_2_outlined, Colors.blue),
                _buildStatCard(totalTask.toString(), 'Total Task', Icons.check_circle_outline, Colors.teal),
                _buildStatCard(totalInventaris.toString(), 'Inventaris', Icons.widgets_outlined, Colors.orange),
                _buildStatCard(pendingCount.toString(), 'Pending Stat...', Icons.pending_actions, Colors.redAccent),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Penyelesaian Status Task & Inventaris', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Expanded(flex: selesaiCount == 0 ? 1 : selesaiCount, child: Container(height: 10, color: Colors.green)),
                        Expanded(flex: prosesCount == 0 ? 1 : prosesCount, child: Container(height: 10, color: Colors.orange)),
                        Expanded(flex: pendingCount == 0 ? 1 : pendingCount, child: Container(height: 10, color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDotStatus('Selesai: $selesaiCount', Colors.green),
                      _buildDotStatus('Proses: $prosesCount', Colors.orange),
                      _buildDotStatus('Pending: $pendingCount', Colors.red),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Record Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${filteredItems.length} Item', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Task'),
                const SizedBox(width: 8),
                _buildFilterChip('Inventaris'),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.category == ItemCategory.Task ? Colors.blue.shade50 : Colors.orange.shade50,
                      child: Icon(
                        item.category == ItemCategory.Task ? Icons.check_circle_outline : Icons.inventory_2_outlined,
                        color: item.category == ItemCategory.Task ? Colors.blue : Colors.orange,
                      ),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.category.name} • ${item.createdBy}'),
                    trailing: Chip(
                      label: Text(item.status.name, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: item.status == ItemStatus.Pending
                          ? Colors.redAccent
                          : item.status == ItemStatus.Proses
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F4C3A),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddItemScreen(currentUser: widget.currentUser, items: widget.items)),
          );
          setState(() {});
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Entry', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDotStatus(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _filterCategory == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0F4C3A),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      onSelected: (selected) {
        if (selected) setState(() => _filterCategory = label);
      },
    );
  }
}