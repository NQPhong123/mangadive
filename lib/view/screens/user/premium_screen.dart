import 'package:flutter/material.dart';

class PremiumBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _PremiumOptionsSheet();
      },
    );
  }
}

class _PremiumOptionsSheet extends StatefulWidget {
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
              onPressed: () {
                // TODO: Xử lý đăng ký với selectedPlan
                print('Gói đã chọn: $selectedPlan');
                Navigator.pop(context); // đóng bottom sheet sau khi chọn
              },
            ),
          ],
        ),
      ),
    );
  }
}
