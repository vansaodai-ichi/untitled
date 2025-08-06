import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'payment_service.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final PaymentService _paymentService = PaymentService();
  String _selectedFilter = 'all';
  bool _isFirebaseConnected = false;

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  void _checkFirebaseConnection() {
    try {
      final app = Firebase.app();
      setState(() {
        _isFirebaseConnected = app.name == '[DEFAULT]';
      });
    } catch (e) {
      setState(() {
        _isFirebaseConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'payment_confirmations'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  _isFirebaseConnected ? Icons.cloud_done : Icons.cloud_off,
                  size: 14,
                  color: _isFirebaseConnected ? Colors.greenAccent : Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  _isFirebaseConnected ? 'firebase_connected'.tr() : 'firebase_disconnected'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _isFirebaseConnected ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.language),
              onPressed: () {
                // Toggle between Khmer and English
                if (context.locale == const Locale('km', 'KM')) {
                  context.setLocale(const Locale('en', 'US'));
                } else {
                  context.setLocale(const Locale('km', 'KM'));
                }
              },
              tooltip: context.locale == const Locale('km', 'KM') ? 'switch_to_english'.tr() : 'switch_to_khmer'.tr(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      const Icon(Icons.list_alt, size: 20),
                      const SizedBox(width: 8),
                      Text('all_payments'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'success',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 20, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('successful'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'failed',
                  child: Row(
                    children: [
                      const Icon(Icons.error, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('failed'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'KHQR',
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code, size: 20),
                      const SizedBox(width: 8),
                      Text('khqr_payments'.tr()),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<PaymentConfirm>>(
        stream: _getPaymentStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('${'error'.tr()}: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('loading_payments'.tr()),
                ],
              ),
            );
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'no_payments_found'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEmptyStateMessage(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return _buildPaymentCard(payment);
              },
            ),
          );
        },
      ),
    );
  }

  Stream<List<PaymentConfirm>> _getPaymentStream() {
    switch (_selectedFilter) {
      case 'success':
        return _paymentService.getPaymentConfirmsBySuccessStream(true);
      case 'failed':
        return _paymentService.getPaymentConfirmsBySuccessStream(false);
      case 'KHQR':
        return _paymentService.getPaymentConfirmsBySourceStream('KHQR');
      default:
        return _paymentService.getPaymentConfirmsStream();
    }
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'success':
        return 'no_successful_payments'.tr();
      case 'failed':
        return 'no_failed_payments'.tr();
      case 'KHQR':
        return 'no_khqr_payments'.tr();
      default:
        return 'no_payments_found'.tr();
    }
  }

  Widget _buildPaymentCard(PaymentConfirm payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: payment.success ? Colors.green : Colors.red,
          child: Icon(
            payment.success ? Icons.check_circle : Icons.error,
            color: Colors.white,
          ),
        ),
        title: Text(
          '${payment.currency} ${payment.paidAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'app_number'.tr()}: ${payment.applicationNumber}'),
            Text('${'bill_number'.tr()}: ${payment.billNumber}'),
            Text('${'source'.tr()}: ${payment.source}'),
            Text('${'status'.tr()}: ${payment.success ? 'success'.tr() : 'failed'.tr()}'),
            Text('${'created_by'.tr()}: ${payment.createdBy}'),
            Text('${'date'.tr()}: ${payment.createdAt}'),
            if (payment.testMessage != null)
              Text('${'message'.tr()}: ${payment.testMessage}'),
          ],
        ),
        trailing: payment.hasPopup 
            ? const Icon(Icons.notification_important, color: Colors.orange)
            : null,
        isThreeLine: true,
      ),
    );
  }
}
