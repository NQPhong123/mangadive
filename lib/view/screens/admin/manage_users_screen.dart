import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _logger = Logger('ManageUsersScreen');
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _toggleAdminRole(String userId, bool isAdmin) async {
    setState(() => _isLoading = true);
    try {
      if (isAdmin) {
        await _firestore.collection('users').doc(userId).update({
          'roles': FieldValue.arrayUnion(['admin']),
        });
        _logger.info('Đã thêm quyền admin cho user $userId');
      } else {
        await _firestore.collection('users').doc(userId).update({
          'roles': FieldValue.arrayRemove(['admin']),
        });
        _logger.info('Đã xóa quyền admin của user $userId');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAdmin ? 'Đã thêm quyền admin' : 'Đã xóa quyền admin',
            ),
          ),
        );
      }
    } catch (e) {
      _logger.severe('Lỗi khi thay đổi quyền admin: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Người dùng')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];
          final currentUser = FirebaseAuth.instance.currentUser;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final email = userData['email'] as String? ?? 'Không có email';
              final username =
                  userData['username'] as String? ?? 'Không có tên';
              final roles = List<String>.from(userData['roles'] ?? []);
              final isAdmin = roles.contains('admin');
              final isSelf = currentUser?.uid == userId;

              return ListTile(
                leading: CircleAvatar(child: Text(username[0].toUpperCase())),
                title: Text(username),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email),
                    Text(
                      'Vai trò: ${roles.isEmpty ? "Người dùng" : roles.join(", ")}',
                      style: TextStyle(
                        color: isAdmin ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing:
                    isSelf
                        ? const Chip(label: Text('Bạn'))
                        : Switch(
                          value: isAdmin,
                          onChanged:
                              _isLoading
                                  ? null
                                  : (value) => _toggleAdminRole(userId, value),
                        ),
              );
            },
          );
        },
      ),
    );
  }
}
