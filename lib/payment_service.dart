import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentConfirm {
  final String id;
  final String applicationNumber;
  final String billNumber;
  final String createdAt;
  final String createdBy;
  final String currency;
  final bool hasPopup;
  final double paidAmount;
  final String source;
  final bool success;
  final String? testMessage;

  PaymentConfirm({
    required this.id,
    required this.applicationNumber,
    required this.billNumber,
    required this.createdAt,
    required this.createdBy,
    required this.currency,
    required this.hasPopup,
    required this.paidAmount,
    required this.source,
    required this.success,
    this.testMessage,
  });

  factory PaymentConfirm.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PaymentConfirm(
      id: doc.id,
      applicationNumber: data['applicationNumber'] ?? '',
      billNumber: data['billNumber'] ?? '',
      createdAt: data['createdAt'] ?? '',
      createdBy: data['createdBy'] ?? '',
      currency: data['currency'] ?? 'USD',
      hasPopup: data['hasPopup'] ?? false,
      paidAmount: (data['paidAmount'] ?? 0.0).toDouble(),
      source: data['source'] ?? '',
      success: data['success'] ?? false,
      testMessage: data['testMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'applicationNumber': applicationNumber,
      'billNumber': billNumber,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'currency': currency,
      'hasPopup': hasPopup,
      'paidAmount': paidAmount,
      'source': source,
      'success': success,
      'testMessage': testMessage,
    };
  }

  @override
  String toString() {
    return 'PaymentConfirm(id: $id, applicationNumber: $applicationNumber, billNumber: $billNumber, paidAmount: $paidAmount, success: $success)';
  }
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'payment_confirms';

  // Get real-time stream of all payment confirmations
  Stream<List<PaymentConfirm>> getPaymentConfirmsStream() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentConfirm.fromFirestore(doc))
            .toList());
  }

  // Get payment confirmations by success status
  Stream<List<PaymentConfirm>> getPaymentConfirmsBySuccessStream(bool success) {
    return _firestore
        .collection(_collectionName)
        .where('success', isEqualTo: success)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentConfirm.fromFirestore(doc))
            .toList());
  }

  // Get payment confirmations by source
  Stream<List<PaymentConfirm>> getPaymentConfirmsBySourceStream(String source) {
    return _firestore
        .collection(_collectionName)
        .where('source', isEqualTo: source)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentConfirm.fromFirestore(doc))
            .toList());
  }

  // Get payment confirmations by application number
  Stream<List<PaymentConfirm>> getPaymentConfirmsByApplicationNumberStream(String applicationNumber) {
    return _firestore
        .collection(_collectionName)
        .where('applicationNumber', isEqualTo: applicationNumber)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentConfirm.fromFirestore(doc))
            .toList());
  }

  // Get single payment confirmation
  Future<PaymentConfirm?> getPaymentConfirm(String paymentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(paymentId)
          .get();
      
      if (doc.exists) {
        return PaymentConfirm.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment confirmation: $e');
    }
  }
}
