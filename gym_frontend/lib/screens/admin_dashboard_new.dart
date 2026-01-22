import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'trainer_management_tab.dart';
import 'admin_chat_tab.dart';

class AdminDashboardNew extends StatefulWidget {
  const AdminDashboardNew({Key? key}) : super(key: key);

  @override
  State<AdminDashboardNew> createState() => _AdminDashboardNewState();
}

class _AdminDashboardNewState extends State<AdminDashboardNew> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _paidUsers = [];
  List<Map<String, dynamic>> _unpaidUsers = [];
  List<Map<String, dynamic>> _allReviews = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAllData();
  }
  
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.wait([
      _loadAllUsers(),
      _loadPaidUsers(),
      _loadUnpaidUsers(),
      _loadAllReviews(),
    ]);
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _loadAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/users/all/'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _allUsers = List<Map<String, dynamic>>.from(data['users']);
          });
        }
      }
    } catch (e) {
      print('Error loading all users: $e');
    }
  }
  
  Future<void> _loadPaidUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/users/paid/'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _paidUsers = List<Map<String, dynamic>>.from(data['users']);
          });
        }
      }
    } catch (e) {
      print('Error loading paid users: $e');
    }
  }
  
  Future<void> _loadUnpaidUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/users/unpaid/'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _unpaidUsers = List<Map<String, dynamic>>.from(data['users']);
          });
        }
      }
    } catch (e) {
      print('Error loading unpaid users: $e');
    }
  }
  
  Future<void> _loadAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/reviews/all/'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _allReviews = List<Map<String, dynamic>>.from(data['reviews']);
          });
        }
      }
    } catch (e) {
      print('Error loading reviews: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7B4EFF),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Paid Users'),
            Tab(text: 'Unpaid Users'),
            Tab(text: 'Trainers'),
            Tab(text: 'Reviews'),
            Tab(text: 'Chats'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllUsersTab(),
                _buildPaidUsersTab(),
                _buildUnpaidUsersTab(),
                const TrainerManagementTab(),
                _buildReviewsTab(),
                const AdminChatTab(),
              ],
            ),
    );
  }
  
  Widget _buildAllUsersTab() {
    if (_allUsers.isEmpty) {
      return const Center(child: Text('No users found'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allUsers.length,
      itemBuilder: (context, index) {
        final user = _allUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: user['payment_status'] ? Colors.green : Colors.orange,
              child: Text(
                user['name'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email']),
                if (user['mobile'] != null) Text('Mobile: ${user['mobile']}'),
                if (user['goal'] != null) 
                  Text('Goal: ${user['goal'].toString().replaceAll('_', ' ').toUpperCase()}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user['payment_status'] ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['payment_status'] ? 'PAID' : 'UNPAID',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                if (user['payment_amount'] != null && user['payment_amount'] > 0)
                  Text('₹${user['payment_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPaidUsersTab() {
    if (_paidUsers.isEmpty) {
      return const Center(child: Text('No paid users found'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paidUsers.length,
      itemBuilder: (context, index) {
        final user = _paidUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                user['name'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${user['email']} • ₹${user['payment_amount']}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Mobile', user['mobile']),
                    _buildDetailRow('Age', '${user['age']} years'),
                    _buildDetailRow('Gender', user['gender'].toString().toUpperCase()),
                    _buildDetailRow('Goal', user['goal'].toString().replaceAll('_', ' ').toUpperCase()),
                    _buildDetailRow('Current Weight', '${user['current_weight']} kg'),
                    _buildDetailRow('Target Weight', '${user['target_weight']} kg'),
                    _buildDetailRow('Duration', '${user['target_months']} months'),
                    _buildDetailRow('Workout Time', user['workout_time'] == 'morning' ? 'Morning' : 'Evening'),
                    _buildDetailRow('Diet', user['diet_preference'].toString().replaceAll('_', ' ').toUpperCase()),
                    _buildDetailRow('Food Allergies', user['food_allergies'] ?? 'None'),
                    _buildDetailRow('Health Conditions', user['health_conditions'] ?? 'None'),
                    _buildDetailRow('Payment Method', user['payment_method'] ?? 'Not Recorded'),
                    _buildTrainerDetailRow(user['assigned_trainer']),
                    _buildDetailRow('Payment Date', user['payment_date']),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildUnpaidUsersTab() {
    if (_unpaidUsers.isEmpty) {
      return const Center(child: Text('No unpaid users found'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _unpaidUsers.length,
      itemBuilder: (context, index) {
        final user = _unpaidUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(
                user['name'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email']),
                if (user['mobile'] != null) Text('Mobile: ${user['mobile']}'),
                if (user['goal'] != null)
                  Text('Goal: ${user['goal'].toString().replaceAll('_', ' ').toUpperCase()}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                if (user['payment_amount'] != null)
                  Text('₹${user['payment_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrainerDetailRow(dynamic trainer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  'Assigned Trainer:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  trainer != null ? trainer['name'] : 'Not Assigned',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (trainer != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(left: 140),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTrainerDetail('Email', trainer['email']),
                  _buildTrainerDetail('Mobile', trainer['mobile']),
                  _buildTrainerDetail('Gender', trainer['gender'].toString().toUpperCase()),
                  _buildTrainerDetail('Experience', '${trainer['experience']} years'),
                  _buildTrainerDetail('Specialization', trainer['specialization']),
                  _buildTrainerDetail('Certification', trainer['certification']),
                  if (trainer['goal_category'] != null)
                    _buildTrainerDetail('Assigned Category', 
                      trainer['goal_category'].toString().replaceAll('_', ' ').toUpperCase()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildReviewsTab() {
    if (_allReviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allReviews.length,
      itemBuilder: (context, index) {
        final review = _allReviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                review['user_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review['user_email'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < review['rating'] ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 16, color: Color(0xFF7B4EFF)),
                      const SizedBox(width: 4),
                      const Text(
                        'Trainer: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        review['trainer_name'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B4EFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  review['review_text'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    review['created_at'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTrainerDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
