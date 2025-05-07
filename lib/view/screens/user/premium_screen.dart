import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mangadive/controllers/auth_controller.dart';

class PremiumBottomSheet {
  static void show(BuildContext context, AuthController authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _PremiumOptionsSheet(authController: authController);
      },
    );
  }
}

class _PremiumOptionsSheet extends StatefulWidget {
  final AuthController authController;

  const _PremiumOptionsSheet({required this.authController});

  @override
  State<_PremiumOptionsSheet> createState() => _PremiumOptionsSheetState();
}

class _PremiumOptionsSheetState extends State<_PremiumOptionsSheet> {
  String selectedPlan = '3 Tháng'; // mặc định

  void _onSelectPlan(String plan) {
    setState(() {
      selectedPlan = plan;
    });
  }

  Widget _buildPlanOption({
    required String planId,
    required String title,
    required String price,
    String? oldPrice,
  }) {
    final bool isSelected = selectedPlan == planId;

    return GestureDetector(
      onTap: () => _onSelectPlan(planId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[800]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(price,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold)),
              if (oldPrice != null)
                Text(oldPrice,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    )),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscription() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin người dùng')),
      );
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tài khoản không tồn tại')),
      );
      return;
    }

    final userData = snapshot.data()!;
    int currentMC = userData['mangaCoin'] ?? 0;
    Timestamp? currentPremiumExpireAtTS = userData['premiumExpireAt'];
    DateTime now = DateTime.now();
    DateTime currentExpire = currentPremiumExpireAtTS != null
        ? currentPremiumExpireAtTS.toDate().isAfter(now)
            ? currentPremiumExpireAtTS.toDate()
            : now
        : now;

    int cost = 0;
    Duration duration = Duration.zero;

    if (selectedPlan == '1 Tháng') {
      cost = 10;
      duration = const Duration(days: 30);
    } else if (selectedPlan == '3 tháng' || selectedPlan == '3 Tháng') {
      cost = 25;
      duration = const Duration(days: 90);
    } else if (selectedPlan == '1 năm' || selectedPlan == '1 Năm') {
      cost = 100;
      duration = const Duration(days: 365);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gói không hợp lệ')),
      );
      return;
    }

    if (currentMC < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không đủ MangaCoin')),
      );
      return;
    }

    final newExpire = currentExpire.add(duration);
    final newMC = currentMC - cost;

    await userDoc.update({
      'mangaCoin': newMC,
      'premium': true,
      'premiumExpireAt': Timestamp.fromDate(newExpire),
    });

    // Gọi reloadUserProfile() để làm mới thông tin người dùng
    await widget.authController.reloadUserProfile();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đăng ký $selectedPlan thành công!')),
    );

    Navigator.pop(context); // đóng bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chọn gói phù hợp với bạn',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 20),
            _buildPlanOption(
              planId: '1 Tháng',
              title: '1 Tháng',
              price: '10 MC',
            ),
            _buildPlanOption(
              planId: '3 tháng',
              title: '3 tháng',
              price: '25 MC',
              oldPrice: '30 MC',
            ),
            _buildPlanOption(
              planId: '1 năm',
              title: '1 năm',
              price: '100 MC',
              oldPrice: '120 MC',
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              label: const Text('Đăng ký'),
              icon: const Icon(Icons.check),
              onPressed: _handleSubscription,
            ),
          ],
        ),
      ),
    );
  }
}
