import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard_new.dart';
import 'screens/add_trainer_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/trainer_dashboard.dart';
import 'screens/payment_processing_screen.dart';
import 'screens/set_payment_pin_screen.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String adminDashboard = '/admin-dashboard';
  static const String addTrainer = '/add-trainer';
  static const String userProfile = '/user-profile';
  static const String payment = '/payment';
  static const String trainerDashboard = '/trainer-dashboard';
  static const String paymentProcessing = '/payment-processing';
  static const String setPaymentPin = '/set-payment-pin';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      landing: (context) => const LandingScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      adminDashboard: (context) => const AdminDashboardNew(),
      addTrainer: (context) => const AddTrainerScreen(),
    };
  }
  
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => HomeScreen(
            userId: args['userId'],
            userName: args['userName'],
          ),
        );
      case userProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => UserProfileScreen(
            userId: args['userId'],
            userName: args['userName'],
          ),
        );
      case payment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => PaymentScreen(
            userId: args['userId'],
            amount: args['amount'],
            months: args['months'],
            userName: args['userName'],
          ),
        );
      case trainerDashboard:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => TrainerDashboard(
            trainerId: args['trainerId'],
            trainerName: args['trainerName'],
          ),
        );
      case paymentProcessing:
        return MaterialPageRoute(
          builder: (context) => const PaymentProcessingScreen(),
          settings: settings,
        );
      case setPaymentPin:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => SetPaymentPinScreen(
            userId: args['userId'],
            userName: args['userName'],
          ),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
