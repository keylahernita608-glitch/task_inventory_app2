enum ItemCategory { Task, Inventaris }
enum ItemStatus { Pending, Proses, Selesai }
enum UserRole { User, AdminSuper, AdminBiasa }

class InventoryItem {
  final String id;
  final String title;
  final ItemCategory category;
  final String description;
  ItemStatus status;
  final String createdBy;

  InventoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.status = ItemStatus.Pending,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.index,
        'description': description,
        'status': status.index,
        'createdBy': createdBy,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'],
        title: json['title'],
        category: ItemCategory.values[json['category']],
        description: json['description'],
        status: ItemStatus.values[json['status']],
        createdBy: json['createdBy'],
      );
}

class AppUser {
  final String username;
  final String password;
  final UserRole role;
  bool isApproved;

  AppUser({
    required this.username,
    required this.password,
    required this.role,
    this.isApproved = false,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role.index,
        'isApproved': isApproved,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        username: json['username'],
        password: json['password'],
        role: UserRole.values[json['role']],
        isApproved: json['isApproved'],
      );
}