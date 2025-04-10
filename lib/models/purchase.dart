import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  final String id;
  final String userId;
  final String mangaId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final DateTime purchaseDate;
  final DateTime expiryDate;

  Purchase({
    required this.id,
    required this.userId,
    required this.mangaId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.purchaseDate,
    required this.expiryDate,
  });

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      mangaId: map['mangaId'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'VND',
      status: map['status'] as String? ?? 'pending',
      paymentMethod: map['paymentMethod'] as String? ?? '',
      purchaseDate: map['purchaseDate'] is Timestamp
          ? (map['purchaseDate'] as Timestamp).toDate()
          : DateTime.parse(map['purchaseDate'] as String? ??
              DateTime.now().toIso8601String()),
      expiryDate: map['expiryDate'] is Timestamp
          ? (map['expiryDate'] as Timestamp).toDate()
          : DateTime.parse(map['expiryDate'] as String? ??
              DateTime.now().add(const Duration(days: 365)).toIso8601String()),
    );
  }

  factory Purchase.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Purchase.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mangaId': mangaId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
    };
  }

  Purchase copyWith({
    String? id,
    String? userId,
    String? mangaId,
    double? amount,
    String? currency,
    String? status,
    String? paymentMethod,
    DateTime? purchaseDate,
    DateTime? expiryDate,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mangaId: mangaId ?? this.mangaId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  // Kiểm tra giao dịch đã hoàn thành chưa
  bool get isCompleted => status == 'completed';

  // Kiểm tra giao dịch đã hết hạn chưa
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  // Cập nhật trạng thái giao dịch thành công
  Purchase markAsCompleted() {
    return copyWith(status: 'completed');
  }

  // Cập nhật trạng thái giao dịch thất bại
  Purchase markAsFailed() {
    return copyWith(status: 'failed');
  }
} 