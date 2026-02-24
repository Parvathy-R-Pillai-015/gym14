import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TrainerFoodMonitoringScreen extends StatefulWidget {
  final int trainerId;
  final String trainerName;

  const TrainerFoodMonitoringScreen({
    super.key,
    required this.trainerId,
    required this.trainerName,
  });

  @override
  State<TrainerFoodMonitoringScreen> createState() =>
      _TrainerFoodMonitoringScreenState();
}

class _TrainerFoodMonitoringScreenState
    extends State<TrainerFoodMonitoringScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _usersCalories = [];
  Map<int, Map<String, dynamic>> _userDailyDetails = {};
  Map<int, Map<String, dynamic>> _userHistoryData = {};
  Map<int, bool> _loadingDetailsMap = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  int? _expandedUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadAssignedUsersCalories();
    setState(() => _isLoading = false);
  }

  Future<void> _loadAssignedUsersCalories() async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/trainer/food/users/calories/?trainer_id=${widget.trainerId}&date=$dateStr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _usersCalories = List<Map<String, dynamic>>.from(data['users']);
            _userDailyDetails.clear();
            _expandedUserId = null;
          });
        }
      }
    } catch (e) {
      print('Error loading users calories: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading food data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserDailyDetails(int userId, String userName) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/trainer/food/user/daily/?trainer_id=${widget.trainerId}&user_id=$userId&date=$dateStr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _userDailyDetails[userId] = data;
          });
        }
      }
    } catch (e) {
      print('Error loading user daily details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading details for $userName'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserHistory(int userId, String userName) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/trainer/food/user/history/?trainer_id=${widget.trainerId}&user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _userHistoryData[userId] = data;
          });
          _showHistoryDialog(userName, data);
        }
      }
    } catch (e) {
      print('Error loading user history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history for $userName'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHistoryDialog(String userName, Map<String, dynamic> historyData) {
    final history = List<Map<String, dynamic>>.from(historyData['history'] ?? []);
    final stats = historyData['statistics'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$userName - 30-Day History'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Card
              Card(
                color: const Color(0xFF0F766E).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${stats['average_calories']?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                              const Text('Avg/Day', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${stats['max_calories']?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const Text('Max', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${stats['min_calories']?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text('Min', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: ${stats['target_calories']?.toStringAsFixed(0) ?? '0'} cal/day',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // History List
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final day = history[index];
                    final dayCalories = day['total_calories'] ?? 0.0;
                    final target = stats['target_calories'] ?? 2000;
                    final percentage = (dayCalories / target * 100).clamp(0, 200);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          day['date'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentage <= 100 ? Colors.green : Colors.orange,
                              ),
                              minHeight: 6,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dayCalories.toStringAsFixed(0)} cal (${percentage.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${(dayCalories / target * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: percentage <= 100 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _userDailyDetails.clear();
      _expandedUserId = null;
    });
    _loadAssignedUsersCalories();
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _userDailyDetails.clear();
      _expandedUserId = null;
    });
    _loadAssignedUsersCalories();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _userDailyDetails.clear();
        _expandedUserId = null;
      });
      _loadAssignedUsersCalories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Monitoring'),
        backgroundColor: const Color(0xFF1F2933),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Navigation
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _previousDay,
                          ),
                          GestureDetector(
                            onTap: _selectDate,
                            child: Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _selectedDate.isBefore(DateTime.now())
                                ? _nextDay
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Users Calories List
                  if (_usersCalories.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users assigned yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _usersCalories.length,
                      itemBuilder: (context, index) {
                        final user = _usersCalories[index];
                        final userId = user['user_id'];
                        final userName = user['user_name'];
                        final totalCalories = user['total_calories'] ?? 0.0;
                        final targetCalories = user['target_calories'] ?? 2000;
                        final percentage = ((totalCalories / targetCalories) * 100)
                            .clamp(0, 200);
                        final isExpanded = _expandedUserId == userId;
                        final details = _userDailyDetails[userId];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // User Header Card
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF0F766E),
                                      const Color(0xFF0F766E).withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // User Name
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Calorie Progress
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${totalCalories.toStringAsFixed(0)} cal',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Target: ${targetCalories.toStringAsFixed(0)} cal',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${percentage.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Progress Bar
                                      LinearProgressIndicator(
                                        value:
                                            (percentage / 100).clamp(0.0, 1.0),
                                        backgroundColor:
                                            Colors.white.withOpacity(0.3),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          percentage <= 100
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        minHeight: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Meal Breakdown
                              if (isExpanded) ...[
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Meal Breakdown',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_loadingDetailsMap[userId] == true)
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      else if (details != null)
                                        _buildMealBreakdown(
                                          details['meal_breakdown'] ?? {},
                                        )
                                      else
                                        Text(
                                          'No data',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Food Entries',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (_loadingDetailsMap[userId] == true)
                                        const SizedBox.shrink()
                                      else if (details != null)
                                        _buildFoodEntries(
                                          details['entries'] ?? [],
                                        )
                                      else
                                        Text(
                                          'No entries',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                ),
                              ],

                              // Action Buttons
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        if (isExpanded) {
                                          // Collapsing
                                          setState(() {
                                            _expandedUserId = null;
                                          });
                                        } else {
                                          // Expanding
                                          setState(() {
                                            _expandedUserId = userId;
                                            if (details == null) {
                                              _loadingDetailsMap[userId] = true;
                                            }
                                          });
                                          // Load details if not already loaded
                                          if (details == null) {
                                            await _loadUserDailyDetails(
                                                userId, userName);
                                            setState(() {
                                              _loadingDetailsMap[userId] = false;
                                            });
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                      ),
                                      label: Text(
                                        isExpanded
                                            ? 'Collapse'
                                            : 'Details',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF0F766E),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        await _loadUserHistory(
                                            userId, userName);
                                      },
                                      icon: const Icon(Icons.history),
                                      label: const Text('History'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildMealBreakdown(Map<String, dynamic> breakdown) {
    if (breakdown.isEmpty) {
      return Text(
        'No meals logged',
        style: TextStyle(color: Colors.grey[600]),
      );
    }

    return Column(
      children: breakdown.entries.map((entry) {
        final mealType = entry.key;
        final calories = (entry.value as num).toDouble();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealType.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${calories.toStringAsFixed(0)} cal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFoodEntries(List<dynamic> entries) {
    if (entries.isEmpty) {
      return Text(
        'No entries',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
    }

    return Column(
      children: entries.map((entry) {
        final foodName = entry['food_name'] ?? 'Unknown';
        final quantity = entry['quantity'] ?? 0;
        final unit = entry['quantity_unit'] ?? '';
        final calories = entry['calories'] ?? 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$quantity $unit',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${calories.toStringAsFixed(0)} cal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
