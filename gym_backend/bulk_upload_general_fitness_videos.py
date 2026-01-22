import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import WorkoutVideo

# General Fitness videos with day numbers and details
general_fitness_videos = [
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.16.48 PM.mp4',
        'title': 'Beginner General Fitness - Getting Started',
        'description': 'Introduction to overall fitness with basic exercises for strength, flexibility, and endurance.',
        'day_number': 1,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.16.53 PM.mp4',
        'title': 'Cardio and Strength Basics',
        'description': 'Balanced workout combining cardiovascular exercises with basic strength training.',
        'day_number': 2,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.17.03 PM.mp4',
        'title': 'Flexibility and Mobility Training',
        'description': 'Essential stretching and mobility exercises for improved range of motion and injury prevention.',
        'day_number': 3,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.17.12 PM.mp4',
        'title': 'Full Body Functional Fitness',
        'description': 'Practical exercises that improve everyday movement and overall body function.',
        'day_number': 4,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.17.20 PM.mp4',
        'title': 'Endurance Building Workout',
        'description': 'Improve cardiovascular endurance and stamina with sustained exercise routines.',
        'day_number': 5,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.17.30 PM.mp4',
        'title': 'Balance and Coordination Training',
        'description': 'Exercises to enhance body control, balance, and coordination for better fitness.',
        'day_number': 6,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.17.45 PM.mp4',
        'title': 'General Conditioning Workout',
        'description': 'Complete conditioning routine for overall fitness improvement and body toning.',
        'day_number': 7,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.18.02 PM.mp4',
        'title': 'Advanced Athletic Conditioning',
        'description': 'High-intensity training for experienced fitness enthusiasts seeking athletic performance.',
        'day_number': 8,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.18.18 PM.mp4',
        'title': 'Advanced Functional Fitness',
        'description': 'Complex movement patterns and advanced exercises for peak functional fitness.',
        'day_number': 9,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 3.18.24 PM.mp4',
        'title': 'Elite General Fitness Program',
        'description': 'Complete advanced workout combining strength, cardio, flexibility, and endurance for optimal fitness.',
        'day_number': 10,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
]

print("Starting bulk upload of general fitness videos...")
print(f"Total videos to upload: {len(general_fitness_videos)}\n")

uploaded_count = 0
skipped_count = 0

for video_data in general_fitness_videos:
    filename = video_data['filename']
    video_path = f'workout_videos/{filename}'
    
    # Check if video already exists
    if WorkoutVideo.objects.filter(video_file=video_path).exists():
        print(f"⚠️  SKIPPED: {video_data['title']} (already exists)")
        skipped_count += 1
        continue
    
    try:
        # Create video record
        video = WorkoutVideo.objects.create(
            title=video_data['title'],
            description=video_data['description'],
            video_file=video_path,
            goal_type='others',
            difficulty_level=video_data['difficulty'],
            min_weight_difference=video_data['min_weight'],
            max_weight_difference=video_data['max_weight'],
            day_number=video_data['day_number'],
            uploaded_via='bulk',
            uploaded_by=None,  # No trainer assigned - admin managed
            is_active=True
        )
        
        print(f"✅ Day {video_data['day_number']}: {video_data['title']} ({video_data['difficulty']})")
        uploaded_count += 1
        
    except Exception as e:
        print(f"❌ ERROR uploading {video_data['title']}: {str(e)}")

print(f"\n{'='*60}")
print(f"Upload complete!")
print(f"✅ Successfully uploaded: {uploaded_count} videos")
print(f"⚠️  Skipped (already exist): {skipped_count} videos")
print(f"{'='*60}")
print(f"\nGeneral Fitness Videos Structure:")
print(f"  Days 1-7: Beginner (0-10kg difference)")
print(f"  Days 8-10: Advanced (11-30kg difference)")
print(f"\nAll videos marked as 'bulk' - managed only by admin")
