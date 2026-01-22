import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import WorkoutVideo

# Update all bulk-uploaded videos to have no specific trainer
bulk_videos = WorkoutVideo.objects.filter(uploaded_via='bulk')

print(f"Found {bulk_videos.count()} bulk-uploaded videos")
print("\nUpdating videos to remove trainer assignment:")

for video in bulk_videos:
    print(f"Video {video.id}: {video.title}")
    print(f"  - Currently assigned to: {video.uploaded_by}")
    video.uploaded_by = None
    video.save()
    print(f"  - Updated: No trainer assigned (bulk/admin video)")

print(f"\n✅ Successfully updated {bulk_videos.count()} videos")
print("Bulk videos are now managed only by admin, not tied to any specific trainer")
