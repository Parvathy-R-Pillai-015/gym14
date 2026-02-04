import os
import django
import json

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_backend.settings')
django.setup()

from users.models import DietPlanTemplate


def build_7day_plan(days):
    keys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    return {k: days[i] for i, k in enumerate(keys)}


# Vegan 7-day varied
vegan_days = [
    {
        'breakfast': {'items': ['Oats (100g)', 'Almond Butter (2 tbsp)', 'Banana', 'Protein Powder (30g)'], 'calories': 550},
        'snack1': {'items': ['Peanut Butter (2 tbsp)', 'Whole Wheat Bread (2 slices)', 'Apple'], 'calories': 400},
        'lunch': {'items': ['Chickpea Curry (200g)', 'Brown Rice (150g)', 'Salad'], 'calories': 650},
        'snack2': {'items': ['Protein Smoothie (Oat Milk)', 'Nuts Mix (50g)'], 'calories': 400},
        'dinner': {'items': ['Lentil Pasta (200g)', 'Tofu Stir-fry (150g)', 'Vegetables'], 'calories': 600},
    },
    {
        'breakfast': {'items': ['Granola (100g)', 'Soy Milk (250ml)', 'Mixed Berries'], 'calories': 520},
        'snack1': {'items': ['Hummus (3 tbsp)', 'Pita Bread (2)', 'Carrot Sticks'], 'calories': 420},
        'lunch': {'items': ['Quinoa Bowl (200g)', 'Black Beans (150g)', 'Avocado'], 'calories': 670},
        'snack2': {'items': ['Vegan Protein Bar', 'Walnuts (30g)'], 'calories': 390},
        'dinner': {'items': ['Tofu Curry (200g)', 'Jasmine Rice (150g)', 'Spinach'], 'calories': 600},
    },
    {
        'breakfast': {'items': ['Peanut Butter Smoothie', 'Oats (60g)', 'Banana'], 'calories': 540},
        'snack1': {'items': ['Trail Mix (60g)', 'Apple'], 'calories': 430},
        'lunch': {'items': ['Lentil Dal (250ml)', 'Basmati Rice (150g)', 'Cucumber Salad'], 'calories': 660},
        'snack2': {'items': ['Soy Yogurt (200g)', 'Granola (40g)'], 'calories': 380},
        'dinner': {'items': ['Veggie Burrito (2)', 'Guacamole (2 tbsp)'], 'calories': 600},
    },
    {
        'breakfast': {'items': ['Chia Pudding (250ml)', 'Almonds (30g)', 'Mango'], 'calories': 520},
        'snack1': {'items': ['Vegan Sandwich (2)', 'Orange'], 'calories': 420},
        'lunch': {'items': ['Kidney Bean Curry (200g)', 'Brown Rice (150g)', 'Salad'], 'calories': 670},
        'snack2': {'items': ['Peanut Butter Toast (2)', 'Banana'], 'calories': 400},
        'dinner': {'items': ['Tofu Noodles (200g)', 'Stir-fry Veg (150g)'], 'calories': 600},
    },
    {
        'breakfast': {'items': ['Oats (80g)', 'Dates (4)', 'Soy Milk (250ml)'], 'calories': 520},
        'snack1': {'items': ['Roasted Chickpeas (60g)', 'Apple'], 'calories': 420},
        'lunch': {'items': ['Quinoa (150g)', 'Chickpea Salad (200g)'], 'calories': 650},
        'snack2': {'items': ['Protein Shake (Oat Milk)', 'Almonds (30g)'], 'calories': 400},
        'dinner': {'items': ['Veggie Pasta (200g)', 'Tofu (150g)'], 'calories': 610},
    },
    {
        'breakfast': {'items': ['Vegan Pancakes (3)', 'Maple Syrup', 'Berries'], 'calories': 540},
        'snack1': {'items': ['Hummus Wrap (1)', 'Carrot Sticks'], 'calories': 410},
        'lunch': {'items': ['Lentil Soup (300ml)', 'Whole Wheat Bread (2)'], 'calories': 630},
        'snack2': {'items': ['Fruit Smoothie', 'Nuts Mix (30g)'], 'calories': 400},
        'dinner': {'items': ['Tofu Fried Rice (200g)', 'Veggies'], 'calories': 620},
    },
    {
        'breakfast': {'items': ['Overnight Oats (100g)', 'Peanut Butter (1 tbsp)', 'Apple'], 'calories': 520},
        'snack1': {'items': ['Vegan Protein Bar', 'Orange'], 'calories': 400},
        'lunch': {'items': ['Bean Burrito Bowl (200g)', 'Avocado'], 'calories': 660},
        'snack2': {'items': ['Soy Yogurt (200g)', 'Granola (40g)'], 'calories': 380},
        'dinner': {'items': ['Chickpea Pasta (200g)', 'Salad'], 'calories': 620},
    },
]

