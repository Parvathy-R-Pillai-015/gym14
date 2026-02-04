import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import UserLogin, UserDietPlan, DietPlanTemplate

TARGET_USERS = ['manu@gmail.com', 'smitha@gmail.com']


def update_user_plan(email):
    user = UserLogin.objects.filter(emailid=email).first()
    if not user:
        print(f"✗ User not found: {email}")
        return

    plan = UserDietPlan.objects.filter(user=user, is_active=True).order_by('-created_at').first()
    if not plan:
        print(f"✗ No active plan for: {email}")
        return

    # Find matching 7-day template based on plan name
    if 'Vegan' in plan.plan_name:
        template_name = 'Muscle Gain - Vegan Very High (2500-3000) - 7 Day'
    elif 'Vegetarian' in plan.plan_name:
        template_name = 'Muscle Gain - Vegetarian Very High (2500-3000) - 7 Day'
    else:
        template_name = 'Muscle Gain - Non-Veg Very High (2500-3000) - 7 Day'

    template = DietPlanTemplate.objects.filter(name=template_name).first()
    if not template:
        print(f"✗ Template not found: {template_name}")
        return

    plan.template = template
    plan.meals_data = template.meals_data
    plan.plan_name = template.name
    plan.save()

    print(f"✓ Updated plan for {email} -> {template.name}")


for email in TARGET_USERS:
    update_user_plan(email)

print("\nDone.")
