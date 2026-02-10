from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.utils import timezone
from django.db import transaction
from .models import UserLogin, PaymentTransaction, UserProfile
from django.contrib.auth.hashers import make_password, check_password
import json
import random
import string
from datetime import timedelta
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.units import inch
from reportlab.lib import colors
from io import BytesIO
from django.http import HttpResponse


def generate_receipt_number():
    """Generate unique receipt number"""
    timestamp = timezone.now().strftime('%Y%m%d%H%M%S')
    random_str = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    return f"GYM-{timestamp}-{random_str}"


@csrf_exempt
@require_http_methods(["POST"])
def set_payment_pin(request):
    
    """
    Set or update payment PIN for user
    """
    try:
        data = json.loads(request.body)
        user_id = data.get('user_id')
        new_pin = data.get('new_pin')
        confirm_pin = data.get('confirm_pin')
        login_password = data.get('login_password')  # Verify identity
        
        # Validate required fields
        if not all([user_id, new_pin, confirm_pin, login_password]):
            return JsonResponse({
                'success': False,
                'message': 'Missing required fields'
            }, status=400)
        
        # Validate PIN format (4 digits)
        if not new_pin.isdigit() or len(new_pin) != 4:
            return JsonResponse({
                'success': False,
                'message': 'PIN must be exactly 4 digits'
            }, status=400)
        
        # Check if PINs match
        if new_pin != confirm_pin:
            return JsonResponse({
                'success': False,
                'message': 'PINs do not match'
            }, status=400)
        
        # Get user and verify login password
        try:
            user = UserLogin.objects.get(id=user_id)
            # Trim whitespace from password
            login_password_trimmed = login_password.strip()
            if not user.check_password(login_password_trimmed):
                return JsonResponse({
                    'success': False,
                    'message': 'Invalid login password. Please enter your correct login password.'
                }, status=401)
        except UserLogin.DoesNotExist:
            return JsonResponse({
                'success': False,
                'message': 'User not found'
            }, status=404)
        
        # Get or create user profile and set payment PIN
        user_profile, created = UserProfile.objects.get_or_create(
            user=user,
            defaults={
                'age': 25,
                'gender': 'other',
                'current_weight': 70.0,
                'current_height': 170.0,
                'goal': 'others',
                'target_weight': 70.0,
                'target_months': 1,
                'workout_time': 'morning',
                'diet_preference': 'others'
            }
        )
        
        # Hash and save payment PIN
        user_profile.payment_pin = make_password(new_pin)
        user_profile.save()
        
        return JsonResponse({
            'success': True,
            'message': 'Payment PIN set successfully'
        }, status=200)
        
    except json.JSONDecodeError:
        return JsonResponse({
            'success': False,
            'message': 'Invalid JSON data'
        }, status=400)
    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': f'Error setting payment PIN: {str(e)}'
        }, status=500)



