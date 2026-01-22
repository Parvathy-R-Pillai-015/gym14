import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import WorkoutVideo

# Weight gain videos with day numbers and details
weight_gain_videos = [
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.00.50 PM.mp4',
        'title': 'Beginner Weight Gain - Foundation Training',
        'description': 'Start your weight gain journey with basic compound exercises focusing on proper form and technique.',
        'day_number': 1,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.00.52 PM.mp4',
        'title': 'Mass Building Basics',
        'description': 'Essential exercises for building muscle mass with focus on major muscle groups.',
        'day_number': 2,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.03.43 PM.mp4',
        'title': 'Upper Body Strength Builder',
        'description': 'Focused training for chest, shoulders, and arms to build upper body mass.',
        'day_number': 3,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.03.47 PM.mp4',
        'title': 'Lower Body Mass Training',
        'description': 'Leg and glute exercises designed to build lower body strength and size.',
        'day_number': 4,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.04.35 PM.mp4',
        'title': 'Full Body Compound Workout',
        'description': 'Complete workout targeting all major muscle groups with compound movements.',
        'day_number': 5,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.04.36 PM.mp4',
        'title': 'Progressive Overload Training',
        'description': 'Learn to progressively increase weight and intensity for continuous gains.',
        'day_number': 6,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.04.36 PM (1).mp4',
        'title': 'Strength and Size Development',
        'description': 'Advanced beginner workout combining strength and hypertrophy training.',
        'day_number': 7,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.04.36 PM (2).mp4',
        'title': 'Advanced Mass Building - High Intensity',
        'description': 'Intense training session for experienced lifters focused on maximum muscle growth.',
        'day_number': 8,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.04.36 PM (3).mp4',
        'title': 'Power Training for Muscle Gain',
        'description': 'Advanced power movements and heavy compound lifts for serious mass gains.',
        'day_number': 9,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 12.04.37 PM.mp4',
        'title': 'Ultimate Bulking Workout',
        'description': 'Complete advanced routine for maximum muscle hypertrophy and weight gain.',
        'day_number': 10,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
]

print("Starting bulk upload of weight gain videos...")
print(f"Total videos to upload: {len(weight_gain_videos)}\n")

uploaded_count = 0
skipped_count = 0

for video_data in weight_gain_videos:
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
            goal_type='weight_gain',
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
print(f"\nWeight Gain Videos Structure:")
print(f"  Days 1-7: Beginner (0-10kg difference)")
print(f"  Days 8-10: Advanced (11-30kg difference)")
print(f"\nAll videos marked as 'bulk' - managed only by admin")
