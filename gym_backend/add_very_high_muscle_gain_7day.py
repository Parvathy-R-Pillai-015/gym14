import os
import django
import json

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import DietPlanTemplate


def build_7day_plan(day_plan):
    return {
        'monday': day_plan,
        'tuesday': day_plan,
        'wednesday': day_plan,
        'thursday': day_plan,
        'friday': day_plan,
        'saturday': day_plan,
        'sunday': day_plan,
    }


vegan_day = {
    'breakfast': {
        'items': ['Oats (100g)', 'Almond Butter (2 tbsp)', 'Banana', 'Protein Powder (30g)'],
        'calories': 550,
    },
    'snack1': {
        'items': ['Peanut Butter (2 tbsp)', 'Whole Wheat Bread (2 slices)', 'Apple'],
        'calories': 400,
    },
    'lunch': {
        'items': ['Chickpea Curry (200g)', 'Brown Rice (150g)', 'Salad'],
        'calories': 650,
    },
    'snack2': {
        'items': ['Protein Smoothie with Oat Milk', 'Nuts Mix (50g)'],
        'calories': 400,
    },
    'dinner': {
        'items': ['Lentil Pasta (200g)', 'Tofu Stir-fry (150g)', 'Vegetables'],
        'calories': 600,
    },
}

vegetarian_day = {
    'breakfast': {
        'items': ['Paneer Paratha (2)', 'Greek Yogurt (150g)', 'Honey (1 tbsp)'],
        'calories': 550,
    },
    'snack1': {
        'items': ['Cheese Sandwich (2 slices)', 'Almonds (30g)', 'Orange'],
        'calories': 400,
    },
    'lunch': {
        'items': ['Dal Makhani (200ml)', 'Basmati Rice (150g)', 'Cucumber Salad'],
        'calories': 650,
    },
    'snack2': {
        'items': ['Protein Shake with Milk', 'Granola Bar'],
        'calories': 400,
    },
    'dinner': {
        'items': ['Paneer Tikka Masala (200g)', 'Roti (2)', 'Mixed Vegetables'],
        'calories': 600,
    },
}

nonveg_day = {
    'breakfast': {
        'items': ['Egg Whites (4)', 'Whole Wheat Toast (2)', 'Butter (1 tbsp)', 'Orange Juice'],
        'calories': 550,
    },
    'snack1': {
        'items': ['Chicken Sandwich (1)', 'Almonds (30g)', 'Apple'],
        'calories': 400,
    },
    'lunch': {
        'items': ['Grilled Chicken (200g)', 'Basmati Rice (150g)', 'Broccoli'],
        'calories': 650,
    },
    'snack2': {
        'items': ['Protein Shake with Milk', 'Granola Bar'],
        'calories': 400,
    },
    'dinner': {
        'items': ['Fish Fillet (200g)', 'Sweet Potato (150g)', 'Salad with Olive Oil'],
        'calories': 600,
    },
}


templates_to_create = [
    {
        'name': 'Muscle Gain - Vegan Very High (2500-3000) - 7 Day',
        'goal_type': 'muscle_gain',
        'calorie_min': 2500,
        'calorie_max': 3000,
        'description': '7-day vegan muscle gain plan (2500-3000 calories)',
        'meals_data': json.dumps(build_7day_plan(vegan_day)),
    },
    {
        'name': 'Muscle Gain - Vegetarian Very High (2500-3000) - 7 Day',
        'goal_type': 'muscle_gain',
        'calorie_min': 2500,
        'calorie_max': 3000,
        'description': '7-day vegetarian muscle gain plan (2500-3000 calories)',
        'meals_data': json.dumps(build_7day_plan(vegetarian_day)),
    },
    {
        'name': 'Muscle Gain - Non-Veg Very High (2500-3000) - 7 Day',
        'goal_type': 'muscle_gain',
        'calorie_min': 2500,
        'calorie_max': 3000,
        'description': '7-day non-veg muscle gain plan (2500-3000 calories)',
        'meals_data': json.dumps(build_7day_plan(nonveg_day)),
    },
]

for template_data in templates_to_create:
    existing = DietPlanTemplate.objects.filter(
        name=template_data['name'],
        goal_type=template_data['goal_type']
    ).first()

    if not existing:
        template = DietPlanTemplate.objects.create(**template_data)
        print(f"✓ Created: {template.name}")
    else:
        print(f"✗ Already exists: {template_data['name']}")

print("\n7-day very high templates created successfully!")
