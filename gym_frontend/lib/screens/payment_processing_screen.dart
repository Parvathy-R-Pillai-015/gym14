import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class PaymentProcessingScreen extends StatefulWidget {
  const PaymentProcessingScreen({Key? key}) : super(key: key);

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isProcessing = true;
  bool _paymentSuccess = false;
  String _message = '';
  String _receiptNumber = '';
  int _transactionId = 0;
  String _subscriptionEndDate = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPayment();
    });
  }

  Future<void> _processPayment() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      setState(() {
        _isProcessing = false;
        _paymentSuccess = false;
        _message = 'Invalid payment data';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/payment/verify-pin/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': args['user_id'],
          'pin': args['pin'],
          'amount': args['amount'],
          'payment_method': args['payment_method'],
          'renewal_period': args['renewal_period'],
          'discount_percentage': args['discount_percentage'],
        }),
      );

      final data = json.decode(response.body);

      setState(() {
        _isProcessing = false;
        _paymentSuccess = data['success'] ?? false;
        _message = data['message'] ?? 'Unknown error';
        if (_paymentSuccess) {
          _receiptNumber = data['receipt_number'] ?? '';
          _transactionId = data['transaction_id'] ?? 0;
          _subscriptionEndDate = data['subscription_end_date'] ?? '';
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _paymentSuccess = false;
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _goToSetPin() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final result = await Navigator.pushNamed(
        context,
        '/set-payment-pin',
        arguments: {
          'userId': args['user_id'],
          'userName': args['user_name'],
        },
      );

      if (result == true) {
        // PIN was set successfully, go back to try payment again
        Navigator.pop(context);
      }
    }
  }

  Future<void> _downloadReceipt() async {
    try {
      final url = 'http://127.0.0.1:8000/api/payment/receipt/$_transactionId/';
      
      // Open the PDF in a new tab for download
      html.window.open(url, '_blank');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt download started'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isProcessing ? _buildProcessingView() : _buildResultView(),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF6B46C1),
            strokeWidth: 4,
          ),
          const SizedBox(height: 30),
          const Text(
            'Processing Payment...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please wait while we verify your transaction',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Success/Failure Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (_paymentSuccess ? Colors.green : Colors.red).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _paymentSuccess ? Icons.check_circle : Icons.error,
              size: 80,
              color: _paymentSuccess ? Colors.green : Colors.red,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Title
          Text(
            _paymentSuccess ? 'Payment Successful!' : 'Payment Failed',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _paymentSuccess ? Colors.green : Colors.red,
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Message
          Text(
            _message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          if (_paymentSuccess) ...[
            const SizedBox(height: 40),
            
            // Receipt Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildWhiteDetailRow('Receipt Number', _receiptNumber),
                  const SizedBox(height: 12),
                  _buildWhiteDetailRow('Valid Until', _formatDate(_subscriptionEndDate)),
                  const SizedBox(height: 12),
                  _buildWhiteDetailRow('Status', 'COMPLETED'),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Download Receipt Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _downloadReceipt,
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Download Receipt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // User Dashboard Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                    arguments: {
                      'userId': args?['user_id'] ?? 0,
                      'userName': args?['user_name'] ?? 'User',
                    },
                  );
                },
                icon: const Icon(Icons.dashboard, color: Colors.white),
                label: const Text(
                  'User Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Back to Dashboard Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home, color: Color(0xFF6B46C1)),
                label: const Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B46C1),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Success Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Your subscription has been renewed successfully!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 40),
            
            // Check if it's PIN not set error
            if (_message.contains('PIN not set'))
              Column(
                children: [
                  // Set PIN Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _goToSetPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Set Payment PIN Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            
            // Retry Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWhiteDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
