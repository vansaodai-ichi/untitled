import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Confirmations'),
            Text(
              _isFirebaseConnected ? 'Firebase Connected' : 'Firebase Disconnected',
              style: TextStyle(
                fontSize: 12,
                color: _isFirebaseConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Payments'),
              ),
              const PopupMenuItem(
                value: 'success',
                child: Text('Successful'),
              ),
              const PopupMenuItem(
                value: 'failed',
                child: Text('Failed'),
              ),
              const PopupMenuItem(
                value: 'KHQR',
                child: Text('KHQR Payments'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
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
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading payments...'),
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
                    'No payment confirmations found',
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
        return 'No successful payments found';
      case 'failed':
        return 'No failed payments found';
      case 'KHQR':
        return 'No KHQR payments found';
      default:
        return 'No payment confirmations found in Firebase';
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
            Text('App Number: ${payment.applicationNumber}'),
            Text('Bill Number: ${payment.billNumber}'),
            Text('Source: ${payment.source}'),
            Text('Status: ${payment.success ? 'Success' : 'Failed'}'),
            Text('Created By: ${payment.createdBy}'),
            Text('Date: ${payment.createdAt}'),
            if (payment.testMessage != null)
              Text('Message: ${payment.testMessage}'),
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
