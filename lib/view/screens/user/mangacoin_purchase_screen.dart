import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mangadive/controllers/auth_controller.dart';
import 'package:mangadive/vnpay_php/vnpay_checkoutview.dart';
import 'package:mangadive/vnpay_php/vnpay_service.dart';

class MangaCoinPurchaseScreen extends StatefulWidget {
  final AuthController authController; // thêm authController

  const MangaCoinPurchaseScreen({Key? key, required this.authController})
      : super(key: key);

  @override
  _MangaCoinPurchaseScreenState createState() =>
      _MangaCoinPurchaseScreenState();
}

class _MangaCoinPurchaseScreenState extends State<MangaCoinPurchaseScreen> {
  int? selectedAmount;
  final TextEditingController customAmountController = TextEditingController();
  bool isCustomSelected = false;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final VNPayService vnpayService = VNPayService();

  void _onTileTap(int amount) {
    setState(() {
      selectedAmount = amount;
      isCustomSelected = false;
      customAmountController.clear();
    });
  }

  void _onCustomAmountChanged(String value) {
    setState(() {
      isCustomSelected = true;
      selectedAmount = int.tryParse(value.replaceAll('.', ''));
    });
  }

  Future<void> _onBuy() async {
    if (selectedAmount == null || selectedAmount! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn hoặc nhập số tiền hợp lệ.')),
      );
      return;
    }
    final amount = selectedAmount!;
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final payUrl = await vnpayService.createOrder(orderId, amount);
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VnpayCheckoutPage(payUrl)),
      );

      if (result != null && result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán thành công!')),
        );

        final earnedMangaCoin = (amount / 1000).floor();
        final uid = FirebaseAuth.instance.currentUser!.uid;

        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

        await userDoc.update({
          'mangaCoin': FieldValue.increment(earnedMangaCoin),
        });
        await widget.authController.reloadUserProfile();
        // Optional: fetch user mới nếu cần
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán không thành công.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khởi tạo thanh toán: $e')),
      );
    }
  }

  Widget _buildAmountTile(int amount) {
    final bool isSelected = !isCustomSelected && selectedAmount == amount;
    final int coin = amount ~/ 1000;

    return ListTile(
      title: Text(
        '${currencyFormat.format(amount)} = $coin MangaCoin',
        style: const TextStyle(color: Colors.black),
      ),
      tileColor: isSelected ? Colors.green.withOpacity(0.2) : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => _onTileTap(amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mua MangaCoin'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAmountTile(10000),
            const SizedBox(height: 10),
            _buildAmountTile(20000),
            const SizedBox(height: 10),
            _buildAmountTile(50000),
            const SizedBox(height: 20),
            TextField(
              controller: customAmountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'Nhập số tiền tùy chọn (VNĐ)',
                labelStyle: const TextStyle(color: Colors.grey),
              ),
              onChanged: _onCustomAmountChanged,
            ),
            if (isCustomSelected && selectedAmount != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '${selectedAmount! ~/ 1000} MangaCoin (${currencyFormat.format(selectedAmount)})',
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Mua bằng VNPAY'),
            ),
          ],
        ),
      ),
    );
  }
}
