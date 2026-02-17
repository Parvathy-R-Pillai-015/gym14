# 🏋️ Gym Management System

A comprehensive full-stack gym management application built with Flutter (Frontend), Django (Backend), and MySQL (Database). This system manages users, trainers, workout videos, diet plans, payments, and attendance tracking.

---

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [User Roles](#user-roles)
- [Key Features Documentation](#key-features-documentation)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Admin Dashboard](#admin-dashboard)
- [Screenshots](#screenshots)
- [Contributing](#contributing)

---

## ✨ Features

### User Management
- ✅ User registration and login with secure password hashing
- ✅ Profile management with fitness goals
- ✅ Role-based access control (User, Trainer, Admin)
- ✅ Password reset with OTP verification

### Trainer Management
- ✅ Trainer registration with specialization
- ✅ Goal-based trainer assignment (Muscle Gain, Weight Loss, Weight Gain, Others)
- ✅ Trainer dashboard for managing assigned users
- ✅ Real-time chat between trainers and users

### Diet Plan System
- ✅ Personalized calorie calculation based on user goals
- ✅ 7-day varied meal plans with multiple diet preferences
- ✅ Diet templates for different calorie ranges
- ✅ Support for Vegan, Vegetarian, and Non-Vegetarian diets
- ✅ Dynamic food calorie tracking

### Workout Video Management
- ✅ Video upload and categorization by goal type
- ✅ Difficulty level classification (Beginner/Advanced)
- ✅ Goal-specific video recommendations
- ✅ Admin dashboard for video management
- ✅ Real-time trainer filtering in admin

### Payment System
- ✅ Secure payment PIN management
- ✅ Multiple payment methods (GPay, PhonePe, Paytm, UPI)
- ✅ Subscription renewal and tracking
- ✅ Payment receipt generation (PDF)
- ✅ Payment history tracking

### Attendance Tracking
- ✅ User attendance request system
- ✅ Trainer approval workflow
- ✅ Attendance history and statistics

### Recipe Management
- ✅ Healthy food recipes with detailed nutritional info
- ✅ Category-based recipe filtering
- ✅ Step-by-step cooking instructions

---

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** StatefulWidget
- **HTTP Client:** http package
- **Platform:** Web (Chrome), can be extended to Mobile (iOS/Android)

### Backend
- **Framework:** Django 4.2.7 (Python)
- **API:** Django REST Framework (Function-based views)
- **Authentication:** Django built-in authentication with password hashing (PBKDF2-SHA256)
- **File Storage:** Django Media files
- **PDF Generation:** ReportLab

### Database
- **Database:** MySQL
- **ORM:** Django ORM
- **Database Name:** db_gym

### Additional Tools
- **Version Control:** Git & GitHub
- **Admin Panel:** Django Admin (Customized)

---

## 📁 Project Structure

```
Gym/
├── gym_frontend/                # Flutter Frontend Application
│   ├── lib/
│   │   ├── main.dart           # Entry point
│   │   ├── routes.dart         # Route configuration
│   │   └── screens/            # All UI screens
│   │       ├── landing_screen.dart
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       ├── home_screen.dart          # User Dashboard
│   │       ├── trainer_dashboard.dart    # Trainer Dashboard
│   │       ├── admin_dashboard_new.dart  # Admin Dashboard
│   │       ├── payment_screen.dart
│   │       ├── pin_entry_screen.dart
│   │       ├── set_payment_pin_screen.dart
│   │       └── ...
│   ├── assets/
│   └── pubspec.yaml
│
├── gym_backend/                 # Django Backend Application
│   ├── gym_backend/            # Project settings
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── users/                  # Main app
│   │   ├── models.py           # Database models
│   │   ├── views.py            # API endpoints
│   │   ├── admin.py            # Admin customization
│   │   ├── admin_views.py      # Admin API views
│   │   ├── payment_views.py    # Payment APIs
│   │   ├── food_views.py       # Food/Diet APIs
│   │   ├── otp_views.py        # OTP verification
│   │   └── migrations/
│   ├── media/
│   │   └── workout_videos/     # Video storage
│   ├── static/
│   │   └── admin/js/           # Custom admin scripts
│   ├── manage.py
│   └── requirements.txt
│
├── .venv/                      # Python virtual environment
├── README.md                   # This file
└── .gitignore
```

---

## 🚀 Installation

### Prerequisites
- Python 3.12+
- Flutter SDK 3.0+
- MySQL Server 8.0+
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/Parvathy-R-Pillai-015/gym12.git
cd gym12
```

### 2. Backend Setup

#### Create Virtual Environment
```bash
cd gym_backend
python -m venv .venv
```

#### Activate Virtual Environment
**Windows:**
```bash
.venv\Scripts\activate
```

**Mac/Linux:**
```bash
source .venv/bin/activate
```

#### Install Dependencies
```bash
pip install django==4.2.7
pip install mysqlclient
pip install pillow
pip install reportlab
```

Or install from requirements.txt:
```bash
pip install -r requirements.txt
```

### 3. Database Setup

#### Create MySQL Database
```sql
CREATE DATABASE db_gym CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### Update Database Settings
Edit `gym_backend/gym_backend/settings.py`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'db_gym',
        'USER': 'your_mysql_username',
        'PASSWORD': 'your_mysql_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

#### Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

#### Create Superuser (Admin)
```bash
python manage.py createsuperuser
```

### 4. Frontend Setup

```bash
cd ../gym_frontend
flutter pub get
```

---

## ▶️ Running the Application

### Start Backend Server

```bash
cd gym_backend
python manage.py runserver
```
Backend will run at: **http://127.0.0.1:8000/**

Admin panel: **http://127.0.0.1:8000/admin/**

### Start Frontend Application

```bash
cd gym_frontend
flutter run -d chrome
```
Frontend will run at: **http://localhost:58543/** (or similar port)

---

## 👥 User Roles

### 1. **User (Regular Member)**
- Register and login
- View personalized diet plans
- Track attendance
- Make subscription payments
- View workout videos
- Chat with assigned trainer
- Track food calorie intake

### 2. **Trainer**
- Manage assigned users
- Create and assign diet plans
- Approve attendance requests
- Upload workout videos
- Chat with users
- View user progress

### 3. **Admin**
- Full system access via Django Admin
- Manage users, trainers, and content
- View payment transactions
- Manage diet templates
- Upload and categorize videos
- System configuration

---

## 🎯 Key Features Documentation

### Calorie Calculation System

**Formula:**
```
BMR (Base Metabolic Rate) = Current Weight (kg) × 24

Daily Calorie Adjustment:
- Weight change target: (Target Weight - Current Weight) / Target Months
- Calories per kg: 7700 calories = 1 kg body weight
- Daily adjustment: (Weight change per month / 30) × 7700

Target Calories = BMR + Daily Adjustment
```

**Safety Limits:**
- Maximum weight gain: 1 kg/week
- Maximum weight loss: 1 kg/week

### Diet Plan Template System

Templates are categorized by:
- **Goal Type:** muscle_gain, weight_loss, weight_gain, others
- **Calorie Range:** Min and Max calories (e.g., 2000-2500)
- **Diet Preference:** Vegan, Vegetarian, Non-Vegetarian
- **Duration:** Single day or 7-day plans

**Example Calorie Ranges:**
- Very Low: 1200-1500 cal
- Low: 1500-2000 cal
- Medium: 2000-2500 cal
- High: 2500-3000 cal
- Very High: 3000+ cal

### Payment PIN System

1. **First-time users:** Automatically redirected to Set PIN screen
2. **PIN Creation:** 4-digit numeric PIN with login password verification
3. **PIN Storage:** Securely hashed using Django's `make_password()`
4. **Payment Flow:**
   - Select payment method → Check PIN exists → Enter PIN → Verify → Process payment → Generate receipt

### Workout Video Categorization

Videos are organized by:
- **Goal Type:** Must match user's fitness goal
- **Difficulty Level:**
  - Beginner: 0-10kg weight difference
  - Advanced: 11-30kg weight difference
- **Trainer Assignment:** Videos assigned to trainers with matching specialization

### Real-time Trainer Filtering (Admin)

**How it works:**
1. Admin selects Goal Type (e.g., Muscle Gain)
2. JavaScript triggers AJAX call to `/api/users/trainers-by-goal/`
3. Backend filters trainers where `goal_category == selected_goal_type`
4. Dropdown updates in real-time with filtered trainers

---

## 📡 API Documentation

### Base URL
```
http://127.0.0.1:8000/api/
```

### Authentication Endpoints

#### User Registration
```http
POST /api/users/create/
Content-Type: application/json

{
  "name": "John Doe",
  "emailid": "john@example.com",
  "password": "password123"
}
```

#### User Login
```http
POST /api/users/login/
Content-Type: application/json

{
  "emailid": "john@example.com",
  "password": "password123"
}

Response:
{
  "success": true,
  "user": {
    "id": 1,
    "name": "John Doe",
    "emailid": "john@example.com",
    "role": "user"
  }
}
```

### Profile Endpoints

#### Create User Profile
```http
POST /api/profile/create/
Content-Type: application/json

{
  "user_id": 1,
  "age": 25,
  "gender": "male",
  "current_weight": 70.0,
  "current_height": 175.0,
  "goal": "muscle_gain",
  "target_weight": 80.0,
  "target_months": 6,
  "workout_time": "morning",
  "diet_preference": "non_veg"
}
```

#### Get User Profile
```http
GET /api/profile/{user_id}/
```

### Diet Plan Endpoints

#### Get Diet Templates
```http
GET /api/diet/templates/?goal_type=muscle_gain&calorie_min=2000&calorie_max=2500
```

#### Create User Diet Plan
```http
POST /api/diet/create-plan/
Content-Type: application/json

{
  "user_id": 1,
  "trainer_id": 5,
  "template_id": 10,
  "start_date": "2026-02-17"
}
```

#### Get User's Active Diet Plan
```http
GET /api/diet/active-plan/{user_id}/
```

### Payment Endpoints

#### Set Payment PIN
```http
POST /api/payment/set-pin/
Content-Type: application/json

{
  "user_id": 1,
  "new_pin": "1234",
  "confirm_pin": "1234",
  "login_password": "password123"
}
```

#### Check if PIN Exists
```http
POST /api/payment/check-pin/
Content-Type: application/json

{
  "user_id": 1
}

Response:
{
  "success": true,
  "has_pin": true
}
```

#### Verify PIN and Process Payment
```http
POST /api/payment/verify-pin/
Content-Type: application/json

{
  "user_id": 1,
  "pin": "1234",
  "amount": 5000,
  "payment_method": "gpay",
  "renewal_period": 3,
  "discount_percentage": 0
}
```

#### Get Payment Receipt
```http
GET /api/payment/receipt/{transaction_id}/
```

#### Get Payment History
```http
GET /api/payment/history/{user_id}/
```

### Trainer Endpoints

#### Get Trainers by Goal Category
```http
GET /api/users/trainers-by-goal/?goal_type=muscle_gain

Response:
{
  "success": true,
  "trainers": [
    {
      "id": 5,
      "name": "Amal - Muscle Gain",
      "goal_category": "muscle_gain"
    }
  ]
}
```

#### Get Trainer's Assigned Users
```http
GET /api/trainer/{trainer_id}/users/
```

### Workout Video Endpoints

#### Get Videos by Goal
```http
GET /api/videos/by-goal/?goal_type=muscle_gain&difficulty=beginner
```

### Attendance Endpoints

#### Request Attendance
```http
POST /api/attendance/request/
Content-Type: application/json

{
  "user_id": 1,
  "date": "2026-02-17"
}
```

#### Accept Attendance (Trainer)
```http
POST /api/attendance/accept/
Content-Type: application/json

{
  "attendance_id": 10
}
```

#### Get User Attendance
```http
GET /api/attendance/user/{user_id}/
```

### Food & Recipe Endpoints

#### Get Food Items
```http
GET /api/food/items/
```

#### Search Food Items
```http
GET /api/food/search/?query=rice
```

#### Log Food Entry
```http
POST /api/food/log/
Content-Type: application/json

{
  "user_id": 1,
  "food_item_id": 15,
  "quantity": 150,
  "meal_type": "breakfast",
  "date": "2026-02-17"
}
```

---

## 🗄️ Database Schema

### Key Models

#### UserLogin
```python
- id (PK)
- name
- emailid (unique)
- password (hashed)
- role (user/trainer/admin)
- is_active
- created_at
- updated_at
```

#### UserProfile
```python
- id (PK)
- user (FK to UserLogin)
- age
- gender
- current_weight
- current_height
- goal (muscle_gain/weight_loss/weight_gain/others)
- target_weight
- target_months
- workout_time
- diet_preference
- payment_pin (hashed)
```

#### Trainer
```python
- id (PK)
- user (FK to UserLogin)
- mobile
- gender
- experience
- specialization
- goal_category (matches UserProfile.goal)
- joining_period
- is_active
```

#### DietPlanTemplate
```python
- id (PK)
- name
- goal_type
- calorie_min
- calorie_max
- diet_type (vegan/vegetarian/non_veg)
- meals_data (JSON with 7-day meal structure)
- is_active
```

#### UserDietPlan
```python
- id (PK)
- user (FK to UserProfile)
- trainer (FK to Trainer)
- template (FK to DietPlanTemplate)
- meals_data (customizable JSON)
- target_calories
- start_date
- end_date
- is_active
```

#### WorkoutVideo
```python
- id (PK)
- title
- description
- video_file
- thumbnail
- goal_type
- difficulty_level (beginner/advanced)
- min_weight_difference
- max_weight_difference
- uploaded_by (FK to Trainer)
- uploaded_via (web/bulk)
- day_number
- is_active
```

#### PaymentTransaction
```python
- id (PK)
- user (FK to UserProfile)
- amount
- payment_method
- receipt_number
- renewal_period
- discount_percentage
- subscription_start_date
- subscription_end_date
- payment_status
- created_at
```

---

## 🔧 Admin Dashboard

Access: **http://127.0.0.1:8000/admin/**

### Features

✅ **User Management**
- View all registered users
- Edit user details and roles
- Activate/deactivate accounts

✅ **Trainer Management**
- Create and assign trainers
- Set goal categories
- View trainer statistics

✅ **Diet Template Management**
- Create 7-day meal plans
- Set calorie ranges
- Manage diet preferences

✅ **Workout Video Management**
- Upload videos
- **Real-time trainer filtering** based on goal type
- Categorize by difficulty
- Set weight difference ranges

✅ **Payment Tracking**
- View all transactions
- Generate receipts
- Track subscription status

✅ **Content Management**
- Food items and recipes
- OTP management
- Chat moderation

---

## 🎨 Screenshots

### Landing Page
Welcome screen with Login and Sign Up options

### User Dashboard
- Profile overview
- Active diet plan display
- Attendance tracking
- Payment status
- Workout video recommendations

### Trainer Dashboard
- Assigned users list
- Diet plan creation for users
- Attendance approval
- User progress tracking

### Payment Flow
1. Payment method selection
2. Auto-redirect to Set PIN (first time) or Enter PIN
3. PIN verification
4. Payment success with receipt download
5. "Back" button to landing page

### Admin Features
- Django admin interface
- Real-time trainer dropdown filtering
- Video upload and categorization
- User and trainer management

---

## 🔐 Security Features

✅ **Password Security**
- PBKDF2-SHA256 hashing algorithm
- Automatic trimming of whitespace
- Django built-in password validation

✅ **Payment PIN Security**
- Separate from login password
- 4-digit numeric PIN
- Hashed storage
- Login password verification required to set/change PIN

✅ **Data Validation**
- Input sanitization (.strip() on all inputs)
- Email uniqueness validation
- Required field validation
- Type checking

✅ **Access Control**
- Role-based permissions
- API endpoint authentication
- Admin-only routes

---

## 📝 Configuration Files

### settings.py (Backend)
```python
# Key Settings
DEBUG = True  # Set to False in production
ALLOWED_HOSTS = ['127.0.0.1', 'localhost']

# Media Files
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Static Files
STATIC_URL = '/static/'
```

### pubspec.yaml (Frontend)
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  file_picker: ^6.0.0
  video_player: ^2.8.0
```

---

## 🐛 Common Issues & Solutions

### Issue: MySQL Connection Error
**Solution:**
1. Check MySQL service is running
2. Verify credentials in settings.py
3. Ensure database `db_gym` exists

### Issue: Module Not Found (reportlab)
**Solution:**
```bash
pip install reportlab
```

### Issue: Flutter packages not found
**Solution:**
```bash
flutter pub get
flutter clean
flutter pub get
```

### Issue: CORS errors
**Solution:** Add `django-cors-headers` if deploying to different domains

### Issue: Admin static files not loading
**Solution:**
```bash
python manage.py collectstatic
```

---

## 🚀 Deployment

### Backend Deployment (Django)

1. Set `DEBUG = False` in settings.py
2. Configure `ALLOWED_HOSTS`
3. Set up production database
4. Collect static files: `python manage.py collectstatic`
5. Use gunicorn or uWSGI
6. Set up Nginx as reverse proxy

### Frontend Deployment (Flutter Web)

```bash
flutter build web
```

Deploy the `build/web` folder to hosting service (Firebase, Netlify, Vercel, etc.)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is developed for educational purposes.

---

## 👨‍💻 Authors

**Parvathy R Pillai**
- GitHub: [@Parvathy-R-Pillai-015](https://github.com/Parvathy-R-Pillai-015)

---

## 📞 Support

For issues or questions:
- Create an issue on GitHub
- Check existing documentation files:
  - `CHAT_SYSTEM_IMPLEMENTATION.md`
  - `FOOD_CALORIE_TRACKER_IMPLEMENTATION.md`
  - `TRAINER_ASSIGNMENT_GUIDE.md`

---

## 🎉 Acknowledgments

- Django Documentation
- Flutter Documentation
- MySQL Documentation
- ReportLab for PDF generation

---

## 📊 Project Statistics

- **Total Lines of Code:** ~15,000+
- **API Endpoints:** 50+
- **Database Models:** 20+
- **Flutter Screens:** 15+
- **Features Implemented:** 30+

---

**Last Updated:** February 17, 2026

**Version:** 1.0.0

**Status:** ✅ Fully Operational - Frontend, Backend, and MySQL fully connected