# Vegetarian 7-day varied
vegetarian_days = [
    {
        'breakfast': {'items': ['Paneer Paratha (2)', 'Greek Yogurt (150g)', 'Honey (1 tbsp)'], 'calories': 550},
        'snack1': {'items': ['Cheese Sandwich (2 slices)', 'Almonds (30g)', 'Orange'], 'calories': 400},
        'lunch': {'items': ['Dal Makhani (200ml)', 'Basmati Rice (150g)', 'Cucumber Salad'], 'calories': 650},
        'snack2': {'items': ['Protein Shake with Milk', 'Granola Bar'], 'calories': 400},
        'dinner': {'items': ['Paneer Tikka Masala (200g)', 'Roti (2)', 'Mixed Vegetables'], 'calories': 600},
    },
    {
        'breakfast': {'items': ['Idli (4)', 'Sambar (200ml)', 'Chutney'], 'calories': 520},
        'snack1': {'items': ['Peanut Chikki (50g)', 'Apple'], 'calories': 410},
        'lunch': {'items': ['Rajma (200g)', 'Jeera Rice (150g)'], 'calories': 670},
        'snack2': {'items': ['Lassi (300ml)', 'Roasted Nuts (30g)'], 'calories': 420},
        'dinner': {'items': ['Palak Paneer (200g)', 'Roti (2)'], 'calories': 600},
    },
    {
        'breakfast': {'items': ['Poha (200g)', 'Boiled Eggs (2)'], 'calories': 530},
        'snack1': {'items': ['Veg Sandwich (2)', 'Banana'], 'calories': 400},
        'lunch': {'items': ['Chole (200g)', 'Rice (150g)'], 'calories': 650},
        'snack2': {'items': ['Milk (250ml)', 'Granola Bar'], 'calories': 380},
        'dinner': {'items': ['Veg Biryani (200g)', 'Raita'], 'calories': 620},
    },
    {
        'breakfast': {'items': ['Upma (200g)', 'Coconut Chutney'], 'calories': 520},
        'snack1': {'items': ['Mixed Nuts (40g)', 'Orange'], 'calories': 410},
        'lunch': {'items': ['Sambar Rice (200g)', 'Salad'], 'calories': 640},
        'snack2': {'items': ['Fruit Smoothie', 'Peanut Butter Toast'], 'calories': 400},
        'dinner': {'items': ['Paneer Bhurji (200g)', 'Roti (2)'], 'calories': 610},
    },
    {
        'breakfast': {'items': ['Dosa (2)', 'Sambar (200ml)'], 'calories': 520},
        'snack1': {'items': ['Cheese Toast (2)', 'Apple'], 'calories': 420},
        'lunch': {'items': ['Kadhi (200ml)', 'Rice (150g)'], 'calories': 640},
        'snack2': {'items': ['Milk (250ml)', 'Nuts Mix (30g)'], 'calories': 400},
        'dinner': {'items': ['Vegetable Korma (200g)', 'Roti (2)'], 'calories': 620},
    },
    {
        'breakfast': {'items': ['Paratha (2)', 'Curd (150g)'], 'calories': 540},
        'snack1': {'items': ['Paneer Roll (1)', 'Banana'], 'calories': 410},
        'lunch': {'items': ['Dal (200ml)', 'Rice (150g)'], 'calories': 630},
        'snack2': {'items': ['Protein Shake', 'Granola'], 'calories': 400},
        'dinner': {'items': ['Mushroom Masala (200g)', 'Roti (2)'], 'calories': 620},
    },
    {
        'breakfast': {'items': ['Oats (80g)', 'Milk (250ml)', 'Almonds'], 'calories': 520},
        'snack1': {'items': ['Fruit Bowl', 'Peanut Chikki (40g)'], 'calories': 400},
        'lunch': {'items': ['Paneer Curry (200g)', 'Rice (150g)'], 'calories': 660},
        'snack2': {'items': ['Yogurt (200g)', 'Nuts (30g)'], 'calories': 380},
        'dinner': {'items': ['Veg Pulao (200g)', 'Raita'], 'calories': 620},
    },
]

