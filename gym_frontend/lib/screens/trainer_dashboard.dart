import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'video_upload_screen.dart';
import 'manage_videos_screen.dart';
import 'trainer_chat_list_screen.dart';
import 'trainer_food_monitoring_screen.dart';

class TrainerDashboard extends StatefulWidget {
  final int trainerId;
  final String trainerName;

  const TrainerDashboard({
    super.key,
    required this.trainerId,
    required this.trainerName,
  });

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  List<Map<String, dynamic>> _assignedUsers = [];
  List<Map<String, dynamic>> _pendingAttendance = [];
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  bool _isLoading = true;
  String _trainerGoalCategory = 'weight_loss';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadAssignedUsers(),
      _loadPendingAttendance(),
      _loadReviews(),
      _loadTrainerDetails(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadAssignedUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/trainer/${widget.trainerId}/users/',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final users = List<Map<String, dynamic>>.from(data['users']);
          
          // Check diet plan status for each user
          for (var user in users) {
            final dietResponse = await http.get(
              Uri.parse('http://127.0.0.1:8000/api/diet/plan/user/${user['id']}/')
            );
            if (dietResponse.statusCode == 200) {
              final dietData = json.decode(dietResponse.body);
              user['has_diet_plan'] = dietData['success'] == true && dietData['diet_plan'] != null;
            } else {
              user['has_diet_plan'] = false;
            }
          }
          
          setState(() {
            _assignedUsers = users;
          });
        }
      }
    } catch (e) {
      print('Error loading assigned users: $e');
    }
  }

  Future<void> _loadPendingAttendance() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/trainer/${widget.trainerId}/attendance/pending/',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _pendingAttendance = List<Map<String, dynamic>>.from(
              data['requests'],
            );
          });
        }
      }
    } catch (e) {
      print('Error loading pending attendance: $e');
    }
  }

  Future<void> _loadReviews() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/reviews/trainer/${widget.trainerId}/',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _reviews = List<Map<String, dynamic>>.from(data['reviews']);
            _averageRating = data['average_rating'].toDouble();
          });
        }
      }
    } catch (e) {
      print('Error loading reviews: $e');
    }
  }

  Future<void> _loadTrainerDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/trainers/${widget.trainerId}/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _trainerGoalCategory = data['goal_category'] ?? 'weight_loss';
          });
        }
      }
    } catch (e) {
      print('Error loading trainer details: $e');
    }
  }

  Future<void> _acceptAttendance(int attendanceId, String userName) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/attendance/accept/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'attendance_id': attendanceId,
          'status': 'accepted',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attendance accepted for $userName'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewUserAttendance(int userId, String userName) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/attendance/user/$userId/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showAttendanceDialog(
            userName,
            List<Map<String, dynamic>>.from(data['attendances']),
            data['total_accepted'],
            data['total_pending'],
            data['total_absent'] ?? 0,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAttendanceDialog(
    String userName,
    List<Map<String, dynamic>> attendances,
    int totalAccepted,
    int totalPending,
    int totalAbsent,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$userName - Attendance'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Card(
                color: const Color(0xFF7B4EFF).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$totalAccepted',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B4EFF),
                            ),
                          ),
                          const Text('Accepted'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$totalPending',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const Text('Pending'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$totalAbsent',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Text('Absent'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: attendances.length,
                  itemBuilder: (context, index) {
                    final att = attendances[index];
                    final status = att['status'];
                    return ListTile(
                      leading: Icon(
                        status == 'accepted'
                            ? Icons.check_circle
                            : status == 'pending'
                            ? Icons.pending
                            : status == 'absent'
                            ? Icons.event_busy
                            : Icons.cancel,
                        color: status == 'accepted'
                            ? Colors.green
                            : status == 'pending'
                            ? Colors.orange
                            : status == 'absent'
                            ? Colors.red
                            : Colors.grey,
                      ),
                      title: Text(att['date']),
                      subtitle: Text('Status: ${status.toUpperCase()}'),
                      trailing: att['accepted_date'] != null
                          ? Text(
                              'Accepted: ${att['accepted_date']}',
                              style: const TextStyle(fontSize: 10),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Mobile', user['mobile']),
              _buildDetailRow('Age', '${user['age']} years'),
              _buildDetailRow('Gender', user['gender']),
              _buildDetailRow('Current Weight', '${user['current_weight']} kg'),
              _buildDetailRow('Current Height', '${user['current_height']} cm'),
              _buildDetailRow('Goal', user['goal']),
              _buildDetailRow('Target Weight', '${user['target_weight']} kg'),
              _buildDetailRow(
                'Target Months',
                '${user['target_months']} months',
              ),
              _buildDetailRow('Workout Time', user['workout_time']),
              _buildDetailRow('Diet Preference', user['diet_preference']),
              if (user['food_allergies'] != '')
                _buildDetailRow('Food Allergies', user['food_allergies']),
              if (user['health_conditions'] != '')
                _buildDetailRow('Health Conditions', user['health_conditions']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _createDietPlan(Map<String, dynamic> user) async {
    // Calculate target calories
    final calcResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/diet/calculate/${user['id']}/'),
    );

    if (calcResponse.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to calculate calories'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final calcData = json.decode(calcResponse.body);
    final targetCalories = calcData['target_calories'];
    final goal = calcData['goal'];
    final allergies = calcData['food_allergies'];
    final currentWeight = calcData['current_weight'];

    // Get diet templates
    String templatesUrl = 'http://127.0.0.1:8000/api/diet/templates/?goal=$goal';
    
    // For 'others' goal, pass user weight instead of target calories
    if (goal == 'others') {
      templatesUrl += '&user_weight=$currentWeight';
    } else {
      templatesUrl += '&target_calories=$targetCalories';
    }
    
    final templatesResponse = await http.get(Uri.parse(templatesUrl));

    if (templatesResponse.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load templates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final templatesData = json.decode(templatesResponse.body);
    final templates = List<Map<String, dynamic>>.from(templatesData['templates']);

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No templates found for $goal goal'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show diet plan creation dialog
    showDialog(
      context: context,
      builder: (context) => _DietPlanDialog(
        userId: user['id'],
        userName: user['name'],
        trainerId: widget.trainerId,
        targetCalories: targetCalories,
        goal: goal,
        allergies: allergies,
        templates: templates,
      ),
    );
  }

  void _viewDietPlan(Map<String, dynamic> user) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/diet/plan/user/${user['id']}/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['diet_plan'] != null) {
          final dietPlan = data['diet_plan'];
          _showDietPlanDetails(user['name'], dietPlan);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No diet plan found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading diet plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDietPlanDetails(String userName, Map<String, dynamic> dietPlan) {
    // Parse meals_data if it's a JSON string
    final mealsData = dietPlan['meals_data'] is String
        ? json.decode(dietPlan['meals_data'])
        : dietPlan['meals_data'] as Map<String, dynamic>;
    
    final is7DayPlan = mealsData.containsKey('monday');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$userName - Diet Plan'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dietPlan['plan_name'] ?? 'Diet Plan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Calories: ${dietPlan['target_calories'] ?? 'N/A'} cal/day'),
                        Text('Created: ${dietPlan['created_at'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (is7DayPlan) ...[
                  const Text(
                    '7-Day Meal Plan:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'].map((day) {
                    final dayMeals = mealsData[day];
                    if (dayMeals == null) return const SizedBox.shrink();
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          day.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dayMeals.containsKey('breakfast'))
                                  _buildMealSection('Breakfast', dayMeals['breakfast']),
                                if (dayMeals.containsKey('snack1'))
                                  _buildMealSection('Morning Snack', dayMeals['snack1']),
                                if (dayMeals.containsKey('lunch'))
                                  _buildMealSection('Lunch', dayMeals['lunch']),
                                if (dayMeals.containsKey('snack2'))
                                  _buildMealSection('Evening Snack', dayMeals['snack2']),
                                if (dayMeals.containsKey('dinner'))
                                  _buildMealSection('Dinner', dayMeals['dinner']),
                                if (dayMeals.containsKey('snacks'))
                                  _buildMealSection('Snacks', dayMeals['snacks']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ] else ...[
                  const Text(
                    'Daily Meal Plan:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mealsData.containsKey('breakfast'))
                            _buildMealSection('Breakfast', mealsData['breakfast']),
                          if (mealsData.containsKey('snack1'))
                            _buildMealSection('Morning Snack', mealsData['snack1']),
                          if (mealsData.containsKey('lunch'))
                            _buildMealSection('Lunch', mealsData['lunch']),
                          if (mealsData.containsKey('snack2'))
                            _buildMealSection('Evening Snack', mealsData['snack2']),
                          if (mealsData.containsKey('dinner'))
                            _buildMealSection('Dinner', mealsData['dinner']),
                          if (mealsData.containsKey('snacks'))
                            _buildMealSection('Snacks', mealsData['snacks']),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String mealName, dynamic mealData) {
    if (mealData == null) return const SizedBox.shrink();
    
    // Handle new format: {items: [...], calories: xxx}
    if (mealData is Map && mealData.containsKey('items')) {
      final itemList = List<String>.from(mealData['items'] ?? []);
      final calories = mealData['calories'];
      
      if (itemList.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$mealName:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$calories cal',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...itemList.map((item) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 2),
                child: Text('• $item'),
              );
            }).toList(),
          ],
        ),
      );
    }
    
    // Handle old format: [{food: ..., quantity: ...}]
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$mealName:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...List<Map<String, dynamic>>.from(mealData).map((item) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: Text('• ${item['food']} - ${item['quantity']}'),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Dashboard - ${widget.trainerName}'),
        backgroundColor: const Color(0xFF7B4EFF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble),
            tooltip: 'Chat Messages',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrainerChatListScreen(
                    trainerId: widget.trainerId,
                  ),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pending Attendance Requests
                  if (_pendingAttendance.isNotEmpty) ...[
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.pending_actions,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Pending Attendance Requests (${_pendingAttendance.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _pendingAttendance.length,
                              itemBuilder: (context, index) {
                                final request = _pendingAttendance[index];
                                return Card(
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(request['user_name']),
                                    subtitle: Text('Date: ${request['date']}'),
                                    trailing: ElevatedButton.icon(
                                      onPressed: () => _acceptAttendance(
                                        request['id'],
                                        request['user_name'],
                                      ),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Food Monitoring Section
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                              const SizedBox(width: 10),
                              const Text(
                                'Food Monitoring',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Monitor your users\' daily food intake and calories',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrainerFoodMonitoringScreen(
                                    trainerId: widget.trainerId,
                                    trainerName: widget.trainerName,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Food Calories'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4CAF50),
                              minimumSize: const Size(double.infinity, 45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Video Management Section
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFF06292)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.video_library, color: Colors.white, size: 28),
                              const SizedBox(width: 10),
                              const Text(
                                'Workout Videos',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Upload workout videos for your users',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoUploadScreen(
                                    trainerId: widget.trainerId,
                                    trainerName: widget.trainerName,
                                    trainerGoalCategory: _trainerGoalCategory,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Upload Video'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFE91E63),
                              minimumSize: const Size(double.infinity, 45),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageVideosScreen(
                                    trainerId: widget.trainerId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.video_library),
                            label: const Text('Manage Videos'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              minimumSize: const Size(double.infinity, 45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Assigned Users
                  Text(
                    'My Users (${_assignedUsers.length})',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_assignedUsers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No users assigned yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _assignedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _assignedUsers[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF7B4EFF),
                                      child: Text(
                                        user['name'][0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            user['email'],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: user['remaining_days'] > 30
                                            ? Colors.green
                                            : user['remaining_days'] > 7
                                            ? Colors.orange
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${user['remaining_days']} days left',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInfoChip(
                                      Icons.fitness_center,
                                      'Goal',
                                      user['goal'],
                                    ),
                                    _buildInfoChip(
                                      Icons.calendar_today,
                                      'Plan',
                                      '${user['target_months']} months',
                                    ),
                                    _buildInfoChip(
                                      Icons.check_circle,
                                      'Attendance',
                                      '${user['total_attendance']}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _showUserDetails(user),
                                      icon: const Icon(Icons.info_outline),
                                      label: const Text('View Details'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _viewUserAttendance(
                                        user['id'],
                                        user['name'],
                                      ),
                                      icon: const Icon(Icons.calendar_month),
                                      label: const Text('Attendance'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF7B4EFF,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => user['has_diet_plan'] == true 
                                          ? _viewDietPlan(user)
                                          : _createDietPlan(user),
                                      icon: Icon(user['has_diet_plan'] == true 
                                          ? Icons.visibility 
                                          : Icons.restaurant_menu),
                                      label: Text(user['has_diet_plan'] == true 
                                          ? 'View Diet'
                                          : 'Diet Plan'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: user['has_diet_plan'] == true 
                                            ? Colors.blue
                                            : Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // Reviews Section
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.pink.shade50,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'User Reviews',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (_reviews.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _averageRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_reviews.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No reviews yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _reviews.length,
                              itemBuilder: (context, index) {
                                final review = _reviews[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: Colors.blue,
                                                  child: Text(
                                                    review['user_name'][0]
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  review['user_name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                ...List.generate(5, (i) {
                                                  return Icon(
                                                    i < review['rating']
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 18,
                                                  );
                                                }),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          review['review_text'],
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          review['created_at'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7B4EFF)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _DietPlanDialog extends StatefulWidget {
  final int userId;
  final String userName;
  final int trainerId;
  final int targetCalories;
  final String goal;
  final String allergies;
  final List<Map<String, dynamic>> templates;

  const _DietPlanDialog({
    required this.userId,
    required this.userName,
    required this.trainerId,
    required this.targetCalories,
    required this.goal,
    required this.allergies,
    required this.templates,
  });

  @override
  State<_DietPlanDialog> createState() => _DietPlanDialogState();
}

class _DietPlanDialogState extends State<_DietPlanDialog> {
  int? _selectedTemplateIndex;
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Diet Plan - ${widget.userName}'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Info',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Goal: ${widget.goal.replaceAll('_', ' ').toUpperCase()}'),
                    Text('Target Calories: ${widget.targetCalories} cal/day'),
                    if (widget.allergies != 'none')
                      Text(
                        'Food Allergies: ${widget.allergies}',
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Diet Plan Template:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.templates.length,
                itemBuilder: (context, index) {
                  final template = widget.templates[index];
                  final isSelected = _selectedTemplateIndex == index;
                  return Card(
                    color: isSelected ? Colors.green.shade100 : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTemplateIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    template['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.green.shade900
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template['description'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            if (isSelected) ...[
                              const Divider(),
                              const Text(
                                'Meal Plan Preview:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildMealPreview(
                                template['meals_data'] is String
                                    ? json.decode(template['meals_data'])
                                    : template['meals_data']
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Trainer Notes (Optional)',
                  hintText: 'Add any special instructions or notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedTemplateIndex != null
              ? () => _saveDietPlan()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create Diet Plan'),
        ),
      ],
    );
  }

  Widget _buildMealPreview(Map<String, dynamic> mealsData) {
    // Check if it's 7-day format (has monday, tuesday, etc keys)
    if (mealsData.containsKey('monday')) {
      // Show Monday's plan as sample
      final mondayMeals = mealsData['monday'] as Map<String, dynamic>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sample: Monday\'s Plan',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          _buildMealSection('Breakfast', mondayMeals['breakfast']),
          _buildMealSection('Lunch', mondayMeals['lunch']),
          _buildMealSection('Dinner', mondayMeals['dinner']),
          _buildMealSection('Snacks', mondayMeals['snacks']),
          const SizedBox(height: 4),
          const Text(
            '7-day plan with variety for each day',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: Colors.green,
            ),
          ),
        ],
      );
    } else {
      // Old format or new format: direct meals
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mealsData.containsKey('breakfast'))
            _buildMealSection('Breakfast', mealsData['breakfast']),
          if (mealsData.containsKey('snack1'))
            _buildMealSection('Morning Snack', mealsData['snack1']),
          if (mealsData.containsKey('lunch'))
            _buildMealSection('Lunch', mealsData['lunch']),
          if (mealsData.containsKey('snack2'))
            _buildMealSection('Evening Snack', mealsData['snack2']),
          if (mealsData.containsKey('dinner'))
            _buildMealSection('Dinner', mealsData['dinner']),
          if (mealsData.containsKey('snacks'))
            _buildMealSection('Snacks', mealsData['snacks']),
        ],
      );
    }
  }

  Widget _buildMealSection(String mealName, dynamic mealData) {
    if (mealData == null) return const SizedBox.shrink();
    
    // Handle new format: {items: [...], calories: xxx}
    if (mealData is Map && mealData.containsKey('items')) {
      final itemList = List<String>.from(mealData['items'] ?? []);
      final calories = mealData['calories'];
      
      if (itemList.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$mealName ($calories cal)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.green,
              ),
            ),
            ...itemList.map((item) => Text(
                  '  • $item',
                  style: const TextStyle(fontSize: 10),
                )),
          ],
        ),
      );
    }
    
    // Handle old format: [{food: ..., quantity: ...}]
    final itemList = mealData is List ? mealData : [];
    if (itemList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.green,
            ),
          ),
          ...itemList.map((item) => Text(
                '  • ${item['food']} - ${item['quantity']}',
                style: const TextStyle(fontSize: 10),
              )),
        ],
      ),
    );
  }

  void _saveDietPlan() async {
    if (_selectedTemplateIndex == null) return;

    final template = widget.templates[_selectedTemplateIndex!];

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/diet/plan/create/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'trainer_id': widget.trainerId,
          'template_id': template['id'],
          'plan_name': template['name'],
          'target_calories': widget.targetCalories,
          'meals_data': template['meals_data'],
          'notes': _notesController.text.trim(),
          'start_date': DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      final data = json.decode(response.body);

      Navigator.pop(context);

      if (response.statusCode == 201 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diet plan created for ${widget.userName}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to create diet plan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
