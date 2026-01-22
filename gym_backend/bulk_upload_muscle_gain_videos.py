import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import WorkoutVideo

# Muscle gain videos with day numbers and details
muscle_gain_videos = [
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.41.18 PM.mp4',
        'title': 'Beginner Muscle Building - Foundation',
        'description': 'Start building lean muscle with basic resistance training and proper form techniques.',
        'day_number': 1,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.41.30 PM.mp4',
        'title': 'Hypertrophy Training Basics',
        'description': 'Essential muscle-building exercises focusing on time under tension and progressive overload.',
        'day_number': 2,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.41.58 PM.mp4',
        'title': 'Upper Body Muscle Development',
        'description': 'Targeted workouts for chest, back, shoulders, and arms to build upper body muscle mass.',
        'day_number': 3,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.42.05 PM.mp4',
        'title': 'Lower Body Strength & Muscle',
        'description': 'Leg training focused on quad, hamstring, and glute development for balanced muscle growth.',
        'day_number': 4,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.42.12 PM.mp4',
        'title': 'Core and Stability Training',
        'description': 'Build a strong core foundation essential for all muscle-building movements.',
        'day_number': 5,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.42.21 PM.mp4',
        'title': 'Push-Pull Muscle Builder',
        'description': 'Balanced push and pull exercises for symmetrical muscle development.',
        'day_number': 6,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.42.28 PM.mp4',
        'title': 'Full Body Muscle Activation',
        'description': 'Complete workout targeting all major muscle groups for maximum growth stimulus.',
        'day_number': 7,
        'difficulty': 'beginner',
        'min_weight': 0,
        'max_weight': 10
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.42.38 PM.mp4',
        'title': 'Advanced Hypertrophy Training',
        'description': 'High-intensity muscle-building workout with advanced techniques for serious gains.',
        'day_number': 8,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.43.48 PM.mp4',
        'title': 'Power & Muscle Building Complex',
        'description': 'Advanced power movements combined with hypertrophy training for maximum muscle mass.',
        'day_number': 9,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
    {
        'filename': 'WhatsApp Video 2026-01-22 at 2.43.54 PM.mp4',
        'title': 'Elite Muscle Building Program',
        'description': 'Complete advanced routine designed for experienced lifters seeking peak muscle development.',
        'day_number': 10,
        'difficulty': 'advanced',
        'min_weight': 11,
        'max_weight': 30
    },
]

print("Starting bulk upload of muscle gain videos...")
print(f"Total videos to upload: {len(muscle_gain_videos)}\n")

uploaded_count = 0
skipped_count = 0

for video_data in muscle_gain_videos:
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
            goal_type='muscle_gain',
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
print(f"\nMuscle Gain Videos Structure:")
print(f"  Days 1-7: Beginner (0-10kg difference)")
print(f"  Days 8-10: Advanced (11-30kg difference)")
print(f"\nAll videos marked as 'bulk' - managed only by admin")
