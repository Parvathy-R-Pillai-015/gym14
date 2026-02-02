import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pin_entry_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int userId;
  final int amount;
  final int months;
  final String? userName;

  const PaymentScreen({
    Key? key,
    required this.userId,
    required this.amount,
    required this.months,
    this.userName,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _userName = widget.userName ?? 'User';
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'value': 'gpay',
      'label': 'Google Pay',
      'icon': Icons.account_balance_wallet,
      'color': Colors.blue,
    },
    {
      'value': 'phonepe',
      'label': 'PhonePe',
      'icon': Icons.phone_android,
      'color': Colors.purple,
    },
    {
      'value': 'paytm',
      'label': 'Paytm',
      'icon': Icons.payment,
      'color': Colors.indigo,
    },
    {
      'value': 'upi',
      'label': 'Other UPI',
      'icon': Icons.qr_code,
      'color': Colors.green,
    },
  ];

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      _showErrorDialog('Please select a payment method');
      return;
    }

    // Navigate to PIN entry screen for payment verification
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinEntryScreen(
          userId: widget.userId,
          userName: _userName,
          renewalMonths: widget.months,
          amount: widget.amount.toDouble(),
          paymentMethod: _selectedPaymentMethod!,
          discountPercentage: 0,
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Payment Successful!'),
          ],
        ),
        content: Text(
          'Your payment of ₹${widget.amount} has been processed successfully.\n\n'
          'You are now enrolled for ${widget.months} month${widget.months > 1 ? 's' : ''}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to home or dashboard
              Navigator.pushReplacementNamed(
                context,
                '/home',
                arguments: {
                  'userId': widget.userId,
                  'userName': _userName,
                },
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Gym Membership', style: TextStyle(fontSize: 16)),
                        Text(
                          '${widget.months} Month${widget.months > 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount', style: TextStyle(fontSize: 16)),
                        Text(
                          '₹${widget.amount}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment Method Selection
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...

_paymentMethods.map((method) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: _selectedPaymentMethod == method['value']
                        ? Colors.blue
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: RadioListTile<String>(
                  value: method['value'],
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                  title: Row(
                    children: [
                      Icon(
                        method['icon'],
                        color: method['color'],
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        method['label'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  activeColor: Colors.blue,
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Payment Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Payment Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Your payment is 100% secure\n'
                    '• Instant confirmation after payment\n'
                    '• Full refund within 7 days if cancelled',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Pay Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Pay ₹${widget.amount}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
