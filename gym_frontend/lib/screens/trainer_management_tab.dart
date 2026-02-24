import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrainerManagementTab extends StatefulWidget {
  const TrainerManagementTab({Key? key}) : super(key: key);

  @override
  State<TrainerManagementTab> createState() => _TrainerManagementTabState();
}

class _TrainerManagementTabState extends State<TrainerManagementTab> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _allTrainers = [];
  
  final List<Map<String, String>> _goalCategories = [
    {'value': 'weight_gain', 'label': 'Weight Gain'},
    {'value': 'weight_loss', 'label': 'Weight Loss'},
    {'value': 'muscle_gain', 'label': 'Muscle Gain'},
    {'value': 'others', 'label': 'Others'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllTrainers();
  }

  Future<void> _loadAllTrainers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/trainers/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _allTrainers = List<Map<String, dynamic>>.from(data['trainers']);
          });
        }
      }
    } catch (e) {
      print('Error loading trainers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _assignTrainerToGoal(int trainerId, String goalCategory) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/admin/trainers/assign/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'trainer_id': trainerId,
          'goal_category': goalCategory,
        }),
      );

      final data = json.decode(response.body);

      if (mounted) {
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.green,
            ),
          );
          _loadAllTrainers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeTrainerFromGoal(int trainerId) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/admin/trainers/remove/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'trainer_id': trainerId,
        }),
      );

      final data = json.decode(response.body);

      if (mounted) {
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trainer removed from category'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAllTrainers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddTrainerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    final experienceController = TextEditingController();
    String? selectedGender;
    String? selectedSpecialization;
    String? selectedCertification;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Trainer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mobileController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile (10 digits) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Experience (years) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSpecialization,
                      decoration: const InputDecoration(
                        labelText: 'Specialization *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Weight Loss', child: Text('Weight Loss')),
                        DropdownMenuItem(value: 'Weight Gain', child: Text('Weight Gain')),
                        DropdownMenuItem(value: 'Muscle Gain', child: Text('Muscle Gain')),
                        DropdownMenuItem(value: 'Cardio Training', child: Text('Cardio Training')),
                        DropdownMenuItem(value: 'Strength Training', child: Text('Strength Training')),
                        DropdownMenuItem(value: 'Yoga', child: Text('Yoga')),
                        DropdownMenuItem(value: 'CrossFit', child: Text('CrossFit')),
                        DropdownMenuItem(value: 'Sports Nutrition', child: Text('Sports Nutrition')),
                        DropdownMenuItem(value: 'Rehabilitation', child: Text('Rehabilitation')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedSpecialization = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCertification,
                      decoration: const InputDecoration(
                        labelText: 'Certification (optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'NASM Certified Personal Trainer', child: Text('NASM Certified Personal Trainer')),
                        DropdownMenuItem(value: 'ACE Personal Trainer', child: Text('ACE Personal Trainer')),
                        DropdownMenuItem(value: 'ISSA Certified Fitness Trainer', child: Text('ISSA Certified Fitness Trainer')),
                        DropdownMenuItem(value: 'ACSM Certified Personal Trainer', child: Text('ACSM Certified Personal Trainer')),
                        DropdownMenuItem(value: 'CrossFit Level 1 Trainer', child: Text('CrossFit Level 1 Trainer')),
                        DropdownMenuItem(value: 'Yoga Alliance Certified', child: Text('Yoga Alliance Certified')),
                        DropdownMenuItem(value: 'Precision Nutrition Certified', child: Text('Precision Nutrition Certified')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCertification = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Password will be auto-generated as: trainername+tr',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        mobileController.text.isEmpty ||
                        selectedGender == null ||
                        experienceController.text.isEmpty ||
                        selectedSpecialization == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await _createTrainer(
                      nameController.text,
                      emailController.text,
                      mobileController.text,
                      selectedGender!,
                      int.parse(experienceController.text),
                      selectedSpecialization!,
                      selectedCertification ?? '',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Trainer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createTrainer(
    String name,
    String email,
    String mobile,
    String gender,
    int experience,
    String specialization,
    String certification,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/admin/trainers/create/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'emailid': email,
          'mobile': mobile,
          'gender': gender,
          'experience': experience,
          'specialization': specialization,
          'certification': certification,
        }),
      );

      final data = json.decode(response.body);

      if (mounted) {
        if (data['success']) {
          // Show success dialog with password
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Trainer Created Successfully!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${data['trainer']['name']}'),
                  Text('Email: ${data['trainer']['email']}'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF14B8A6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login Credentials:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Password: ${data['trainer']['password']}'),
                        const SizedBox(height: 8),
                        const Text(
                          'Please share these credentials with the trainer',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadAllTrainers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAssignDialog(int trainerId, String trainerName, String? currentGoal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign $trainerName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _goalCategories.map((goal) {
              return ListTile(
                title: Text(goal['label']!),
                trailing: currentGoal == goal['value']
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _assignTrainerToGoal(trainerId, goal['value']!);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group trainers by goal category
    Map<String, List<Map<String, dynamic>>> trainersByGoal = {
      'weight_gain': [],
      'weight_loss': [],
      'muscle_gain': [],
      'others': [],
      'unassigned': [],
    };

    for (var trainer in _allTrainers) {
      String category = trainer['goal_category'] ?? 'unassigned';
      if (!trainersByGoal.containsKey(category)) {
        category = 'unassigned';
      }
      trainersByGoal[category]!.add(trainer);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add Trainer Button
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: _showAddTrainerDialog,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Add New Trainer', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Summary Card
        Card(
          color: const Color(0xFF0F766E).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trainer Assignment Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Total Trainers: ${_allTrainers.length}'),
                Text('Weight Gain: ${trainersByGoal['weight_gain']!.length}/2'),
                Text('Weight Loss: ${trainersByGoal['weight_loss']!.length}/2'),
                Text('Muscle Gain: ${trainersByGoal['muscle_gain']!.length}/2'),
                Text('Others: ${trainersByGoal['others']!.length}/2'),
                Text('Unassigned: ${trainersByGoal['unassigned']!.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Goal Categories
        ..._goalCategories.map((goalCat) {
          final trainers = trainersByGoal[goalCat['value']]!;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: Icon(
                Icons.fitness_center,
                color: trainers.length >= 5 ? Colors.green : Colors.orange,
              ),
              title: Text(
                goalCat['label']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${trainers.length}/5 Trainers Assigned'),
              children: [
                if (trainers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No trainers assigned to this category'),
                  )
                else
                  ...trainers.map((trainer) => _buildTrainerTile(trainer, goalCat['value']!)),
              ],
            ),
          );
        }).toList(),

        // Unassigned Trainers
        Card(
          child: ExpansionTile(
            leading: const Icon(Icons.person_off, color: Colors.grey),
            title: const Text(
              'Unassigned Trainers',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${trainersByGoal['unassigned']!.length} Trainers'),
            children: [
              if (trainersByGoal['unassigned']!.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('All trainers are assigned'),
                )
              else
                ...trainersByGoal['unassigned']!.map((trainer) => _buildTrainerTile(trainer, null)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerTile(Map<String, dynamic> trainer, String? goalCategory) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: trainer['is_active'] ? Colors.green : Colors.grey,
          child: Text(
            trainer['name'][0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          trainer['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${trainer['experience']} years - ${trainer['specialization']}'),
            if (trainer['assigned_users_count'] > 0)
              Text(
                '${trainer['assigned_users_count']} users assigned',
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (goalCategory != null)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeTrainerFromGoal(trainer['id']),
                tooltip: 'Remove from category',
              ),
            IconButton(
              icon: Icon(
                goalCategory != null ? Icons.swap_horiz : Icons.add_circle,
                color: Colors.blue,
              ),
              onPressed: () => _showAssignDialog(
                trainer['id'],
                trainer['name'],
                trainer['goal_category'],
              ),
              tooltip: goalCategory != null ? 'Reassign' : 'Assign to category',
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrainerDetailRow('Email', trainer['email']),
                _buildTrainerDetailRow('Mobile', trainer['mobile']),
                _buildTrainerDetailRow('Gender', trainer['gender'].toString().toUpperCase()),
                _buildTrainerDetailRow('Experience', '${trainer['experience']} years'),
                _buildTrainerDetailRow('Specialization', trainer['specialization']),
                _buildTrainerDetailRow('Certification', trainer['certification'] ?? 'Not Specified'),
                if (trainer['goal_category'] != null)
                  _buildTrainerDetailRow(
                    'Assigned Category',
                    trainer['goal_category'].toString().replaceAll('_', ' ').toUpperCase(),
                  ),
                _buildTrainerDetailRow('Status', trainer['is_active'] ? 'Active' : 'Inactive'),
                _buildTrainerDetailRow('Users Assigned', trainer['assigned_users_count'].toString()),
                _buildTrainerDetailRow('Joined On', trainer['created_at']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerDetailRow(String label, String value) {
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
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
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
}
