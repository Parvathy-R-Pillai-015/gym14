import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _currentWeightController = TextEditingController();
  final TextEditingController _currentHeightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  
  // Dropdown values
  String? _selectedGender;
  String? _selectedGoal;
  int? _selectedTargetMonths;
  String? _selectedWorkoutTime;
  String? _selectedDietPreference;
  String? _selectedFoodAllergies;
  String? _selectedHealthCondition;
  int? _selectedTrainerId;
  
  bool _isLoading = false;
  bool _profileExists = false;
  bool _paymentCompleted = false;
  List<Map<String, dynamic>> _availableTrainers = [];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadTrainersForGoal(String goal) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/trainers/$goal/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _availableTrainers = List<Map<String, dynamic>>.from(data['trainers']);
            // Reset trainer selection if goal changes
            if (_availableTrainers.isEmpty) {
              _selectedTrainerId = null;
            } else if (_selectedTrainerId != null) {
              // Check if selected trainer is still valid for new goal
              final isValid = _availableTrainers.any((t) => t['id'] == _selectedTrainerId);
              if (!isValid) {
                _selectedTrainerId = null;
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error loading trainers: $e');
    }
  }

  final List<Map<String, String>> _genders = [
    {'value': 'male', 'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _goals = [
    {'value': 'weight_gain', 'label': 'Weight Gain'},
    {'value': 'weight_loss', 'label': 'Weight Loss'},
    {'value': 'muscle_gain', 'label': 'Muscle Gain'},
    {'value': 'others', 'label': 'Others'},
  ];

  final List<Map<String, dynamic>> _targetMonths = [
    {'value': 1, 'label': '1 Month'},
    {'value': 2, 'label': '2 Months'},
    {'value': 3, 'label': '3 Months'},
    {'value': 6, 'label': '6 Months'},
    {'value': 8, 'label': '8 Months'},
    {'value': 12, 'label': '1 Year'},
  ];

  final List<Map<String, String>> _workoutTimes = [
    {'value': 'morning', 'label': '4 AM to 11 AM'},
    {'value': 'evening', 'label': '4 PM to 11 PM'},
  ];

  final List<Map<String, String>> _dietPreferences = [
    {'value': 'vegetarian', 'label': 'Vegetarian'},
    {'value': 'non_veg', 'label': 'Non-Vegetarian'},
    {'value': 'vegan', 'label': 'Vegan'},
    {'value': 'others', 'label': 'Others'},
  ];

  final List<Map<String, String>> _foodAllergies = [
    {'value': 'none', 'label': 'None'},
    {'value': 'seafood', 'label': 'Seafood'},
    {'value': 'nuts', 'label': 'Nuts'},
    {'value': 'dairy', 'label': 'Dairy'},
    {'value': 'others', 'label': 'Others'},
  ];

  final List<Map<String, String>> _healthConditions = [
    {'value': 'none', 'label': 'None'},
    {'value': 'asthma', 'label': 'Asthma'},
    {'value': 'hypertension', 'label': 'Hypertension'},
    {'value': 'diabetes', 'label': 'Diabetes'},
    {'value': 'others', 'label': 'Others'},
  ];

  Future<void> _loadExistingProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/profile/${widget.userId}/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['profile'] != null) {
          final profile = data['profile'];
          
          setState(() {
            _profileExists = true;
            _paymentCompleted = profile['payment_status'] == true;
            _mobileController.text = profile['mobile_number'] ?? '';
            _ageController.text = profile['age'].toString();
            _selectedGender = profile['gender'];
            _currentWeightController.text = profile['current_weight'].toString();
            _currentHeightController.text = profile['current_height'].toString();
            _selectedGoal = profile['goal'];
            _targetWeightController.text = profile['target_weight'].toString();
            _selectedTargetMonths = profile['target_months'];
            _selectedWorkoutTime = profile['workout_time'];
            _selectedDietPreference = profile['diet_preference'];
            _selectedFoodAllergies = profile['food_allergies'];
            _selectedHealthCondition = profile['health_conditions'];
          });
          
          // Load trainers if goal is already set
          if (_selectedGoal != null) {
            _loadTrainersForGoal(_selectedGoal!);
          }
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/profile/create/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'user_id': widget.userId,
            'mobile_number': _mobileController.text,
            'age': _ageController.text.isEmpty ? 0 : int.parse(_ageController.text),
            'gender': _selectedGender ?? '',
            'current_weight': _currentWeightController.text.isEmpty ? 0.0 : double.parse(_currentWeightController.text),
            'current_height': _currentHeightController.text.isEmpty ? 0.0 : double.parse(_currentHeightController.text),
            'goal': _selectedGoal ?? '',
            // For 'others' goal, target_weight = current_weight (maintenance)
            'target_weight': _selectedGoal == 'others' 
                ? (_currentWeightController.text.isEmpty ? 0.0 : double.parse(_currentWeightController.text))
                : (_targetWeightController.text.isEmpty ? 0.0 : double.parse(_targetWeightController.text)),
            'target_months': _selectedTargetMonths ?? 1,
            'workout_time': _selectedWorkoutTime ?? '',
            'diet_preference': _selectedDietPreference ?? '',
            'food_allergies': _selectedFoodAllergies ?? 'none',
            'health_conditions': _selectedHealthCondition ?? 'none',
            'trainer_id': _selectedTrainerId,
          }),
        );

        final data = json.decode(response.body);

        if (data['success']) {
          if (_paymentCompleted) {
            // If payment is already done, go back to home
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } else {
            // If payment not done, go to payment screen
            Navigator.pushReplacementNamed(
              context,
              '/payment',
              arguments: {
                'userId': widget.userId,
                'amount': data['profile']['payment_amount'],
                'months': _selectedTargetMonths,
                'userName': widget.userName,
              },
            );
          }
        } else {
          _showErrorDialog(data['message']);
        }
      } catch (e) {
        _showErrorDialog('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, ${widget.userName}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please fill in your details to get started with your fitness journey',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '10 digit mobile number',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your mobile number';
                  if (value.length != 10) return 'Mobile number must be exactly 10 digits';
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Please enter only numbers';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your age';
                  if (int.tryParse(value) == null || int.parse(value) < 10 || int.parse(value) > 100) {
                    return 'Please enter a valid age (10-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                value: _selectedGender,
                items: _genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender['value'],
                    child: Text(gender['label']!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _currentWeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Weight (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your current weight';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _currentHeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Height (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your current height';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Goal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                value: _selectedGoal,
                items: _goals.map((goal) {
                  return DropdownMenuItem<String>(
                    value: goal['value'],
                    child: Text(goal['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGoal = value;
                    if (value != null) {
                      _loadTrainersForGoal(value);
                    }
                  });
                },
                validator: (value) => value == null ? 'Please select your goal' : null,
              ),
              const SizedBox(height: 16),
              
              if (_availableTrainers.isNotEmpty) ...[
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Select Trainer (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_pin),
                    hintText: 'Choose your trainer',
                  ),
                  isExpanded: true,
                  value: _selectedTrainerId,
                  selectedItemBuilder: (context) {
                    return _availableTrainers.map((trainer) {
                      return Text(
                        trainer['name'],
                        overflow: TextOverflow.ellipsis,
                      );
                    }).toList();
                  },
                  items: _availableTrainers.map((trainer) {
                    return DropdownMenuItem<int>(
                      value: trainer['id'],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              trainer['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${trainer['experience']} years exp - ${trainer['specialization']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedTrainerId = value),
                ),
                const SizedBox(height: 16),
              ],
              
              // Only show target weight if goal is not 'others'
              if (_selectedGoal != 'others') ...[
                TextFormField(
                  controller: _targetWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Target Weight (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.track_changes),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your target weight';
                    if (double.tryParse(value) == null) return 'Please enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Target Duration',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                value: _selectedTargetMonths,
                items: _targetMonths.map((month) {
                  return DropdownMenuItem<int>(
                    value: month['value'],
                    child: Text(month['label']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTargetMonths = value),
                validator: (value) => value == null ? 'Please select target duration' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Preferred Workout Time',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                value: _selectedWorkoutTime,
                items: _workoutTimes.map((time) {
                  return DropdownMenuItem<String>(
                    value: time['value'],
                    child: Text(time['label']!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedWorkoutTime = value),
                validator: (value) => value == null ? 'Please select workout time' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Diet Preference',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                value: _selectedDietPreference,
                items: _dietPreferences.map((diet) {
                  return DropdownMenuItem<String>(
                    value: diet['value'],
                    child: Text(diet['label']!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedDietPreference = value),
                validator: (value) => value == null ? 'Please select diet preference' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Food Allergies',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
                value: _selectedFoodAllergies,
                items: _foodAllergies.map((allergy) {
                  return DropdownMenuItem<String>(
                    value: allergy['value'],
                    child: Text(allergy['label']!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedFoodAllergies = value),
                validator: (value) => value == null ? 'Please select food allergies option' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Health Conditions',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                value: _selectedHealthCondition,
                items: _healthConditions.map((condition) {
                  return DropdownMenuItem<String>(
                    value: condition['value'],
                    child: Text(condition['label']!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedHealthCondition = value),
                validator: (value) => value == null ? 'Please select health condition option' : null,
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _paymentCompleted ? 'Save Changes' : 'Continue to Payment',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _ageController.dispose();
    _currentWeightController.dispose();
    _currentHeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }
}
