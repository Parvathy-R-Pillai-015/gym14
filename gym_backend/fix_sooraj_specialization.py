import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import Trainer, UserLogin

# Find sooraj trainer
sooraj_user = UserLogin.objects.get(emailid='sooraj@gmail.com')
sooraj = Trainer.objects.get(user=sooraj_user)

print(f"Trainer: {sooraj.user.name} ({sooraj.user.emailid})")
print(f"Current specialization: {sooraj.specialization}")
print(f"Current goal_category: {sooraj.goal_category}")

# Update to weight_gain
sooraj.specialization = 'Weight Gain'
sooraj.goal_category = 'weight_gain'
sooraj.save()

print(f"\n✅ Updated to:")
print(f"New specialization: {sooraj.specialization}")
print(f"New goal_category: {sooraj.goal_category}")