@csrf_exempt
@require_http_methods(["POST"])
def verify_pin_and_process_payment(request):
    """
    Verify user payment PIN and process subscription payment
    """
    try:
        data = json.loads(request.body)
        user_id = data.get('user_id')
        pin = data.get('pin')
        amount = data.get('amount')
        payment_method = data.get('payment_method')
        renewal_period = data.get('renewal_period')
        discount_percentage = data.get('discount_percentage', 0)
        
        # Validate required fields
        if not all([user_id, pin, amount, payment_method, renewal_period]):
            return JsonResponse({
                'success': False,
                'message': 'Missing required fields'
            }, status=400)
        
        # Get user
        try:
            user = UserLogin.objects.get(id=user_id)
        except UserLogin.DoesNotExist:
            return JsonResponse({
                'success': False,
                'message': 'User not found'
            }, status=404)
        
        # Get user profile and check payment PIN
        try:
            user_profile = UserProfile.objects.get(user=user)
            if not user_profile.payment_pin:
                return JsonResponse({
                    'success': False,
                    'message': 'Payment PIN not set. Please set your payment PIN first.'
                }, status=400)
            
            # Verify payment PIN
            pin_trimmed = pin.strip()
            if not check_password(pin_trimmed, user_profile.payment_pin):
                return JsonResponse({
                    'success': False,
                    'message': 'Invalid payment PIN. Please try again.'
                }, status=401)
        except UserProfile.DoesNotExist:
            return JsonResponse({
                'success': False,
                'message': 'User profile not found. Please complete your profile first.'
            }, status=404)
        
        # Create payment transaction
        receipt_number = generate_receipt_number()
        
        with transaction.atomic():
            payment = PaymentTransaction.objects.create(
                user=user,
                amount=amount,
                payment_method=payment_method,
                renewal_period=renewal_period,
                status='completed',
                receipt_number=receipt_number,
                discount_percentage=discount_percentage
            )
            
            # Update user profile subscription end date
            try:
                user_profile = UserProfile.objects.get(user=user)
                current_end_date = user_profile.subscription_end_date
                
                # If subscription has expired or doesn't exist, start from today
                if not current_end_date or current_end_date < timezone.now():
                    current_end_date = timezone.now()
                
                # Add renewal period
                new_end_date = current_end_date + timedelta(days=renewal_period * 30)
                user_profile.subscription_end_date = new_end_date
                user_profile.payment_status = True
                user_profile.payment_amount = amount
                user_profile.payment_method = payment_method
                user_profile.payment_date = timezone.now()
                user_profile.save()
            except UserProfile.DoesNotExist:
                # If no profile exists, create basic one with subscription
                new_end_date = timezone.now() + timedelta(days=renewal_period * 30)
                user_profile = UserProfile.objects.create(
                    user=user,
                    subscription_end_date=new_end_date,
                    subscription_start_date=timezone.now(),
                    payment_status=True,
                    payment_amount=amount,
                    payment_method=payment_method,
                    payment_date=timezone.now(),
                    # Required fields with defaults
                    age=25,
                    gender='other',
                    current_weight=70.0,
                    current_height=170.0,
                    goal='others',
                    target_weight=70.0,
                    target_months=1,
                    workout_time='morning',
                    diet_preference='others'
                )
        
        return JsonResponse({
            'success': True,
            'message': 'Payment successful!',
            'receipt_number': receipt_number,
            'transaction_id': payment.id,
            'subscription_end_date': new_end_date.strftime('%Y-%m-%d')
        }, status=200)
        
    except json.JSONDecodeError:
        return JsonResponse({
            'success': False,
            'message': 'Invalid JSON data'
        }, status=400)
    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': f'Error processing payment: {str(e)}'
        }, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def generate_payment_receipt(request, transaction_id):
    """
    Generate PDF receipt for payment transaction
    """
    try:
        # Get transaction
        try:
            payment = PaymentTransaction.objects.select_related('user').get(id=transaction_id)
        except PaymentTransaction.DoesNotExist:
            return JsonResponse({
                'success': False,
                'message': 'Transaction not found'
            }, status=404)
        
        # Create PDF in memory
        buffer = BytesIO()
        pdf = canvas.Canvas(buffer, pagesize=letter)
        width, height = letter
        
        # Set up colors
        primary_color = colors.HexColor('#6B46C1')  # Purple
        text_color = colors.HexColor('#2D3748')
        
        # Header
        pdf.setFillColor(primary_color)
        pdf.rect(0, height - 100, width, 100, fill=True, stroke=False)
        
        pdf.setFillColor(colors.white)
        pdf.setFont("Helvetica-Bold", 28)
        pdf.drawCentredString(width / 2, height - 50, "FITNESS GYM")
        
        pdf.setFont("Helvetica", 14)
        pdf.drawCentredString(width / 2, height - 75, "Payment Receipt")
        
        # Receipt details box
        pdf.setFillColor(text_color)
        pdf.setFont("Helvetica-Bold", 12)
        
        y_position = height - 140
        
        # Receipt Number
        pdf.drawString(1 * inch, y_position, "Receipt Number:")
        pdf.setFont("Helvetica", 12)
        pdf.drawString(3 * inch, y_position, payment.receipt_number)
        
        y_position -= 25
        
        # Date
        pdf.setFont("Helvetica-Bold", 12)
        pdf.drawString(1 * inch, y_position, "Transaction Date:")
        pdf.setFont("Helvetica", 12)
        pdf.drawString(3 * inch, y_position, payment.transaction_date.strftime('%B %d, %Y %I:%M %p'))
        
        y_position -= 40
        
        # Customer details section
        pdf.setFillColor(primary_color)
        pdf.setFont("Helvetica-Bold", 14)
        pdf.drawString(1 * inch, y_position, "Customer Details")
        
        y_position -= 25
        pdf.setFillColor(text_color)
        pdf.setFont("Helvetica-Bold", 11)
        pdf.drawString(1 * inch, y_position, "Name:")
        pdf.setFont("Helvetica", 11)
        pdf.drawString(2.5 * inch, y_position, payment.user.name)
        
        y_position -= 20
        pdf.setFont("Helvetica-Bold", 11)
        pdf.drawString(1 * inch, y_position, "Email:")
        pdf.setFont("Helvetica", 11)
        pdf.drawString(2.5 * inch, y_position, payment.user.emailid)
        
        y_position -= 40
        
        # Payment details section
        pdf.setFillColor(primary_color)
        pdf.setFont("Helvetica-Bold", 14)
        pdf.drawString(1 * inch, y_position, "Payment Details")
        
        y_position -= 25
        pdf.setFillColor(text_color)
        pdf.setFont("Helvetica-Bold", 11)
        pdf.drawString(1 * inch, y_position, "Renewal Period:")
        pdf.setFont("Helvetica", 11)
        renewal_text = f"{payment.renewal_period} Month{'s' if payment.renewal_period > 1 else ''}"
        pdf.drawString(2.5 * inch, y_position, renewal_text)
        
        y_position -= 20
        pdf.setFont("Helvetica-Bold", 11)
        pdf.drawString(1 * inch, y_position, "Payment Method:")
        pdf.setFont("Helvetica", 11)
        pdf.drawString(2.5 * inch, y_position, payment.get_payment_method_display())
        
        y_position -= 20
        pdf.setFont("Helvetica-Bold", 11)
        pdf.drawString(1 * inch, y_position, "Status:")
        pdf.setFont("Helvetica", 11)
        pdf.setFillColor(colors.green)
        pdf.drawString(2.5 * inch, y_position, payment.get_status_display().upper())
        
        y_position -= 30
        
        # Amount section with box
        pdf.setFillColor(colors.lightgrey)
        pdf.rect(1 * inch, y_position - 30, 5 * inch, 50, fill=True, stroke=True)
        
        pdf.setFillColor(text_color)
        pdf.setFont("Helvetica-Bold", 14)
        pdf.drawString(1.2 * inch, y_position - 10, "Total Amount Paid:")
        pdf.setFont("Helvetica-Bold", 18)
        pdf.setFillColor(primary_color)
        pdf.drawString(4.5 * inch, y_position - 10, f"₹{payment.amount}")
        
        # Footer
        pdf.setFillColor(text_color)
        pdf.setFont("Helvetica-Oblique", 9)
        pdf.drawCentredString(width / 2, 1 * inch, "Thank you for your payment!")
        pdf.drawCentredString(width / 2, 0.7 * inch, "For queries, contact: support@fitnessgym.com")
        
        # Draw border
        pdf.setStrokeColor(primary_color)
        pdf.setLineWidth(2)
        pdf.rect(0.5 * inch, 0.5 * inch, width - 1 * inch, height - 1 * inch, fill=False, stroke=True)
        
        # Save PDF
        pdf.showPage()
        pdf.save()
        
        # Get PDF from buffer
        buffer.seek(0)
        
        # Create response
        response = HttpResponse(buffer.getvalue(), content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="receipt_{payment.receipt_number}.pdf"'
        
        return response
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': f'Error generating receipt: {str(e)}'
        }, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def get_user_payment_history(request, user_id):
    """
    Get payment history for a user
    """
    try:
        # Get user
        try:
            user = UserLogin.objects.get(id=user_id)
        except UserLogin.DoesNotExist:
            return JsonResponse({
                'success': False,
                'message': 'User not found'
            }, status=404)
        
        # Get all payment transactions for user
        payments = PaymentTransaction.objects.filter(user=user).order_by('-transaction_date')
        
        payment_list = []
        for payment in payments:
            payment_list.append({
                'id': payment.id,
                'receipt_number': payment.receipt_number,
                'amount': str(payment.amount),
                'payment_method': payment.get_payment_method_display(),
                'renewal_period': payment.renewal_period,
                'status': payment.get_status_display(),
                'transaction_date': payment.transaction_date.strftime('%Y-%m-%d %H:%M:%S'),
                'discount_percentage': str(payment.discount_percentage)
            })
        
        return JsonResponse({
            'success': True,
            'payments': payment_list
        }, status=200)
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': f'Error fetching payment history: {str(e)}'
        }, status=500)


@csrf_exempt
@require_http_methods(["POST"])
def check_payment_pin(request):
    """
    Check if user has payment PIN set
    """
    try:
        data = json.loads(request.body)
        user_id = data.get('user_id')
        
        if not user_id:
            return JsonResponse({
                'success': False,
                'message': 'User ID is required'
            }, status=400)
        
        try:
            user = UserLogin.objects.get(id=user_id)
            user_profile = UserProfile.objects.filter(user=user).first()
            
            # Check if payment PIN exists and is set
            has_pin = user_profile and user_profile.payment_pin and user_profile.payment_pin.strip() != ''
            
            return JsonResponse({
                'success': True,
                'has_pin': has_pin
            }, status=200)
        except UserLogin.DoesNotExist:
            return JsonResponse({
                'success': False,
                'message': 'User not found'
            }, status=404)
    except Exception as e:
        return JsonResponse({
            'success': False,
            'message': f'Error checking PIN: {str(e)}'
        }, status=500)
