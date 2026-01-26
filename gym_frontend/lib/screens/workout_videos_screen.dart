import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class WorkoutVideosScreen extends StatefulWidget {
  final int userId;
  
  const WorkoutVideosScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _WorkoutVideosScreenState createState() => _WorkoutVideosScreenState();
}

class _WorkoutVideosScreenState extends State<WorkoutVideosScreen> {
  List<dynamic> _videos = [];
  bool _isLoading = true;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/videos/user/${widget.userId}/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _videos = data['videos'];
            _userInfo = data['user_info'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildUnlockStatusCard() {
    if (_userInfo == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Video Access Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Goal', _userInfo!['goal']),
            _buildInfoRow('Weight Difference', '${_userInfo!['weight_difference']}kg'),
            if (_userInfo!['days_enrolled'] != null)
              _buildInfoRow('Days Enrolled', 'Day ${_userInfo!['days_enrolled']}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.video_library,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _userInfo!['unlock_status'],
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerPicksSection() {
    final picks = _videos
        .where((video) => video['day_number'] == null)
        .toList();

    if (picks.isEmpty) return const SizedBox.shrink();

    picks.sort((a, b) {
      final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    final topPicks = picks.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.deepPurple),
              const SizedBox(width: 8),
              const Text(
                'Trainer Picks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Text(
                  '${picks.length} uploads',
                  style: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topPicks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pick = topPicks[index];

                return SizedBox(
                  width: 240,
                  child: GestureDetector(
                    onTap: () => _playVideo(pick),
                    child: Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: pick['thumbnail_url'] != null
                                    ? Image.network(
                                        'http://127.0.0.1:8000${pick['thumbnail_url']}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildPlaceholder();
                                        },
                                      )
                                    : _buildPlaceholder(),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Trainer Upload',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              if (pick['duration'] != null)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(pick['duration'] / 60).toStringAsFixed(0)} min',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pick['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _buildChip(
                                      Icons.flag,
                                      pick['difficulty_level'],
                                      pick['difficulty_level'] == 'beginner' ? Colors.green : Colors.orange,
                                    ),
                                    _buildChip(
                                      Icons.fitness_center,
                                      pick['weight_range'],
                                      Colors.blue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final isRecommended = video['is_recommended'] ?? false;
    final recommendation = video['recommendation'];
    final isLocked = video['is_unlocked'] == false;
    final dayNumber = video['day_number'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail or placeholder with lock overlay
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: video['thumbnail_url'] != null
                      ? Image.network(
                          'http://127.0.0.1:8000${video['thumbnail_url']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
                if (isLocked)
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unlocks on Day ${video['unlock_day']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (dayNumber != null && !isLocked)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Day $dayNumber',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with recommended badge
                  Row(
                  children: [
                    Expanded(
                      child: Text(
                        video['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isRecommended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Recommended',
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  video['description'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                // Video info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(
                      Icons.flag,
                      video['difficulty_level'],
                      video['difficulty_level'] == 'beginner'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    _buildChip(
                      Icons.fitness_center,
                      video['weight_range'],
                      Colors.blue,
                    ),
                    if (video['duration'] != null)
                      _buildChip(
                        Icons.access_time,
                        '${(video['duration'] / 60).toStringAsFixed(0)} min',
                        Colors.purple,
                      ),
                  ],
                ),
                // Trainer recommendation note
                if (isRecommended && recommendation != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trainer\'s Note:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        if (recommendation['note'] != null &&
                            recommendation['note'].isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            recommendation['note'],
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'by ${recommendation['recommended_by']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Watch button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLocked ? null : () {
                      _playVideo(video);
                    },
                    icon: Icon(isLocked ? Icons.lock : Icons.play_circle_filled),
                    label: Text(isLocked ? 'Locked' : 'Watch Video'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isLocked ? Colors.grey : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Workout Video',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVideos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadVideos,
              child: _videos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No videos available yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your trainer will upload videos soon',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        _buildUnlockStatusCard(),
                        _buildTrainerPicksSection(),
                        ..._videos
                            .where((video) => video['day_number'] != null)
                            .map((video) => _buildVideoCard(video)),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
    );
  }

  void _playVideo(Map<String, dynamic> video) {
    final videoUrl = 'http://127.0.0.1:8000${video['video_url']}';
    
    // Open video in new tab for Flutter web
    html.window.open(videoUrl, '_blank');
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${video['title']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
