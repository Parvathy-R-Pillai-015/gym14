import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import UserLogin, UserProfile, DietPlanTemplate

# Get Smitha's data
user = UserLogin.objects.get(emailid='smitha@gmail.com')
profile = UserProfile.objects.get(user=user)

print(f"User: {user.name}")
print(f"Goal: {profile.goal}")
print(f"Current Weight: {profile.current_weight}")
print(f"Target Weight: {profile.target_weight}")
print(f"Target Months: {profile.target_months}")

# Calculate target calories
result = profile.calculate_target_calories()
target_cal = result['target_calories']
print(f"\nTarget Calories: {target_cal}")

# Check templates for muscle_gain
print(f"\nTemplates for muscle_gain goal:")
templates = DietPlanTemplate.objects.filter(goal_type='muscle_gain')
print(f"Total templates: {templates.count()}")

for t in templates:
    print(f"  - {t.name}: {t.calorie_min}-{t.calorie_max}")

# Check if any templates match the target calories
matching = templates.filter(calorie_min__lte=target_cal, calorie_max__gte=target_cal)
print(f"\nMatching templates for {target_cal} calories: {matching.count()}")
for t in matching:
    print(f"  - {t.name}: {t.calorie_min}-{t.calorie_max}")