# Non-veg 7-day varied
nonveg_days = [
    {
        'breakfast': {'items': ['Egg Whites (4)', 'Whole Wheat Toast (2)', 'Butter (1 tbsp)', 'Orange Juice'], 'calories': 550},
        'snack1': {'items': ['Chicken Sandwich (1)', 'Almonds (30g)', 'Apple'], 'calories': 400},
        'lunch': {'items': ['Grilled Chicken (200g)', 'Basmati Rice (150g)', 'Broccoli'], 'calories': 650},
        'snack2': {'items': ['Protein Shake with Milk', 'Granola Bar'], 'calories': 400},
        'dinner': {'items': ['Fish Fillet (200g)', 'Sweet Potato (150g)', 'Salad with Olive Oil'], 'calories': 600},
    },
    {
        'breakfast': {'items': ['Omelette (3 eggs)', 'Toast (2)', 'Banana'], 'calories': 540},
        'snack1': {'items': ['Boiled Eggs (2)', 'Nuts (30g)'], 'calories': 420},
        'lunch': {'items': ['Chicken Curry (200g)', 'Rice (150g)'], 'calories': 660},
        'snack2': {'items': ['Greek Yogurt (200g)', 'Honey'], 'calories': 380},
        'dinner': {'items': ['Grilled Fish (200g)', 'Quinoa (150g)'], 'calories': 620},
    },
    {
        'breakfast': {'items': ['Scrambled Eggs (4)', 'Potato (150g)', 'Orange'], 'calories': 530},
        'snack1': {'items': ['Chicken Wrap (1)', 'Apple'], 'calories': 410},
        'lunch': {'items': ['Mutton Curry (200g)', 'Rice (150g)'], 'calories': 670},
        'snack2': {'items': ['Protein Shake', 'Nuts (30g)'], 'calories': 400},
        'dinner': {'items': ['Chicken Stir-fry (200g)', 'Veggies (150g)'], 'calories': 600},
    },
    {
        'breakfast': {'items': ['Egg Bhurji (4 eggs)', 'Roti (2)'], 'calories': 540},
        'snack1': {'items': ['Tuna Sandwich (1)', 'Orange'], 'calories': 410},
        'lunch': {'items': ['Chicken Biryani (200g)'], 'calories': 650},
        'snack2': {'items': ['Milk (250ml)', 'Granola'], 'calories': 380},
        'dinner': {'items': ['Fish Curry (200g)', 'Rice (150g)'], 'calories': 620},
    },
    {
        'breakfast': {'items': ['Omelette (3 eggs)', 'Toast (2)', 'Apple'], 'calories': 520},
        'snack1': {'items': ['Boiled Eggs (2)', 'Banana'], 'calories': 400},
        'lunch': {'items': ['Turkey/Chicken Salad (200g)', 'Rice (150g)'], 'calories': 640},
        'snack2': {'items': ['Protein Bar', 'Nuts (30g)'], 'calories': 400},
        'dinner': {'items': ['Grilled Chicken (200g)', 'Sweet Potato (150g)'], 'calories': 620},
    },
    {
        'breakfast': {'items': ['Egg Whites (4)', 'Oats (80g)'], 'calories': 520},
        'snack1': {'items': ['Chicken Sandwich (1)', 'Apple'], 'calories': 410},
        'lunch': {'items': ['Fish Curry (200g)', 'Rice (150g)'], 'calories': 650},
        'snack2': {'items': ['Greek Yogurt (200g)', 'Honey'], 'calories': 380},
        'dinner': {'items': ['Chicken Curry (200g)', 'Roti (2)'], 'calories': 620},
    },
    {
        'breakfast': {'items': ['Scrambled Eggs (3)', 'Toast (2)', 'Orange'], 'calories': 520},
        'snack1': {'items': ['Tuna Sandwich (1)', 'Nuts (30g)'], 'calories': 420},
        'lunch': {'items': ['Chicken Tikka (200g)', 'Rice (150g)'], 'calories': 660},
        'snack2': {'items': ['Protein Shake', 'Granola Bar'], 'calories': 400},
        'dinner': {'items': ['Fish Fillet (200g)', 'Veggies (150g)'], 'calories': 600},
    },
]


templates_to_create = [
    {
        'name': 'Muscle Gain - Vegan Very High (2500-3000) - 7 Day Varied',
        'goal_type': 'muscle_gain',
        'calorie_min': 2500,
        'calorie_max': 3000,
        'description': '7-day vegan muscle gain plan with varied meals (2500-3000 calories)',
        'meals_data': json.dumps(build_7day_plan(vegan_days)),
    },
    {
        'name': 'Muscle Gain - Vegetarian Very High (2500-3000) - 7 Day Varied',
        'goal_type': 'muscle_gain',
        'calorie_min': 2500,
        'calorie_max': 3000,
        'description': '7-day vegetarian muscle gain plan with varied meals (2500-3000 calories)',
        'meals_data': json.dumps(build_7day_plan(vegetarian_days)),
    },
    {
        'name': 'Muscle Gain - Non-Veg Very High (2500-3000) - 7 Day Varied',
        'goal_type': 'muscle_gain',
        'calorie_min': 2500,
        'calorie_max': 3000,
        'description': '7-day non-veg muscle gain plan with varied meals (2500-3000 calories)',
        'meals_data': json.dumps(build_7day_plan(nonveg_days)),
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

print("\nVaried 7-day very high templates created successfully!")
