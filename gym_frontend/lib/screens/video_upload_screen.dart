import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class VideoUploadScreen extends StatefulWidget {
  final int trainerId;
  final String trainerName;
  final String trainerGoalCategory;

  const VideoUploadScreen({
    Key? key,
    required this.trainerId,
    required this.trainerName,
    required this.trainerGoalCategory,
  }) : super(key: key);

  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedGoalType;
  String? _selectedDifficulty;
  Uint8List? _videoBytes;
  String? _videoFileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _trainerGoalType;
  bool _isLoadingGoal = true;

  final List<Map<String, String>> _goalTypes = [
    {'value': 'weight_gain', 'label': 'Weight Gain'},
    {'value': 'weight_loss', 'label': 'Weight Loss'},
    {'value': 'muscle_gain', 'label': 'Muscle Gain'},
    {'value': 'muscle_building', 'label': 'Muscle Building'},
    {'value': 'others', 'label': 'General Fitness'},
  ];

  final List<Map<String, String>> _difficultyLevels = [
    {'value': 'beginner', 'label': 'Beginner (0-10kg difference)'},
    {'value': 'advanced', 'label': 'Advanced (11-30kg difference)'},
  ];

  @override
  void initState() {
    super.initState();
    // Set goal type from trainer's assigned category
    setState(() {
      _selectedGoalType = widget.trainerGoalCategory;
      _trainerGoalType = widget.trainerGoalCategory;
      _isLoadingGoal = false;
    });
  }

  Future<void> _fetchTrainerGoalType() async {
    print('Fetching trainer goal for ID: ${widget.trainerId}');
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/trainers/${widget.trainerId}/'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data');
        setState(() {
          _trainerGoalType = data['goal_category'] ?? 'weight_loss';
          _selectedGoalType = _trainerGoalType;
          _isLoadingGoal = false;
        });
        print('Goal type set to: $_selectedGoalType');
      } else {
        print('API returned non-200 status');
        // Fallback to default
        setState(() {
          _selectedGoalType = 'weight_loss';
          _trainerGoalType = 'weight_loss';
          _isLoadingGoal = false;
        });
      }
    } catch (e) {
      print('Error fetching trainer goal: $e');
      setState(() {
        _selectedGoalType = 'weight_loss';
        _trainerGoalType = 'weight_loss';
        _isLoadingGoal = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'avi', 'mov', 'mkv', 'wmv'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _videoBytes = result.files.single.bytes;
          _videoFileName = result.files.single.name;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video selected: $_videoFileName (${(_videoBytes!.length / (1024 * 1024)).toStringAsFixed(2)} MB)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_videoBytes == null || _videoFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video file')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/videos/upload/'),
      );

      // Add form fields
      request.fields['trainer_id'] = widget.trainerId.toString();
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['goal_type'] = _selectedGoalType!;
      request.fields['difficulty_level'] = _selectedDifficulty!;

      // Add video file from bytes
      var videoFile = http.MultipartFile.fromBytes(
        'video_file',
        _videoBytes!,
        filename: _videoFileName!,
      );
      request.files.add(videoFile);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedGoalType = null;
            _selectedDifficulty = null;
            _videoBytes = null;
            _videoFileName = null;
          });
        }
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Workout Video'),
        backgroundColor: const Color(0xFF1F2933),
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Uploading video...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This may take a few minutes',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Card(
                      color: const Color(0xFF0F766E).withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF0F766E)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Upload workout videos for your assigned goal: ${widget.trainerName}',
                                style: const TextStyle(color: Color(0xFF0F766E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Video file picker
                    Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: _pickVideo,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                _videoBytes == null
                                    ? Icons.video_library_outlined
                                    : Icons.video_library,
                                size: 64,
                                color: _videoBytes == null
                                    ? Colors.grey.shade400
                                    : Colors.green,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _videoBytes == null
                                    ? 'Tap to select video'
                                    : _videoFileName ?? 'Video selected',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _videoBytes == null
                                      ? Colors.grey.shade600
                                      : Colors.green,
                                ),
                              ),
                              if (_videoBytes != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to change video',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Video Title',
                        hintText: 'e.g., Weight Gain Basics - Beginner',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter video title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the workout routine...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Goal Type (Auto-filled from trainer's specialization)
                    TextFormField(
                      initialValue: _selectedGoalType != null 
                          ? _goalTypes.firstWhere((g) => g['value'] == _selectedGoalType)['label']
                          : 'Loading...',
                      decoration: InputDecoration(
                        labelText: 'Goal Type (Auto-assigned)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.flag),
                        enabled: false,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        helperText: 'Based on your trainer specialization',
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    // Difficulty Level
                    DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty Level',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                      items: _difficultyLevels.map((level) {
                        return DropdownMenuItem(
                          value: level['value'],
                          child: Text(level['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select difficulty level';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _uploadVideo,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text(
                          'Upload Video',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                        ),
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
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
